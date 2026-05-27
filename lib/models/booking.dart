import 'package:cloud_firestore/cloud_firestore.dart';

/// Status values stored on `bookings/{id}.status`. String constants
/// rather than an enum so a future "completed" or "rescheduled" value
/// added by a server-side process doesn't crash the client model.
class BookingStatus {
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';
}

/// A user's court booking. Stores a small snapshot of court fields
/// (`courtName`, `courtAddress`, `courtImageUrl`) so the bookings list
/// can render without a per-row `courts/{courtId}` round trip — and
/// without breaking if the court doc is later renamed or deleted.
class Booking {
  final String id;
  final String userId;
  final String courtId;
  final String courtName;
  final String courtAddress;
  /// First image from the court's `imageUrls` at booking time, captured
  /// for stable list/confirmation rendering. May be empty if the court
  /// had no images. Not on the originally-specified field list but
  /// required for the cards we already ship — see the BookingService
  /// note above `createBooking`.
  final String courtImageUrl;
  final String sportType;
  final DateTime date;
  /// 24-hour `HH:mm`, e.g. `"18:00"`. Display-side formatting (12-hour
  /// with AM/PM) is the caller's job — keeps Firestore values stable.
  final String startTime;
  final String endTime;
  final double pricePerHour;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.courtName,
    required this.courtAddress,
    required this.courtImageUrl,
    required this.sportType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;

  Booking copyWith({
    String? status,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id,
      userId: userId,
      courtId: courtId,
      courtName: courtName,
      courtAddress: courtAddress,
      courtImageUrl: courtImageUrl,
      sportType: sportType,
      date: date,
      startTime: startTime,
      endTime: endTime,
      pricePerHour: pricePerHour,
      totalPrice: totalPrice,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'courtId': courtId,
        'courtName': courtName,
        'courtAddress': courtAddress,
        'courtImageUrl': courtImageUrl,
        'sportType': sportType,
        'date': Timestamp.fromDate(date),
        'startTime': startTime,
        'endTime': endTime,
        'pricePerHour': pricePerHour,
        'totalPrice': totalPrice,
        'status': status,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      };

  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Booking.fromMap({...data, 'id': doc.id});
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: (map['id'] as String?) ?? '',
      userId: (map['userId'] as String?) ?? '',
      courtId: (map['courtId'] as String?) ?? '',
      courtName: (map['courtName'] as String?) ?? '',
      courtAddress: (map['courtAddress'] as String?) ?? '',
      courtImageUrl: (map['courtImageUrl'] as String?) ?? '',
      sportType: (map['sportType'] as String?) ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: (map['startTime'] as String?) ?? '',
      endTime: (map['endTime'] as String?) ?? '',
      pricePerHour: _parseDouble(map['pricePerHour']) ?? 0,
      totalPrice: _parseDouble(map['totalPrice']) ?? 0,
      // Default a missing/malformed status to `confirmed`; a write that
      // landed without a status is far more likely to be a transient
      // partial than a cancellation.
      status: (map['status'] as String?) ?? BookingStatus.confirmed,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static double? _parseDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }
}
