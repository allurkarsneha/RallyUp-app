import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';
import '../models/open_match.dart';
import '../utils/booking_slots.dart';
import 'schedule_conflict_service.dart';

/// Computes which generated [bookingSlots] are still available for
/// a given court on a given date, given the current confirmed
/// private bookings and non-cancelled open matches in Firestore.
///
/// Used by `BookCourtSheet` to hide occupied slots from the time
/// grid so a user can't pick a slot another booking/match already
/// owns. The Courts list card no longer surfaces an "N slots today"
/// badge — that UI was removed — so we only carry the per-court
/// slot list method now.
///
/// Occupancy rule, per spec:
///   * Confirmed private booking on that court → blocks the slot.
///   * Hosted open match on that court → blocks the slot, even
///     before any players join. Joining an existing open match
///     does NOT subtract another slot — the host's match is the
///     only reservation against the court.
///   * Cancelled bookings/matches do NOT block.
///   * "Today" hides any slot whose start time has already passed.
class CourtAvailabilityService {
  final FirebaseFirestore _db;

  CourtAvailabilityService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _matches =>
      _db.collection('open_matches');

  /// Returns the slots from the canonical [bookingSlots] list that
  /// are still bookable for [courtId] on [date]. Order matches
  /// [bookingSlots]; consumers should not re-sort.
  Future<List<BookingSlot>> availableSlotsFor({
    required String courtId,
    required DateTime date,
  }) async {
    final dayOnly = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dayOnly.isBefore(today)) return const [];

    // Fetch the per-court active set. Single-field where so no
    // composite index — small per-court active set is acceptable
    // client-side scan.
    final occupied = await _occupiedIntervalsForCourt(courtId);

    final result = <BookingSlot>[];
    for (final slot in bookingSlots) {
      final slotStart = _combine(dayOnly, slot.start);
      final slotEnd = _combine(dayOnly, slot.end);
      // Hide already-started slots when looking at today.
      if (dayOnly.isAtSameMomentAs(today) && !slotStart.isAfter(now)) {
        continue;
      }
      final blocked = occupied.any(
        (i) =>
            _isSameDay(i.date, dayOnly) &&
            ScheduleConflictService.intervalsOverlap(
              aStart: _combine(i.date, i.startTime),
              aEnd: _combine(i.date, i.endTime),
              bStart: slotStart,
              bEnd: slotEnd,
            ),
      );
      if (!blocked) result.add(slot);
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────
  // Internals
  // ─────────────────────────────────────────────────────────────

  Future<List<_OccupiedInterval>> _occupiedIntervalsForCourt(
    String courtId,
  ) async {
    final occupied = <_OccupiedInterval>[];

    final bookingsSnap = await _bookings
        .where('courtId', isEqualTo: courtId)
        .get();
    for (final doc in bookingsSnap.docs) {
      final b = Booking.fromDoc(doc);
      if (!b.isConfirmed) continue;
      occupied.add(
        _OccupiedInterval(
          date: b.date,
          startTime: b.startTime,
          endTime: b.endTime,
        ),
      );
    }

    final matchesSnap = await _matches
        .where('courtId', isEqualTo: courtId)
        .get();
    for (final doc in matchesSnap.docs) {
      final m = OpenMatch.fromDoc(doc);
      if (m.isCancelled) continue;
      occupied.add(
        _OccupiedInterval(
          date: m.date,
          startTime: m.startTime,
          endTime: m.endTime,
        ),
      );
    }
    return occupied;
  }

  static DateTime _combine(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Small interval record used during availability calculation. Not
/// exported — the caller never holds these directly.
class _OccupiedInterval {
  final DateTime date;
  final String startTime;
  final String endTime;
  const _OccupiedInterval({
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}
