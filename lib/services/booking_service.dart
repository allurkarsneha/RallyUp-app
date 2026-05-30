import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/app_notification.dart';
import '../models/booking.dart';
import '../models/court.dart';
import 'notification_service.dart';
import 'schedule_conflict_service.dart';

/// Real Firestore-backed booking layer. Replaces the hard-coded maps
/// that the bookings screens used during the static-mock phase.
class BookingService {
  final FirebaseFirestore _db;
  final NotificationService _notifications;
  final ScheduleConflictService _conflicts;

  BookingService({
    FirebaseFirestore? db,
    NotificationService? notifications,
    ScheduleConflictService? conflicts,
  }) : _db = db ?? FirebaseFirestore.instance,
       _notifications = notifications ?? NotificationService(),
       _conflicts =
           conflicts ??
           ScheduleConflictService(db: db ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  /// Streams every booking belonging to [userId]. Sorting is
  /// client-side rather than via a Firestore `orderBy('date',
  /// descending: false)` so we don't pay for a composite index on
  /// `userId + date`. The dataset per user is small in scope (tens of
  /// bookings) and sort cost is negligible.
  Stream<List<Booking>> streamBookingsForUser(String userId) {
    return _bookings.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final bookings = snap.docs.map((doc) => Booking.fromDoc(doc)).toList();
      bookings.sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return a.startTime.compareTo(b.startTime);
      });
      return bookings;
    });
  }

  /// Persists a confirmed booking from the Book Court overlay flow.
  ///
  /// Snapshot fields (`courtName`, `courtAddress`, `courtImageUrl`,
  /// `pricePerHour`) are captured at booking time so the list / detail
  /// views can render without an extra `courts/{id}` read, and so a
  /// later rename or deactivation of the court doesn't retroactively
  /// rewrite history.
  ///
  /// For now `totalPrice` is just `court.pricePerHour` (every generated
  /// slot is 1 hour). When variable-length bookings ship, multiply by
  /// hours-in-slot here.
  Future<Booking> createBooking({
    required String userId,
    required Court court,
    required String sportType,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    // Schedule conflict guards run BEFORE the doc write so we never
    // persist a colliding booking. Distinct StateError messages
    // ('court-occupied' vs 'schedule-conflict') let the UI surface
    // the right SnackBar copy.
    await _conflicts.assertNoConflictForNewReservation(
      userId: userId,
      courtId: court.id,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );

    final ref = _bookings.doc();
    final now = DateTime.now();
    final courtImageUrl = court.imageUrls.isNotEmpty
        ? court.imageUrls.first
        : '';

    final payload = {
      'userId': userId,
      'courtId': court.id,
      'courtName': court.name,
      'courtAddress': court.address,
      'courtImageUrl': courtImageUrl,
      'sportType': sportType,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'pricePerHour': court.pricePerHour,
      'totalPrice': court.pricePerHour,
      'status': BookingStatus.confirmed,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await ref.set(payload);

    // Best-effort booking-confirmed in-app notification. We swallow
    // errors here on purpose — if Firestore rules / network blip
    // prevents the notification write, the booking itself already
    // succeeded and we don't want to roll it back. The bell badge
    // simply doesn't tick up for this event; the booking is still
    // visible in MyBookings / BookingConfirmedPage.
    _safeNotify(
      userId: userId,
      title: 'Court booked',
      body:
          '${court.name} is booked for ${_humanWhen(date, startTime, endTime)}.',
      type: AppNotification.typeBookingConfirmed,
      targetType: AppNotification.targetBooking,
      targetId: ref.id,
    );

    // Return a hydrated model so the caller can route straight into
    // BookingConfirmedPage. `createdAt`/`updatedAt` are best-effort
    // from the client clock — the next `streamBookingsForUser` snapshot
    // will replace them with the server values.
    return Booking(
      id: ref.id,
      userId: userId,
      courtId: court.id,
      courtName: court.name,
      courtAddress: court.address,
      courtImageUrl: courtImageUrl,
      sportType: sportType,
      date: date,
      startTime: startTime,
      endTime: endTime,
      pricePerHour: court.pricePerHour,
      totalPrice: court.pricePerHour,
      status: BookingStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Fetch a single booking by id. Returns `null` if the doc is
  /// missing or empty — callers (e.g. tapping a `booking_*`
  /// notification) should handle the null case gracefully.
  Future<Booking?> getBooking(String bookingId) async {
    final snap = await _bookings.doc(bookingId).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return Booking.fromMap({...data, 'id': snap.id});
  }

  /// Soft-cancel a booking. We don't delete the doc — keeping it
  /// makes "Past" bookings still visible and lets us reason about
  /// cancellations vs. attended sessions in a later phase.
  Future<void> cancelBooking(String bookingId) async {
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.cancelled,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Best-effort cancellation notification — same swallow-errors
    // rationale as createBooking. Read the doc back to get the court
    // name + userId for the notification body; if that read fails,
    // the cancellation still stands.
    try {
      final booking = await getBooking(bookingId);
      if (booking != null) {
        _safeNotify(
          userId: booking.userId,
          title: 'Booking cancelled',
          body: '${booking.courtName} was cancelled.',
          type: AppNotification.typeBookingCancelled,
          targetType: AppNotification.targetBooking,
          targetId: booking.id,
        );
      }
    } catch (e) {
      debugPrint('BookingService: cancellation notification skipped: $e');
    }
  }

  /// Fire-and-forget notification write. Swallows + debugPrints any
  /// error so a Firestore rules / network failure on the
  /// notifications collection can never cascade into a booking
  /// write/cancel failure.
  void _safeNotify({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? targetType,
    String? targetId,
  }) {
    _notifications
        .createNotification(
          userId: userId,
          title: title,
          body: body,
          type: type,
          targetType: targetType,
          targetId: targetId,
        )
        .catchError((e) {
          debugPrint('BookingService: notification write failed: $e');
        });
  }

  /// Human-readable "EEE, MMM d · 6:00 PM - 7:00 PM" for notification
  /// bodies. Standalone (not member of Booking) because we use it on
  /// the in-memory draft before the Booking object exists.
  String _humanWhen(DateTime date, String startTime, String endTime) {
    final d = DateFormat('EEE, MMM d').format(date);
    return '$d · $startTime - $endTime';
  }
}
