import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/id_verification.dart';

/// Tiny privileged surface for an in-app moderator workflow.
///
/// Gating is intentionally minimal:
///   * Hardcoded list of allow-listed admin emails ([_adminEmails]).
///   * UI gate (drawer + admin pages) only renders for those emails.
///   * Server-side enforcement is deferred to a Firestore rules pass
///     and a Cloud Function check — this service does not pretend to
///     authorise its own writes; it just makes the writes the
///     reviewer needs.
///
/// To make a new account an admin, add their email here and they
/// will see the "ID Verification Reviews" entry in the side drawer
/// the next time they open the app.
class AdminService {
  /// Admin allow-list. Sign in with one of these emails to see the
  /// admin entry in the drawer + the moderator surfaces.
  static const Set<String> _adminEmails = {'kaleakshay3219@gmail.com'};

  final FirebaseFirestore _db;

  AdminService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Whether [user] is on the static admin allow-list.
  /// Comparison is email-only and case-insensitive.
  bool isAdmin(AppUser? user) {
    final email = user?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return false;
    return _adminEmails.any((e) => e.toLowerCase() == email);
  }

  /// Streams every user with `idVerification.status == 'submitted'`.
  /// Returns an [AppUser] per row so the admin UI can show the
  /// reviewer all the context (name, avatar, document URLs).
  Stream<List<AppUser>> streamPendingIdVerifications() {
    // Single-field where so no composite index is needed.
    return _users
        .where('idVerification.status', isEqualTo: 'submitted')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => AppUser.fromMap({...doc.data(), 'uid': doc.id}))
              .toList();
        });
  }

  /// Flip an existing ID-verification record to a terminal status.
  /// [reviewerNote] is optional but persisted when present.
  Future<void> setVerificationStatus({
    required String userId,
    required IdVerificationStatus status,
    String? reviewerNote,
  }) async {
    if (status == IdVerificationStatus.submitted) {
      throw ArgumentError(
        'setVerificationStatus only takes verified / rejected. '
        'submitted is the initial state and is set by the user.',
      );
    }
    final payload = <String, dynamic>{
      'idVerification.status': status.storageKey,
      'idVerification.reviewedAt': FieldValue.serverTimestamp(),
    };
    if (reviewerNote != null && reviewerNote.trim().isNotEmpty) {
      payload['idVerification.reviewerNote'] = reviewerNote.trim();
    }
    await _users.doc(userId).update(payload);
  }
}
