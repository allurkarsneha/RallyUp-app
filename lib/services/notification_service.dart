import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

/// Reads + writes `notifications/{id}` docs.
///
/// All queries are `where('userId', isEqualTo: ...)` only — sorted
/// client-side. Avoids needing a composite `userId + createdAt`
/// index. Per-user notification volume stays small for the dataset
/// scope of this app (tens to low hundreds), so client-sort is fine.
class NotificationService {
  final FirebaseFirestore _db;

  NotificationService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  /// Newest-first stream of every notification belonging to [userId].
  /// Pending `createdAt` (serverTimestamp) values sort with `null`
  /// treated as "now" — so a freshly-written notification stays at
  /// the top until the server confirms its timestamp.
  Stream<List<AppNotification>> streamNotificationsForUser(String userId) {
    return _notifications.where('userId', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final list = snap.docs
          .map((doc) => AppNotification.fromDoc(doc))
          .toList();
      list.sort((a, b) {
        final aT = a.createdAt ?? DateTime.now();
        final bT = b.createdAt ?? DateTime.now();
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  /// Live count of unread notifications for [userId]. Pipes into the
  /// notification bell badge.
  Stream<int> streamUnreadCount(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Append one notification. Callers should fire-and-forget through
  /// try/catch so a Firestore rules / network blip never breaks the
  /// originating action (booking write, invite send, ...).
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? targetType,
    String? targetId,
  }) async {
    await _notifications.add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'targetType': targetType,
      'targetId': targetId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }

  /// Bulk mark-read. Uses a Firestore `WriteBatch` so the unread
  /// counter on the bell badge drops to zero in a single snapshot
  /// rather than flickering down one row at a time.
  Future<void> markAllAsRead(String userId) async {
    final unread = await _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    if (unread.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
