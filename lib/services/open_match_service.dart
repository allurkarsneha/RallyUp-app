import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/booking_draft.dart';
import '../models/open_match.dart';
import 'chat_service.dart';
import 'notification_service.dart';
import 'schedule_conflict_service.dart';

/// Firestore layer for `open_matches/{id}`.
///
/// Design notes:
///   * Queries use only `where('status', whereIn: …)` (no composite
///     ordering) — sorting happens client-side. Keeps us out of the
///     composite-index land in this phase.
///   * Joining a match is a real Firestore transaction so two users
///     tapping Join on the last spot at the same time can't both
///     succeed. The transaction also rejects host-self-join, duplicate
///     join, cancelled, and full states inside the same atomic
///     read-write — no TOCTOU window.
///   * Capacity is measured by [OpenMatch.effectiveJoinedCount]
///     (`joinedPlayerIds.length + confirmedGuestCount`), not by the
///     array length, so "players already confirmed" from
///     PlayersSetupSheet counts toward `full` / `spotsLeft` correctly.
class OpenMatchService {
  final FirebaseFirestore _db;
  final NotificationService _notifications;
  final ChatService _chatService;
  final ScheduleConflictService _conflicts;

  OpenMatchService({
    FirebaseFirestore? db,
    NotificationService? notifications,
    ChatService? chatService,
    ScheduleConflictService? conflicts,
  }) : _db = db ?? FirebaseFirestore.instance,
       _notifications = notifications ?? NotificationService(),
       _chatService = chatService ?? ChatService(),
       _conflicts =
           conflicts ??
           ScheduleConflictService(db: db ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _matches =>
      _db.collection('open_matches');

  /// Streams every visible open match. Cancelled docs are filtered
  /// out client-side so a cancelled match still exists for auditing
  /// but never appears in the user-facing lists. Both `open` and
  /// `full` are surfaced — full ones render in a disabled state on
  /// the details page rather than disappearing, so a user who clicked
  /// a notification for a now-full match still sees what happened.
  Stream<List<OpenMatch>> streamOpenMatches() {
    return _matches
        .where(
          'status',
          whereIn: const [OpenMatch.statusOpen, OpenMatch.statusFull],
        )
        .snapshots()
        .map((snap) {
          final matches = snap.docs
              .map((doc) => OpenMatch.fromDoc(doc))
              .toList();
          matches.sort((a, b) {
            final byDate = a.date.compareTo(b.date);
            if (byDate != 0) return byDate;
            return a.startTime.compareTo(b.startTime);
          });
          return matches;
        });
  }

  /// Streams every open match where [userId] is either the host or
  /// one of the joined players. Used by MyBookingsPage so users can
  /// see hosted + joined matches alongside their private bookings.
  ///
  /// Filtering is client-side rather than a Firestore composite
  /// (`hostUid == uid OR joinedPlayerIds arrayContains uid`) so we
  /// don't have to ship an index. Per-user match volume is small
  /// enough that the entire `open_matches` collection scan is fine
  /// in this phase.
  ///
  /// Cancelled matches are kept in the stream — MyBookingsPage surfaces
  /// them under Past with a "Cancelled" tag so the user can see what
  /// happened to a match they were part of.
  Stream<List<OpenMatch>> streamMatchesForUser(String userId) {
    return _matches.snapshots().map((snap) {
      final mine = <OpenMatch>[];
      for (final doc in snap.docs) {
        final m = OpenMatch.fromDoc(doc);
        if (m.hostUid == userId || m.joinedPlayerIds.contains(userId)) {
          mine.add(m);
        }
      }
      mine.sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return a.startTime.compareTo(b.startTime);
      });
      return mine;
    });
  }

  Future<OpenMatch?> getOpenMatch(String matchId) async {
    final snap = await _matches.doc(matchId).get();
    if (!snap.exists) return null;
    return OpenMatch.fromDoc(snap);
  }

  /// Live stream of a single match doc. Emits `null` once the doc
  /// is missing (host nuked it, server-side delete, etc.). Used by
  /// invite cards so the "X / Y joined · N spots left" line stays
  /// honest as other players accept / leave the underlying match.
  Stream<OpenMatch?> streamOpenMatch(String matchId) {
    return _matches.doc(matchId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return OpenMatch.fromDoc(snap);
    });
  }

  /// Create an open match doc with the host pre-joined as the first
  /// player and `confirmedGuestCount = playersConfirmed - 1` so any
  /// already-confirmed guests the host claims at PlayersSetupSheet
  /// time are counted toward capacity without inventing fake uids.
  ///
  /// Status starts `open` (or `full` immediately if the effective
  /// joined count meets `playersRequired`).
  ///
  /// Simple duplicate-host conflict check (per Task 11 of the earlier
  /// phase): before writing, scan for an existing non-cancelled match
  /// by this host on the same court / date / startTime. Bails out
  /// with a clear `StateError` so the UI can surface a friendly
  /// message. This is a single-field `where('hostUid')` scan and
  /// filtered client-side — no composite index required.
  Future<OpenMatch> createOpenMatch({
    required AppUser host,
    required BookingDraft draft,
  }) async {
    final dayOnly = DateTime(draft.date.year, draft.date.month, draft.date.day);

    // Shared schedule conflict guards. Combines court-occupancy
    // (no double-booking the same court) with personal-schedule
    // (the host can't be in two overlapping sessions). Throws
    // distinct StateError messages — `court-occupied` vs
    // `schedule-conflict` — so the UI can surface the right copy.
    await _conflicts.assertNoConflictForNewReservation(
      userId: host.uid,
      courtId: draft.court.id,
      date: dayOnly,
      startTime: draft.startTime,
      endTime: draft.endTime,
    );

    final ref = _matches.doc();
    final now = DateTime.now();
    final required = (draft.playersRequired ?? 1).clamp(1, 1000);
    // Clamp playersConfirmed to [1, required]. The host always counts
    // as 1; values outside the range can come from a stale picker
    // state. We never go below 1 (the host can't un-include
    // themselves) or above required (would overfill the match before
    // anyone joins).
    final playersConfirmed = (draft.playersConfirmed ?? 1).clamp(1, required);
    final confirmedGuestCount = playersConfirmed - 1;
    final joinedIds = <String>[host.uid];
    final joinedNames = <String>[host.displayName];
    final imageUrls = List<String>.from(draft.court.imageUrls);
    final firstImageUrl = imageUrls.isNotEmpty ? imageUrls.first : '';
    final effectiveJoined = joinedIds.length + confirmedGuestCount;
    final initialStatus = effectiveJoined >= required
        ? OpenMatch.statusFull
        : OpenMatch.statusOpen;

    await ref.set({
      'hostUid': host.uid,
      'hostName': host.displayName,
      'hostInitials': host.initials,
      'hostPhotoUrl': host.photoUrl,
      'hostAvatarId': host.avatarId,
      'courtId': draft.court.id,
      'courtName': draft.court.name,
      'courtAddress': draft.court.address,
      'courtImageUrl': firstImageUrl,
      'courtImageUrls': imageUrls,
      'sportType': draft.sportType,
      'date': Timestamp.fromDate(dayOnly),
      'startTime': draft.startTime,
      'endTime': draft.endTime,
      'pricePerHour': draft.court.pricePerHour,
      'totalPrice': draft.totalPrice,
      'playersRequired': required,
      'joinedPlayerIds': joinedIds,
      'joinedPlayerNames': joinedNames,
      'confirmedGuestCount': confirmedGuestCount,
      'status': initialStatus,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final created = OpenMatch(
      id: ref.id,
      hostUid: host.uid,
      hostName: host.displayName,
      hostInitials: host.initials,
      hostPhotoUrl: host.photoUrl,
      hostAvatarId: host.avatarId,
      courtId: draft.court.id,
      courtName: draft.court.name,
      courtAddress: draft.court.address,
      courtImageUrl: firstImageUrl,
      courtImageUrls: imageUrls,
      sportType: draft.sportType,
      date: dayOnly,
      startTime: draft.startTime,
      endTime: draft.endTime,
      pricePerHour: draft.court.pricePerHour,
      totalPrice: draft.totalPrice,
      playersRequired: required,
      joinedPlayerIds: joinedIds,
      joinedPlayerNames: joinedNames,
      confirmedGuestCount: confirmedGuestCount,
      status: initialStatus,
      createdAt: now,
      updatedAt: now,
    );

    // Group thread is created best-effort with the host pre-added.
    // A chat-thread write failure must never roll back a successful
    // match create — the next join / leave / chat-open will
    // re-create the thread because the writes are idempotent.
    _chatService.createOrUpdateGroupThreadForMatch(created).catchError((_) {});

    return created;
  }

  /// Atomic join. Returns the post-join match.
  ///
  /// Throws:
  ///   * `StateError('match-not-found')` — doc deleted server-side.
  ///   * `StateError('match-cancelled')` — host cancelled.
  ///   * `StateError('match-full')` — capacity reached before this
  ///     user's transaction got there.
  ///   * `StateError('host-cannot-join')` — host tried to join own
  ///     match.
  ///   * `StateError('already-joined')` — uid already in the list.
  Future<OpenMatch> joinOpenMatch({
    required OpenMatch match,
    required AppUser user,
  }) async {
    // Personal schedule guard. Runs OUTSIDE the join transaction
    // because the conflict queries hit collections that the
    // transaction doesn't read — and we don't want this single
    // network round-trip to bloat into a transactional read.
    // `excludeMatchId` keeps the user's own already-joined entries
    // for the same match from being a false positive (defence-in-
    // depth — the join transaction also bails on `already-joined`).
    await _conflicts.assertNoUserConflict(
      userId: user.uid,
      date: match.date,
      startTime: match.startTime,
      endTime: match.endTime,
      excludeMatchId: match.id,
    );

    final ref = _matches.doc(match.id);
    final updated = await _db.runTransaction<OpenMatch>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw StateError('match-not-found');
      }
      final current = OpenMatch.fromDoc(snap);
      if (current.isCancelled) {
        throw StateError('match-cancelled');
      }
      if (current.isHost(user.uid)) {
        throw StateError('host-cannot-join');
      }
      if (current.hasJoined(user.uid)) {
        throw StateError('already-joined');
      }
      // Capacity check uses the effective count so a host who claimed
      // "5 confirmed" on a 6-required match still has exactly 1 real
      // spot left for a remote joiner — not 5.
      if (current.effectiveJoinedCount >= current.playersRequired) {
        throw StateError('match-full');
      }

      final newIds = [...current.joinedPlayerIds, user.uid];
      final newNames = [...current.joinedPlayerNames, user.displayName];
      final newEffective = newIds.length + current.confirmedGuestCount;
      final newStatus = newEffective >= current.playersRequired
          ? OpenMatch.statusFull
          : OpenMatch.statusOpen;

      tx.update(ref, {
        'joinedPlayerIds': newIds,
        'joinedPlayerNames': newNames,
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return current.copyWith(
        joinedPlayerIds: newIds,
        joinedPlayerNames: newNames,
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    });

    // Add the joiner to the group chat thread so the chat list shows
    // up under their Messages → Groups tab immediately. Side-effect:
    // failures are swallowed so the join itself is never rolled back.
    _chatService
        .addUserToGroupThread(match: updated, user: user)
        .catchError((_) {});

    return updated;
  }

  /// Host-only cancel. Sets `status = cancelled` and fans out a
  /// notification to every real joined player except the host so
  /// their MyBookings rows flip to "Cancelled" the moment the host
  /// confirms cancellation.
  ///
  /// Wrapped in a transaction so we can read the doc + assert the
  /// caller is the host inside the same atomic operation — prevents
  /// a stale local snapshot from letting a non-host trip this code
  /// path. Notifications are fired AFTER the transaction commits;
  /// per-notification failures are swallowed so a missing target uid
  /// or rules blip never rolls back a successful cancel.
  ///
  /// Throws:
  ///   * `StateError('match-not-found')`
  ///   * `StateError('not-host')` — caller isn't the host of [match].
  ///   * `StateError('already-cancelled')` — no-op cancel attempts.
  Future<OpenMatch> cancelOpenMatch({
    required OpenMatch match,
    required AppUser host,
  }) async {
    final ref = _matches.doc(match.id);
    final result = await _db.runTransaction<OpenMatch>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw StateError('match-not-found');
      }
      final current = OpenMatch.fromDoc(snap);
      if (!current.isHost(host.uid)) {
        throw StateError('not-host');
      }
      if (current.isCancelled) {
        throw StateError('already-cancelled');
      }
      tx.update(ref, {
        'status': OpenMatch.statusCancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return current.copyWith(
        status: OpenMatch.statusCancelled,
        updatedAt: DateTime.now(),
      );
    });

    // Notify each real joined player except the host. Use the
    // post-transaction snapshot's uids — if the host raced a late
    // join, that uid is still in the list and gets the cancellation
    // notice.
    final body =
        '${result.hostName} cancelled the match at ${result.courtName}.';
    for (final uid in result.joinedPlayerIds) {
      if (uid == host.uid) continue;
      // Fire-and-forget per uid — a single failure shouldn't block
      // the others.
      _notifications
          .createNotification(
            userId: uid,
            title: 'Host cancelled the match',
            body: body,
            type: AppNotification.typeOpenMatchCancelled,
            targetType: AppNotification.targetMatch,
            targetId: result.id,
          )
          .catchError((_) {});
    }
    return result;
  }

  /// Joined-player leave. Removes the user from `joinedPlayerIds` +
  /// `joinedPlayerNames` at the same index (parallel arrays — never
  /// `arrayRemove` independently) and flips `status` back to `open`
  /// if effective count drops below capacity. Does not touch
  /// `playersRequired` or `confirmedGuestCount`.
  ///
  /// Wrapped in a Firestore transaction so a host racing a cancel
  /// can't both succeed against the same doc — the loser sees a
  /// fresh snapshot and bails cleanly.
  ///
  /// Notifies the host (and, best-effort, remaining joined players)
  /// after the transaction commits.
  ///
  /// Throws:
  ///   * `StateError('match-not-found')`
  ///   * `StateError('match-cancelled')` — already cancelled by host.
  ///   * `StateError('host-cannot-leave')` — host must use cancel.
  ///   * `StateError('not-joined')` — uid not in `joinedPlayerIds`.
  Future<OpenMatch> leaveOpenMatch({
    required OpenMatch match,
    required AppUser user,
  }) async {
    final ref = _matches.doc(match.id);
    final result = await _db.runTransaction<OpenMatch>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw StateError('match-not-found');
      }
      final current = OpenMatch.fromDoc(snap);
      if (current.isCancelled) {
        throw StateError('match-cancelled');
      }
      if (current.isHost(user.uid)) {
        throw StateError('host-cannot-leave');
      }
      final idx = current.joinedPlayerIds.indexOf(user.uid);
      if (idx < 0) {
        throw StateError('not-joined');
      }
      // Rebuild both arrays by index so they stay aligned. Using
      // arrayRemove on a primitive list would drop every matching
      // element from `joinedPlayerIds` but leave `joinedPlayerNames`
      // untouched — desync, hard to recover from.
      final newIds = [...current.joinedPlayerIds]..removeAt(idx);
      final newNames = [...current.joinedPlayerNames];
      if (idx < newNames.length) newNames.removeAt(idx);
      final newEffective = newIds.length + current.confirmedGuestCount;
      // Status flips back to open when a spot frees up. Cancelled
      // is impossible here because we bailed above; full → open is
      // the meaningful transition.
      final newStatus = newEffective >= current.playersRequired
          ? OpenMatch.statusFull
          : OpenMatch.statusOpen;
      tx.update(ref, {
        'joinedPlayerIds': newIds,
        'joinedPlayerNames': newNames,
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return current.copyWith(
        joinedPlayerIds: newIds,
        joinedPlayerNames: newNames,
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    });

    // Notify the host first — that's the load-bearing signal. The
    // remaining-joined fan-out is a best-effort courtesy ping.
    _notifications
        .createNotification(
          userId: result.hostUid,
          title: 'Player left your match',
          body: '${user.displayName} left your match at ${result.courtName}.',
          type: AppNotification.typeMatchLeft,
          targetType: AppNotification.targetMatch,
          targetId: result.id,
        )
        .catchError((_) {});
    for (final uid in result.joinedPlayerIds) {
      if (uid == result.hostUid) continue;
      _notifications
          .createNotification(
            userId: uid,
            title: 'A player left the match',
            body: '${user.displayName} left the match at ${result.courtName}.',
            type: AppNotification.typeMatchLeft,
            targetType: AppNotification.targetMatch,
            targetId: result.id,
          )
          .catchError((_) {});
    }

    // Drop the leaver from the group chat thread. Their existing
    // messages stay in history; they just won't see the thread in
    // their Groups tab anymore. Best-effort — a chat write failure
    // shouldn't roll back a successful leave.
    _chatService
        .removeUserFromGroupThread(match: result, userId: user.uid)
        .catchError((_) {});

    return result;
  }
}
