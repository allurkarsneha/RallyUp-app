import 'package:cloud_firestore/cloud_firestore.dart';

/// Writes feedback + user-report submissions to Firestore.
///
/// Layout:
///
/// ```
/// feedback/{id}
///   userId:    string?  (null when an anonymous user submits)
///   userEmail: string?
///   userName:  string?
///   category:  string   ("Technical issue", "Bug", "Feedback", ...)
///   message:   string
///   createdAt: Timestamp
///
/// reports/{id}
///   reporterId:        string
///   reporterName:      string
///   reportedUserId:    string
///   reportedUserName:  string
///   reason:            string
///   createdAt:         Timestamp
///   status:            "open" | "reviewed" | "dismissed"  (server set)
/// ```
///
/// Neither write blocks the UI. Errors propagate so the calling
/// screen can surface a SnackBar; nothing here swallows.
class FeedbackService {
  final FirebaseFirestore _db;

  FeedbackService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _feedback =>
      _db.collection('feedback');

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('reports');

  /// Append a feedback / suggestion / bug-report row.
  ///
  /// [message] is required and validated non-empty by the calling
  /// page; we re-validate here so a misbehaving caller can't push a
  /// blank row server-side. [category] defaults to the generic
  /// bucket if the caller didn't pick one.
  Future<void> submitFeedback({
    required String message,
    String category = 'Feedback',
    String? userId,
    String? userEmail,
    String? userName,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Feedback message cannot be empty.');
    }
    await _feedback.add({
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'category': category.trim().isEmpty ? 'Feedback' : category.trim(),
      'message': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Append a report-another-user row.
  ///
  /// Used from a player's profile or the chat header's "Report user"
  /// menu (no UI today; the service is wired so the menu can land in
  /// a future cleanup task). Reports start in `status: open` and a
  /// moderator workflow (out of scope) flips them later.
  Future<void> reportUser({
    required String reporterId,
    required String reporterName,
    required String reportedUserId,
    required String reportedUserName,
    required String reason,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw ArgumentError('Report reason cannot be empty.');
    }
    await _reports.add({
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'reason': trimmedReason,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
