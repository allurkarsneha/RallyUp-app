import 'package:cloud_firestore/cloud_firestore.dart';

/// One message inside a thread. Lives under
/// `threads/{threadId}/messages/{messageId}`.
///
/// Intentionally narrow: sender + text + sentAt. Read receipts, delivery
/// statuses, media attachments, and reactions are explicitly deferred —
/// they belong to a later phase that also gates the unread-count UI in
/// the threads list.
///
/// [senderName] is an optional snapshot of the sender's display name,
/// captured at send time. Used by GROUP-chat bubbles so they can label
/// who said what without a `users/{uid}` lookup per message. Direct
/// chat doesn't need it — the other user is already resolved at
/// thread-open time — and older direct messages won't have written
/// the field, so it's a nullable `String?`.
class ChatMessage {
  final String id;
  final String senderUid;
  final String? senderName;
  final String text;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() => {
    'senderUid': senderUid,
    if (senderName != null) 'senderName': senderName,
    'text': text,
    'sentAt': Timestamp.fromDate(sentAt),
  };

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ChatMessage(
      id: doc.id,
      senderUid: (data['senderUid'] as String?) ?? '',
      senderName: data['senderName'] as String?,
      text: (data['text'] as String?) ?? '',
      // `serverTimestamp()` writes haven't resolved yet on the writing
      // client for the first frame after send — fall back to `now()` so
      // ordering stays sensible client-side until the server timestamp
      // round-trips.
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
