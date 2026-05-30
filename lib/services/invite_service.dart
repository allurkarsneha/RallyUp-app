import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/invite.dart';
import '../models/open_match.dart';
import 'chat_service.dart';
import 'notification_service.dart';
import 'open_match_service.dart';

/// Reads + writes `invites/{id}` docs.
///
/// Each invite ties one host's open match to one specific invitee.
/// Capacity, host identity, and duplicate-pending-invite guards are
/// enforced server-authoritatively via Firestore transactions or
/// pre-checks so a stale local snapshot can't slip a bad invite past
/// the rules.
///
/// Notifications are written as a best-effort side effect after the
/// primary mutation succeeds — a notification-write failure must
/// never roll back the underlying create/accept/decline.
class InviteService {
  final FirebaseFirestore _db;
  final NotificationService _notifications;
  final OpenMatchService _openMatchService;
  final ChatService _chatService;

  InviteService({
    FirebaseFirestore? db,
    NotificationService? notifications,
    OpenMatchService? openMatchService,
    ChatService? chatService,
  }) : _db = db ?? FirebaseFirestore.instance,
       _notifications = notifications ?? NotificationService(),
       _openMatchService = openMatchService ?? OpenMatchService(),
       _chatService = chatService ?? ChatService();

  CollectionReference<Map<String, dynamic>> get _invites =>
      _db.collection('invites');

  // ─────────────────────────────────────────────────────────────
  // Reads
  // ─────────────────────────────────────────────────────────────

