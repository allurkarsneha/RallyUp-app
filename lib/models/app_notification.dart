import 'package:cloud_firestore/cloud_firestore.dart';

/// In-app notification record stored under `notifications/{id}`.
///
/// Per-event records (booking confirmed, booking cancelled, invite
/// received, ...) keyed by `userId`. This model only describes the
/// Firestore document — the push delivery path (FCM) reads the same
/// fields server-side in a later phase.
///
/// Shape decisions:
///
///   * `type` is a string rather than an enum so a server-side
///     process (Cloud Function, admin tool) can introduce a new type
///     without forcing a client model migration.
///   * `targetType` + `targetId` are deliberately untyped pointers.
///     The client decides at tap-time how to route based on
///     `targetType`. Avoids embedding entire object snapshots inside
///     each notification.
class AppNotification {
  static const String typeBookingConfirmed = 'booking_confirmed';
  static const String typeBookingCancelled = 'booking_cancelled';
  static const String typeInviteReceived = 'invite_received';
  static const String typeSystem = 'system';

  static const String targetBooking = 'booking';
  static const String targetInvite = 'invite';
  static const String targetMatch = 'match';

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? targetType;
  final String? targetId;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.targetType,
    required this.targetId,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      targetType: targetType,
      targetId: targetId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'targetType': targetType,
        'targetId': targetId,
        'isRead': isRead,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  factory AppNotification.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AppNotification.fromMap({...data, 'id': doc.id});
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: (map['id'] as String?) ?? '',
      userId: (map['userId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      type: (map['type'] as String?) ?? AppNotification.typeSystem,
      targetType: map['targetType'] as String?,
      targetId: map['targetId'] as String?,
      // Missing isRead → unread. Conservative: never accidentally
      // pre-mark a server-written notification as already seen.
      isRead: (map['isRead'] as bool?) ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
