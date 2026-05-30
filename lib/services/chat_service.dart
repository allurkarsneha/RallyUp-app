import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../models/open_match.dart';

/// Source of truth for both direct (1-to-1) and open-match group
/// messaging. Both shapes live in the same `threads/{threadId}`
/// collection so the messages subcollection layout, send/read APIs,
/// and `lastMessage` previews stay symmetrical between them.
///
/// Firestore layout:
///
/// ```
/// threads/{threadId}
///   type:           'direct' | 'group'   (missing → 'direct' on legacy docs)
///   participantIds: [uidA, uidB, …]
///   lastMessage:    string?
///   lastMessageAt:  Timestamp?
///   lastSenderId:   string?
///   createdAt:      Timestamp
///   updatedAt:      Timestamp
///   lastReadAtByUser: { uid: Timestamp }
///   // Group-only:
///   matchId:        string
///   title:          string   "<Sport> at <Court>"
///   imageUrl:       string
///   sportType:      string
///   courtName:      string
///
/// threads/{threadId}/messages/{messageId}
///   senderUid: string
///   senderName: string?  (group-only; lets bubbles label the sender
///                         without a follow-up users/{uid} read)
///   text:      string
///   sentAt:    Timestamp
/// ```
///
/// Direct thread IDs are deterministic: the two uids are sorted and
/// joined with `_`. Group thread IDs are deterministic too: the
/// match id prefixed with `match_`. Either form lets the caller jump
/// straight to a doc by id with no `where(...)` lookup.
class ChatService {
  final FirebaseFirestore _db;

  ChatService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _threads =>
      _db.collection('threads');

  // ─────────────────────────────────────────────────────────────
  // Direct threads
  // ─────────────────────────────────────────────────────────────

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
        'type': ChatThread.typeDirect,
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

  // ─────────────────────────────────────────────────────────────
  // Group (open-match) threads
  // ─────────────────────────────────────────────────────────────

  /// Deterministic id for the open-match group thread. Prefixed with
  /// `match_` so collisions with a direct thread (`uidA_uidB`) are
  /// impossible — uids don't contain underscores, but a strict prefix
  /// is the load-bearing guarantee.
  String groupThreadIdForMatch(String matchId) => 'match_$matchId';

  /// Create the group thread for [match] if it doesn't exist yet, or
  /// refresh its metadata + participant list. Safe to call on every
  /// match create / join / leave because the write is `merge: true`
  /// with a deterministic id.
  ///
  /// Participants:
  ///   * First call (thread doesn't exist) → seed with the literal
  ///     uids from `match.joinedPlayerIds`.
  ///   * Subsequent calls (e.g. a stale local OpenMatch snapshot
  ///     re-opens the chat) → `arrayUnion` so we never drop a
  ///     player who joined after the local snapshot was built.
  ///     Removals are still authoritative through
  ///     [removeUserFromGroupThread] only.
  ///
  /// `lastMessage*` fields are written `null`-merge so a freshly
  /// created thread shows "no messages yet" rather than inheriting
  /// stale preview text from a sibling doc.
  Future<void> createOrUpdateGroupThreadForMatch(OpenMatch match) async {
    final id = groupThreadIdForMatch(match.id);
    final ref = _threads.doc(id);
    final snap = await ref.get();
    final title = '${match.sportType} at ${match.courtName}'.trim();
    final imageUrl = match.courtImageUrl;
    final now = FieldValue.serverTimestamp();

    final base = <String, dynamic>{
      'type': ChatThread.typeGroup,
      'matchId': match.id,
      'title': title,
      'imageUrl': imageUrl,
      'sportType': match.sportType,
      'courtName': match.courtName,
      'updatedAt': now,
    };
    if (!snap.exists) {
      // First-ever write: seed the participants list directly with
      // whatever the OpenMatch carries (just the host on first
      // create, host + invited joiners later).
      base['participantIds'] = List<String>.from(match.joinedPlayerIds);
      base['lastMessage'] = null;
      base['lastMessageAt'] = null;
      base['lastSenderId'] = null;
      base['createdAt'] = now;
    } else {
      // Existing thread: union in any uids the local snapshot
      // knows about. Crucially never replace the array — a stale
      // local snapshot must not silently kick remote joiners.
      base['participantIds'] = FieldValue.arrayUnion(
        List<String>.from(match.joinedPlayerIds),
      );
    }
    await ref.set(base, SetOptions(merge: true));
  }

