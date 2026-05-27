import 'package:cloud_firestore/cloud_firestore.dart';

/// One message inside a thread. Lives under
/// `threads/{threadId}/messages/{messageId}`.
///
/// Intentionally narrow: sender + text + sentAt. Read receipts, delivery
/// statuses, media attachments, and reactions are explicitly deferred —
/// they belong to a later phase that also gates the unread-count UI in
/// the threads list.
class ChatMessage {
  final String id;
  final String senderUid;
  final String text;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.text,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() => {
        'senderUid': senderUid,
        'text': text,
        'sentAt': Timestamp.fromDate(sentAt),
      };

  factory ChatMessage.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ChatMessage(
      id: doc.id,
      senderUid: (data['senderUid'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      // `serverTimestamp()` writes haven't resolved yet on the writing
      // client for the first frame after send — fall back to `now()` so
      // ordering stays sensible client-side until the server timestamp
      // round-trips.
      sentAt:
          (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