  /// Streams every invite [userId] sent. Newest first. Sorted
  /// client-side so we don't ship a composite index for
  /// `fromUserId + createdAt`.
  Stream<List<Invite>> streamSentInvites(String userId) {
    return _invites.where('fromUserId', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final list = snap.docs.map((doc) => Invite.fromDoc(doc)).toList();
      list.sort((a, b) {
        final aT = a.createdAt ?? DateTime.now();
        final bT = b.createdAt ?? DateTime.now();
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  /// Streams every invite [userId] received. Newest first.
  Stream<List<Invite>> streamReceivedInvites(String userId) {
    return _invites.where('toUserId', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final list = snap.docs.map((doc) => Invite.fromDoc(doc)).toList();
      list.sort((a, b) {
        final aT = a.createdAt ?? DateTime.now();
        final bT = b.createdAt ?? DateTime.now();
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  /// Streams pending invites for [matchId]. Used by InviteToMatchPage
  /// to surface "this player already has a pending invite" so the
  /// host doesn't double-invite.
  Stream<List<Invite>> streamPendingInvitesForMatch(String matchId) {
    return _invites
        .where('matchId', isEqualTo: matchId)
        .where('status', isEqualTo: Invite.statusPending)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Invite.fromDoc(doc)).toList());
  }

  Future<Invite?> getInvite(String inviteId) async {
    final snap = await _invites.doc(inviteId).get();
    if (!snap.exists) return null;
    return Invite.fromDoc(snap);
  }

  // ─────────────────────────────────────────────────────────────
  // Create
  // ─────────────────────────────────────────────────────────────

  /// Create a new pending invite from [fromUser] to [toUser] for
  /// [match]. Guards (all server-checked against the live match doc
  /// inside the transaction):
  ///   * `fromUser` must be the host of [match].
  ///   * `match` must not be cancelled or full.
  ///   * `toUser` cannot be the host.
  ///   * `toUser` cannot already be in `joinedPlayerIds`.
  ///   * No existing pending/accepted invite for the same `matchId +
  ///     toUserId` pair.
  ///
  /// Throws:
  ///   * `StateError('match-not-found')`
  ///   * `StateError('not-host')`
  ///   * `StateError('match-cancelled')`
  ///   * `StateError('match-full')`
  ///   * `StateError('invitee-is-host')`
  ///   * `StateError('invitee-already-joined')`
  ///   * `StateError('duplicate-invite')`
  Future<Invite> createInvite({
    required AppUser fromUser,
    required AppUser toUser,
    required OpenMatch match,
  }) async {
    // Duplicate-pending or already-accepted check runs OUTSIDE the
    // transaction because Firestore transactions only see docs they
    // explicitly `tx.get`, and a `where(...)` query can't run inside.
    // Doing it pre-flight is safe because the transaction's accept
    // step also re-verifies the match state, so the worst case is
    // a same-millisecond race producing two pending invites — UI
    // rule keeps both visible until one resolves.
    final dupSnap = await _invites
        .where('matchId', isEqualTo: match.id)
        .where('toUserId', isEqualTo: toUser.uid)
        .get();
    final hasDuplicate = dupSnap.docs.any((d) {
      final inv = Invite.fromDoc(d);
      return inv.isPending || inv.isAccepted;
    });
    if (hasDuplicate) {
      throw StateError('duplicate-invite');
    }

    final newDoc = _invites.doc();
    final invite = await _db.runTransaction<Invite>((tx) async {
      final ref = _db.collection('open_matches').doc(match.id);
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw StateError('match-not-found');
      }
      final current = OpenMatch.fromDoc(snap);
      if (!current.isHost(fromUser.uid)) {
        throw StateError('not-host');
      }
      if (current.isCancelled) {
        throw StateError('match-cancelled');
      }
      if (current.isFull ||
          current.effectiveJoinedCount >= current.playersRequired) {
        throw StateError('match-full');
      }
      if (current.isHost(toUser.uid)) {
        throw StateError('invitee-is-host');
      }
      if (current.hasJoined(toUser.uid)) {
        throw StateError('invitee-already-joined');
      }

      final payload = {
        'matchId': current.id,
        'fromUserId': fromUser.uid,
        'fromUserName': fromUser.displayName,
        'fromUserInitials': fromUser.initials,
        'fromUserPhotoUrl': fromUser.photoUrl,
        'fromUserAvatarId': fromUser.avatarId,
        'toUserId': toUser.uid,
        'toUserName': toUser.displayName,
        'toUserInitials': toUser.initials,
        'toUserPhotoUrl': toUser.photoUrl,
        'toUserAvatarId': toUser.avatarId,
        'courtId': current.courtId,
        'courtName': current.courtName,
        'courtAddress': current.courtAddress,
        'courtImageUrl': current.courtImageUrl,
        'sportType': current.sportType,
        'date': Timestamp.fromDate(current.date),
        'startTime': current.startTime,
        'endTime': current.endTime,
        'playersRequired': current.playersRequired,
        'effectiveJoinedCountAtSend': current.effectiveJoinedCount,
        'status': Invite.statusPending,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      tx.set(newDoc, payload);

      return Invite(
        id: newDoc.id,
        matchId: current.id,
        fromUserId: fromUser.uid,
        fromUserName: fromUser.displayName,
        fromUserInitials: fromUser.initials,
        fromUserPhotoUrl: fromUser.photoUrl,
        fromUserAvatarId: fromUser.avatarId,
        toUserId: toUser.uid,
        toUserName: toUser.displayName,
        toUserInitials: toUser.initials,
        toUserPhotoUrl: toUser.photoUrl,
        toUserAvatarId: toUser.avatarId,
        courtId: current.courtId,
        courtName: current.courtName,
        courtAddress: current.courtAddress,
        courtImageUrl: current.courtImageUrl,
        sportType: current.sportType,
        date: current.date,
        startTime: current.startTime,
        endTime: current.endTime,
        playersRequired: current.playersRequired,
        effectiveJoinedCountAtSend: current.effectiveJoinedCount,
        status: Invite.statusPending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    _notifications
        .createNotification(
          userId: toUser.uid,
          title: 'You were invited to a match',
          body:
              '${fromUser.displayName} invited you to '
              '${invite.sportType} at ${invite.courtName}.',
          type: AppNotification.typeInviteReceived,
          targetType: AppNotification.targetInvite,
          targetId: invite.id,
        )
        .catchError((_) {});

    return invite;
  }

  // ─────────────────────────────────────────────────────────────
  // Accept
  // ─────────────────────────────────────────────────────────────

  /// Accept an invite. Joins [user] to the underlying open match via
  /// [OpenMatchService.joinOpenMatch] (capacity / duplicate / host
  /// guards run there in a transaction), marks the invite accepted,
  /// adds the user to the group thread, and notifies the host.
  ///
  /// Returns the post-join [OpenMatch] snapshot so the caller can
  /// push MatchJoinedPage with the right state.
  ///
  /// Throws:
  ///   * `StateError('invite-not-found')`
  ///   * `StateError('not-invitee')`
  ///   * `StateError('invite-not-pending')`
  ///   * any `StateError` from `joinOpenMatch` (match-not-found,
  ///     match-cancelled, match-full, already-joined, host-cannot-join)
  Future<OpenMatch> acceptInvite({
    required Invite invite,
    required AppUser user,
  }) async {
    if (invite.toUserId != user.uid) {
      throw StateError('not-invitee');
    }
    // Re-read the invite inside the transaction-equivalent path so a
    // stale local "pending" snapshot can't double-accept.
    final fresh = await getInvite(invite.id);
    if (fresh == null) {
      throw StateError('invite-not-found');
    }
    if (!fresh.isPending) {
      throw StateError('invite-not-pending');
    }

    final match = await _openMatchService.getOpenMatch(fresh.matchId);
    if (match == null) {
      throw StateError('match-not-found');
    }

    final updated = await _openMatchService.joinOpenMatch(
      match: match,
      user: user,
    );

    await _invites.doc(fresh.id).set({
      'status': Invite.statusAccepted,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Group-thread membership is also written inside
    // `OpenMatchService.joinOpenMatch` so direct joins stay covered.
    // Doing it here too is idempotent (`arrayUnion`) and protects the
    // "host added invite-only player" path against a future change to
    // the join flow.
    _chatService
        .addUserToGroupThread(match: updated, user: user)
        .catchError((_) {});

    _notifications
        .createNotification(
          userId: fresh.fromUserId,
          title: 'Invite accepted',
          body:
              '${user.displayName} accepted your invite for '
              '${fresh.sportType} at ${fresh.courtName}.',
          type: AppNotification.typeInviteAccepted,
          targetType: AppNotification.targetMatch,
          targetId: fresh.matchId,
        )
        .catchError((_) {});

    return updated;
  }

  // ─────────────────────────────────────────────────────────────
  // Decline
  // ─────────────────────────────────────────────────────────────

  /// Decline an invite. Marks the invite `declined` and notifies the
  /// host. Match doc is not touched — the invitee was never on the
  /// player list to begin with.
  ///
  /// Throws:
  ///   * `StateError('invite-not-found')`
  ///   * `StateError('not-invitee')`
  ///   * `StateError('invite-not-pending')`
  Future<Invite> declineInvite({
    required Invite invite,
    required AppUser user,
  }) async {
    if (invite.toUserId != user.uid) {
      throw StateError('not-invitee');
    }
    final fresh = await getInvite(invite.id);
    if (fresh == null) {
      throw StateError('invite-not-found');
    }
    if (!fresh.isPending) {
      throw StateError('invite-not-pending');
    }

    await _invites.doc(fresh.id).set({
      'status': Invite.statusDeclined,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _notifications
        .createNotification(
          userId: fresh.fromUserId,
          title: 'Invite declined',
          body:
              '${user.displayName} declined your invite for '
              '${fresh.sportType} at ${fresh.courtName}.',
          type: AppNotification.typeInviteDeclined,
          targetType: AppNotification.targetInvite,
          targetId: fresh.id,
        )
        .catchError((_) {});

    return fresh.copyWith(
      status: Invite.statusDeclined,
      updatedAt: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bulk cancel (host cancelled the match)
  // ─────────────────────────────────────────────────────────────

  /// Flip every PENDING invite for [matchId] to `cancelled`. Called
  /// from MyBookings after a host successfully cancels a match. Does
  /// nothing to accepted/declined/cancelled invites — they're already
  /// in terminal states.
  ///
  /// Done as a `WriteBatch` so the invitees' invite lists update in
  /// a single Firestore snapshot.
  ///
  /// After the batch commits, each affected invitee receives a
  /// best-effort `typeOpenMatchCancelled` notification so the
  /// invite doesn't silently disappear from their Received tab.
  /// This is the partner notification to `OpenMatchService.cancelOpenMatch`'s
  /// fanout — that one notifies host + accepted players (everyone
  /// in `joinedPlayerIds`); this one notifies the pending invitees
  /// who were never in that list. There is no overlap, so no risk
  /// of double-notifying accepted players.
  Future<void> cancelInvitesForMatch(String matchId) async {
    final pending = await _invites
        .where('matchId', isEqualTo: matchId)
        .where('status', isEqualTo: Invite.statusPending)
        .get();
    if (pending.docs.isEmpty) return;
    final batch = _db.batch();
    final now = FieldValue.serverTimestamp();
    final cancelled = <Invite>[];
    for (final doc in pending.docs) {
      batch.update(doc.reference, {
        'status': Invite.statusCancelled,
        'updatedAt': now,
      });
      cancelled.add(Invite.fromDoc(doc));
    }
    await batch.commit();

    // Fanout invitee notifications. Best-effort per-invitee — a
    // single notification write failure must not roll back the
    // batched status flip. `targetType: targetMatch` mirrors the
    // host-cancel fanout in OpenMatchService.cancelOpenMatch so
    // NotificationsPage routes the tap into MatchDetailsPage when
    // the match still exists (or to a friendly SnackBar otherwise).
    for (final inv in cancelled) {
      _notifications
          .createNotification(
            userId: inv.toUserId,
            title: 'Match cancelled',
            body:
                '${inv.fromUserName} cancelled the '
                '${inv.sportType} match at ${inv.courtName} '
                "you were invited to. The invite is no longer active.",
            type: AppNotification.typeOpenMatchCancelled,
            targetType: AppNotification.targetMatch,
            targetId: inv.matchId,
          )
          .catchError((_) {});
    }
  }
}
