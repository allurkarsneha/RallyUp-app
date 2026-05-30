import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';
import '../models/open_match.dart';

/// Checks two independent kinds of schedule conflict against the live
/// Firestore state, before a write goes through:
///
///   * **Court occupancy** — a physical court cannot host two
///     overlapping reservations. Active confirmed private bookings
///     and non-cancelled open matches on the same court both count.
///
///   * **User schedule** — a real user cannot be in two overlapping
///     active sessions, even at different courts. Active sources:
///     confirmed private bookings owned by them, open matches they
///     host, and open matches where their uid is in
///     `joinedPlayerIds`. Anonymous `confirmedGuestCount` guests are
///     intentionally NOT checked because they have no real uid.
///
/// The overlap rule is the canonical interval-overlap test:
///
/// ```dart
/// existingStart < newEnd && newStart < existingEnd
/// ```
///
/// String equality of `startTime`/`endTime` is NOT a substitute —
/// 6:00–7:00 PM and 6:30–7:30 PM are exact-equality miss but real
/// overlap.
///
/// Throws `StateError('schedule-conflict')` on detection. Callers
/// translate that into a user-friendly SnackBar message.
///
/// Queries are intentionally simple (`where('userId', ...)`,
/// `where('hostUid', ...)`, etc.) so we don't ship any new composite
/// indexes — overlap testing happens client-side after a small
/// per-user fetch.
class ScheduleConflictService {
  final FirebaseFirestore _db;

  ScheduleConflictService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _matches =>
      _db.collection('open_matches');

  // ─────────────────────────────────────────────────────────────
  // Pure helpers
  // ─────────────────────────────────────────────────────────────

  /// Build a wall-clock DateTime from `date` (midnight) + `HH:mm`.
  static DateTime _combine(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }

  /// Canonical `existingStart < newEnd && newStart < existingEnd`.
  /// Returns false when intervals only touch at endpoints
  /// (6–7 / 7–8 is allowed, by spec).
  static bool intervalsOverlap({
    required DateTime aStart,
    required DateTime aEnd,
    required DateTime bStart,
    required DateTime bEnd,
  }) {
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }

