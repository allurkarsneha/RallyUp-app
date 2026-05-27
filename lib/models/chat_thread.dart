import 'package:cloud_firestore/cloud_firestore.dart';

/// A direct (1-to-1) chat thread between two users. Group chats are
/// intentionally out of scope for this phase — the data model already
/// supports >2 ids in `participantIds` so a future group implementation
/// won't require a migration, but the `directThreadId` helper assumes
/// exactly two participants.
class ChatThread {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Per-participant "last time this user opened the chat" timestamp.
  /// Keyed by uid. Used by [isUnreadFor] to decide whether the receiver
  /// has seen the most recent message. Pending `serverTimestamp()`
  /// writes resolve to `null` for one round-trip on the writing client,
  /// which is the same as "never read" — that's intentionally treated
  /// as unread so the indicator doesn't briefly flash off.
  final Map<String, DateTime> lastReadAtByUser;

  const ChatThread({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.createdAt,
    required this.updatedAt,
    this.lastReadAtByUser = const {},
  });

  /// Returns the participant uid that is NOT [currentUid], or `null` if
  /// the thread somehow only contains the current user. Useful for
  /// resolving "the other person" in 1-to-1 list rendering.
  String? otherParticipant(String currentUid) {
    for (final id in participantIds) {
      if (id != currentUid) return id;
    }
    return null;
  }

  /// Last time [uid] opened (or sent within) this thread. `null` if the
  /// user has never opened it.
  DateTime? lastReadAtFor(String uid) => lastReadAtByUser[uid];

  /// A thread is "unread" for [uid] when:
  ///   1. there is a most recent message at all
  ///   2. that message was sent by SOMEONE ELSE
  ///   3. [uid] either has never opened the thread, or last opened it
  ///      strictly before that message landed.
  ///
  /// "Strictly before" matters: a normal open-the-chat flow writes a
  /// fresh read timestamp at the moment of opening, which is always
  /// >= the latest message's timestamp, so the thread immediately
  /// becomes read.
  bool isUnreadFor(String uid) {
    final lastAt = lastMessageAt;
    if (lastAt == null) return false;
    if (lastSenderId == uid) return false;
    final readAt = lastReadAtByUser[uid];
    if (readAt == null) return true;
    return readAt.isBefore(lastAt);
  }

  factory ChatThread.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final ids = (data['participantIds'] as List<dynamic>?)
            ?.cast<String>() ??
        const <String>[];
    return ChatThread(
      id: doc.id,
      participantIds: ids,
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastSenderId: data['lastSenderId'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastReadAtByUser: _parseReadMap(data['lastReadAtByUser']),
    );
  }

  /// Defensive parser — the field is optional (older docs from the
  /// pre-unread phase don't have it) and we never want a malformed entry
  /// to crash thread rendering. Anything that isn't a Timestamp under a
  /// String key is ignored.
  static Map<String, DateTime> _parseReadMap(dynamic raw) {
    if (raw is! Map) return const {};
    final result = <String, DateTime>{};
    raw.forEach((key, value) {
      if (key is String && value is Timestamp) {
        result[key] = value.toDate();
      }
    });
    return result;
  }
}
