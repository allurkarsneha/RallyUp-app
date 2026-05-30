import 'package:cloud_firestore/cloud_firestore.dart';

/// One chat thread document under `threads/{threadId}`.
///
/// Two thread shapes are supported:
///   * [typeDirect] — 1-to-1 chat between two users. `participantIds`
///     has exactly two uids. This is the original shape — the
///     `directThreadId` helper assumes two participants and the
///     direct UI looks them up by hitting `users/{uid}`.
///   * [typeGroup] — open-match group thread. `participantIds` can
///     grow as players join the match. Group threads carry extra
///     snapshot fields (`matchId`, `title`, `imageUrl`, `sportType`,
///     `courtName`) so the threads list can render an avatar/title
///     row without a per-card open-match read.
///
/// Backward compatibility: docs written before the group split don't
/// have a `type` field. They're treated as [typeDirect] so the
/// existing MessagesPage keeps showing them.
class ChatThread {
  static const String typeDirect = 'direct';
  static const String typeGroup = 'group';

  final String id;
  final String type;
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

  /// Group-only metadata. `null` on direct threads.
  final String? matchId;
  final String? title;
  final String? imageUrl;
  final String? sportType;
  final String? courtName;

  const ChatThread({
    required this.id,
    required this.type,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.createdAt,
    required this.updatedAt,
    this.lastReadAtByUser = const {},
    this.matchId,
    this.title,
    this.imageUrl,
    this.sportType,
    this.courtName,
  });

  bool get isDirect => type == typeDirect;
  bool get isGroup => type == typeGroup;

  /// Returns the participant uid that is NOT [currentUid], or `null` if
  /// the thread somehow only contains the current user. Useful for
  /// resolving "the other person" in 1-to-1 list rendering.
  ///
  /// For group threads this is meaningless (there is no single
  /// "other"); callers should branch on [isGroup] before calling.
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

  factory ChatThread.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final ids =
        (data['participantIds'] as List<dynamic>?)?.cast<String>() ??
        const <String>[];
    // Missing `type` field on legacy docs → direct. New direct writes
    // include the type explicitly, but the absence of it must never
    // route an old direct thread into the groups list.
    final type = (data['type'] as String?) ?? typeDirect;
    return ChatThread(
      id: doc.id,
      type: type,
      participantIds: ids,
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastSenderId: data['lastSenderId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastReadAtByUser: _parseReadMap(data['lastReadAtByUser']),
      matchId: data['matchId'] as String?,
      title: data['title'] as String?,
      imageUrl: data['imageUrl'] as String?,
      sportType: data['sportType'] as String?,
      courtName: data['courtName'] as String?,
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