  /// Convenience wrapper for callers that have `(date, startStr,
  /// endStr)` pairs and want the same overlap test.
  static bool dayTimesOverlap({
    required DateTime aDate,
    required String aStart,
    required String aEnd,
    required DateTime bDate,
    required String bStart,
    required String bEnd,
  }) {
    return intervalsOverlap(
      aStart: _combine(aDate, aStart),
      aEnd: _combine(aDate, aEnd),
      bStart: _combine(bDate, bStart),
      bEnd: _combine(bDate, bEnd),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Court occupancy
  // ─────────────────────────────────────────────────────────────

  /// Returns true when [courtId] already has an active confirmed
  /// booking OR active non-cancelled open match overlapping the
  /// proposed window.
  ///
  /// `excludeBookingId` / `excludeMatchId` let callers skip the doc
  /// they're about to update — currently unused (we don't edit
  /// existing reservations) but they make the helper future-proof.
  Future<bool> isCourtOccupied({
    required String courtId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
    String? excludeMatchId,
  }) async {
    final newStart = _combine(date, startTime);
    final newEnd = _combine(date, endTime);

    // Confirmed bookings on this court. We don't combine `courtId +
    // date` into a composite index — the per-court active set is
    // small, so client filtering is fine here.
    final bookingsSnap = await _bookings
        .where('courtId', isEqualTo: courtId)
        .get();
    for (final doc in bookingsSnap.docs) {
      if (excludeBookingId != null && doc.id == excludeBookingId) continue;
      final b = Booking.fromDoc(doc);
      if (!b.isConfirmed) continue;
      if (!_isSameDay(b.date, date)) continue;
      if (intervalsOverlap(
        aStart: _combine(b.date, b.startTime),
        aEnd: _combine(b.date, b.endTime),
        bStart: newStart,
        bEnd: newEnd,
      )) {
        return true;
      }
    }

    // Non-cancelled open matches on this court.
    final matchesSnap = await _matches
        .where('courtId', isEqualTo: courtId)
        .get();
    for (final doc in matchesSnap.docs) {
      if (excludeMatchId != null && doc.id == excludeMatchId) continue;
      final m = OpenMatch.fromDoc(doc);
      if (m.isCancelled) continue;
      if (!_isSameDay(m.date, date)) continue;
      if (intervalsOverlap(
        aStart: _combine(m.date, m.startTime),
        aEnd: _combine(m.date, m.endTime),
        bStart: newStart,
        bEnd: newEnd,
      )) {
        return true;
      }
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // User schedule
  // ─────────────────────────────────────────────────────────────

  /// Returns true when [userId] already has another active session
  /// overlapping the proposed window: a confirmed private booking,
  /// a hosted open match, or an open match they joined.
  ///
  /// Each Firestore query is single-field-equality so no new
  /// composite indexes are introduced.
  Future<bool> hasUserConflict({
    required String userId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
    String? excludeMatchId,
  }) async {
    final newStart = _combine(date, startTime);
    final newEnd = _combine(date, endTime);

    // 1) confirmed bookings owned by this user
    final bookingsSnap = await _bookings
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in bookingsSnap.docs) {
      if (excludeBookingId != null && doc.id == excludeBookingId) continue;
      final b = Booking.fromDoc(doc);
      if (!b.isConfirmed) continue;
      if (!_isSameDay(b.date, date)) continue;
      if (intervalsOverlap(
        aStart: _combine(b.date, b.startTime),
        aEnd: _combine(b.date, b.endTime),
        bStart: newStart,
        bEnd: newEnd,
      )) {
        return true;
      }
    }

    // 2) hosted open matches
    final hostedSnap = await _matches.where('hostUid', isEqualTo: userId).get();
    for (final doc in hostedSnap.docs) {
      if (excludeMatchId != null && doc.id == excludeMatchId) continue;
      final m = OpenMatch.fromDoc(doc);
      if (m.isCancelled) continue;
      if (!_isSameDay(m.date, date)) continue;
      if (intervalsOverlap(
        aStart: _combine(m.date, m.startTime),
        aEnd: _combine(m.date, m.endTime),
        bStart: newStart,
        bEnd: newEnd,
      )) {
        return true;
      }
    }

    // 3) joined open matches — `arrayContains` on `joinedPlayerIds`
    //    is a single-index query, available by default. We still
    //    deduplicate against `excludeMatchId` so a host-also-joined
    //    record (which can't actually happen but is cheap to guard)
    //    doesn't false-positive.
    final joinedSnap = await _matches
        .where('joinedPlayerIds', arrayContains: userId)
        .get();
    for (final doc in joinedSnap.docs) {
      if (excludeMatchId != null && doc.id == excludeMatchId) continue;
      final m = OpenMatch.fromDoc(doc);
      if (m.isCancelled) continue;
      // Skip host-self entries (already covered by query 2).
      if (m.hostUid == userId) continue;
      if (!_isSameDay(m.date, date)) continue;
      if (intervalsOverlap(
        aStart: _combine(m.date, m.startTime),
        aEnd: _combine(m.date, m.endTime),
        bStart: newStart,
        bEnd: newEnd,
      )) {
        return true;
      }
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // High-level guards (throw on conflict)
  // ─────────────────────────────────────────────────────────────

  /// Combined pre-flight for a "new booking" or "new open match"
  /// flow. Runs the court-occupancy check then the user-schedule
  /// check. Throws `StateError` with a distinct message per kind
  /// so callers can produce the right SnackBar copy.
  Future<void> assertNoConflictForNewReservation({
    required String userId,
    required String courtId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    if (await isCourtOccupied(
      courtId: courtId,
      date: date,
      startTime: startTime,
      endTime: endTime,
    )) {
      throw StateError('court-occupied');
    }
    if (await hasUserConflict(
      userId: userId,
      date: date,
      startTime: startTime,
      endTime: endTime,
    )) {
      throw StateError('schedule-conflict');
    }
  }

  /// For "join an existing open match" and "accept invite". The
  /// court is already booked by the host's match — only the user's
  /// own schedule needs validating.
  Future<void> assertNoUserConflict({
    required String userId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeMatchId,
  }) async {
    if (await hasUserConflict(
      userId: userId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      excludeMatchId: excludeMatchId,
    )) {
      throw StateError('schedule-conflict');
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
