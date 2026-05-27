import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';
import '../models/chat_thread.dart';

/// Single source of truth for direct (1-to-1) messaging.
///
/// Firestore layout (no participant snapshots — profile data only lives in
/// `users/{uid}`; the chat layer points at it via uids):
///
/// ```
/// threads/{threadId}
///   participantIds: [uidA, uidB]
///   lastMessage:    string?
///   lastMessageAt:  Timestamp?
///   lastSenderId:   string?
///   createdAt:      Timestamp
///   updatedAt:      Timestamp
///
/// threads/{threadId}/messages/{messageId}
///   senderUid: string
///   text:      string
///   sentAt:    Timestamp
/// ```
///
/// Direct thread IDs are deterministic: the two uids are sorted and
/// joined with `_`. That makes "find or create the direct thread between
/// A and B" a single doc read by id — no `where('participantIds',
/// arrayContains: …)` query — and structurally prevents two parallel
/// docs from being created for the same pair.
class ChatService {
  final FirebaseFirestore _db;

  ChatService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _threads =>
      _db.collection('threads');

  /// Deterministic direct-thread id for two users. Sort + join with `_`
  /// so the order of arguments never matters.
  String directThreadId(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return ids.join('_');
  }

  /// Returns the existing thread id between [currentUid] and [otherUid],
  /// creating the parent doc on the first call. Idempotent — repeated
  /// calls return the same id and never overwrite metadata, because we
  /// use `SetOptions(merge: true)` on a payload that only fills missing
  /// fields the first time.
  Future<String> createOrGetDirectThread({
    required String currentUid,
    required String otherUid,
  }) async {
    final id = directThreadId(currentUid, otherUid);
    final ref = _threads.doc(id);
    final snap = await ref.get();
    if (!snap.exists) {
      final now = FieldValue.serverTimestamp();
      await ref.set({
        'participantIds': [currentUid, otherUid]..sort(),
        'lastMessage': null,
        'lastMessageAt': null,
        'lastSenderId': null,
        'createdAt': now,
        'updatedAt': now,
      });
    }
    return id;
  }

  /// Streams messages for a thread, oldest-first. The MessagePage uses
  /// `reverse: true` on the ListView and consumes this stream as-is —
  /// flipping the sort to descending would force every consumer to flip
  /// the list themselves, so ascending stays the canonical order.
  Stream<List<ChatMessage>> streamMessages(String threadId) {
    return _threads
        .doc(threadId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ChatMessage.fromDoc(doc)).toList(),
        );
  }

  /// Append one message and bump the parent thread's preview fields in
  /// the same batched write so the Messages list updates atomically with
  /// the new message. Empty/whitespace input is rejected up front so the
  /// "send" button can be wired to call this directly without an extra
  /// guard at the call site.
  ///
  /// The sender's own `lastReadAtByUser` entry is bumped to the same
  /// server timestamp as the message — that is the rule that keeps the
  /// thread "read" for the sender while leaving the receiver as unread.
  /// The receiver's read timestamp is NEVER written here; it only moves
  /// forward when the receiver opens the chat via [markThreadRead].
  Future<void> sendMessage({
    required String threadId,
    required String senderUid,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final threadRef = _threads.doc(threadId);
    final messageRef = threadRef.collection('messages').doc();
    final now = FieldValue.serverTimestamp();

    final batch = _db.batch();
    batch.set(messageRef, {
      'senderUid': senderUid,
      'text': trimmed,
      'sentAt': now,
    });
    // `update` would throw if the parent doc was somehow lost.
    // `set(merge)` is the safer fallback path that also (re)creates the
    // doc if it's missing — important because the messaging UI assumes
    // the parent exists once `createOrGetDirectThread` has been called,
    // but doesn't re-check on every send.
    //
    // For `lastReadAtByUser`, the nested-map shape `{ senderUid: now }`
    // combined with `merge: true` makes Firestore deep-merge — only the
    // sender's entry is touched, the receiver's existing entry (if any)
    // is preserved.
    batch.set(
      threadRef,
      {
        'lastMessage': trimmed,
        'lastMessageAt': now,
        'lastSenderId': senderUid,
        'updatedAt': now,
        'lastReadAtByUser': {senderUid: now},
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  /// Move [uid]'s read marker forward to "now". Idempotent and safe to
  /// call on every chat-open and on every incoming-message snapshot —
  /// Firestore deep-merges the nested `lastReadAtByUser` map so the
  /// other participant's read state is never overwritten.
  ///
  /// Uses `set(merge: true)` rather than `update(dot notation)` so a
  /// stale or missing parent doc (e.g. a thread that was just created
  /// but whose `createdAt`/`participantIds` write hasn't observably
  /// landed on this client yet) doesn't throw.
  Future<void> markThreadRead({
    required String threadId,
    required String uid,
  }) async {
    await _threads.doc(threadId).set(
      {
        'lastReadAtByUser': {uid: FieldValue.serverTimestamp()},
      },
      SetOptions(merge: true),
    );
  }

  /// Streams every thread the user participates in, newest-activity
  /// first. Threads with no messages yet (just created via
  /// `createOrGetDirectThread`) still appear at the top.
  ///
  /// Sorting is done client-side rather than via Firestore `orderBy` for
  /// two reasons:
  ///
  ///   1. Combining `where('participantIds', arrayContains: ...)` with
  ///      `orderBy('updatedAt', descending: true)` requires a composite
  ///      Firestore index. Without it the listener throws
  ///      `FAILED_PRECONDITION` — the user just sees an empty list and
  ///      no error, which is exactly the "User B never sees the thread"
  ///      symptom we hit.
  ///   2. `createOrGetDirectThread` writes `updatedAt` with
  ///      `FieldValue.serverTimestamp()`, which resolves to `null` on
  ///      the writing client for one round-trip. Server-side `orderBy`
  ///      filters out docs whose ordering field is null, hiding brand
  ///      new threads from the sender until the server confirms — also
  ///      part of the observed bug. Client-side sort treats null as
  ///      "send to bottom" (via fallback to `createdAt`) so the thread
  ///      stays visible immediately.
  Stream<List<ChatThread>> streamThreadsForUser(String uid) {
    return _threads
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final threads =
          snap.docs.map((doc) => ChatThread.fromDoc(doc)).toList();
      threads.sort((a, b) {
        final aT = a.lastMessageAt ?? a.updatedAt;
        final bT = b.lastMessageAt ?? b.updatedAt;
        return bT.compareTo(aT);
      });
      return threads;
    });
  }
}