  /// Add [user] to the group thread for [match]. Uses `arrayUnion`
  /// so repeated calls (e.g. join → leave → join again) don't
  /// duplicate the uid. Title/court snapshots are refreshed at the
  /// same time in case the host swapped the court between the
  /// thread's last update and now.
  Future<void> addUserToGroupThread({
    required OpenMatch match,
    required AppUser user,
  }) async {
    final id = groupThreadIdForMatch(match.id);
    final ref = _threads.doc(id);
    final now = FieldValue.serverTimestamp();
    final title = '${match.sportType} at ${match.courtName}'.trim();
    await ref.set({
      'type': ChatThread.typeGroup,
      'matchId': match.id,
      'title': title,
      'imageUrl': match.courtImageUrl,
      'sportType': match.sportType,
      'courtName': match.courtName,
      'participantIds': FieldValue.arrayUnion([user.uid]),
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  /// Remove [userId] from the group thread for [match] (e.g. when the
  /// user leaves). The doc + history is preserved so other
  /// participants can still scroll the chat.
  Future<void> removeUserFromGroupThread({
    required OpenMatch match,
    required String userId,
  }) async {
    final id = groupThreadIdForMatch(match.id);
    final ref = _threads.doc(id);
    await ref.set({
      'participantIds': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Streams every group thread the user participates in, with the
  /// same client-side sort (`lastMessageAt` desc, falling back to
  /// `updatedAt`) the direct-threads stream uses. Filtering on
  /// `type == 'group'` is done client-side so we don't have to ship
  /// a composite index for `participantIds arrayContains + type`.
  Stream<List<ChatThread>> streamGroupThreadsForUser(String uid) {
    return _threads.where('participantIds', arrayContains: uid).snapshots().map(
      (snap) {
        final threads = snap.docs
            .map((doc) => ChatThread.fromDoc(doc))
            .where((t) => t.isGroup)
            .toList();
        threads.sort((a, b) {
          final aT = a.lastMessageAt ?? a.updatedAt;
          final bT = b.lastMessageAt ?? b.updatedAt;
          return bT.compareTo(aT);
        });
        return threads;
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Messages (shared by direct + group threads)
  // ─────────────────────────────────────────────────────────────

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
          (snap) => snap.docs.map((doc) => ChatMessage.fromDoc(doc)).toList(),
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
  ///
  /// [senderName] is optional and used by group-chat bubbles so we
  /// don't have to refetch the sender's display name for every message.
  /// Direct chat callers can leave it null — direct bubbles look up
  /// the other user once at thread-open time.
  Future<void> sendMessage({
    required String threadId,
    required String senderUid,
    required String text,
    String? senderName,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final threadRef = _threads.doc(threadId);
    final messageRef = threadRef.collection('messages').doc();
    final now = FieldValue.serverTimestamp();

    final messagePayload = <String, dynamic>{
      'senderUid': senderUid,
      'text': trimmed,
      'sentAt': now,
    };
    if (senderName != null && senderName.isNotEmpty) {
      messagePayload['senderName'] = senderName;
    }

    final batch = _db.batch();
    batch.set(messageRef, messagePayload);
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
    batch.set(threadRef, {
      'lastMessage': trimmed,
      'lastMessageAt': now,
      'lastSenderId': senderUid,
      'updatedAt': now,
      'lastReadAtByUser': {senderUid: now},
    }, SetOptions(merge: true));
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
    await _threads.doc(threadId).set({
      'lastReadAtByUser': {uid: FieldValue.serverTimestamp()},
    }, SetOptions(merge: true));
  }

  /// Read a thread by id. Used by the group chat page (and any code
  /// that needs to render the title/court snapshot for an existing
  /// thread without subscribing to the stream).
  Future<ChatThread?> getThread(String threadId) async {
    final snap = await _threads.doc(threadId).get();
    if (!snap.exists) return null;
    return ChatThread.fromDoc(snap);
  }

  // ─────────────────────────────────────────────────────────────
  // Thread streams (per shape)
  // ─────────────────────────────────────────────────────────────

  /// Streams every DIRECT thread the user participates in,
  /// newest-activity first. Group threads are filtered OUT client-side
  /// so the legacy Messages tab continues to show 1-to-1 chats only.
  /// Threads with no messages yet (just created via
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
    return _threads.where('participantIds', arrayContains: uid).snapshots().map(
      (snap) {
        final threads = snap.docs
            .map((doc) => ChatThread.fromDoc(doc))
            .where((t) => t.isDirect)
            .toList();
        threads.sort((a, b) {
          final aT = a.lastMessageAt ?? a.updatedAt;
          final bT = b.lastMessageAt ?? b.updatedAt;
          return bT.compareTo(aT);
        });
        return threads;
      },
    );
  }
}
