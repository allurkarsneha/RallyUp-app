import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/id_verification.dart';
import '../models/signup_form_data.dart';
import '../models/user_location.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

enum AuthStatus {
  loading,
  unauthenticated,
  needsOnboarding,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  StreamSubscription<User?>? _authSub;
  AuthStatus _status = AuthStatus.loading;
  AppUser? _currentUser;
  String? _lastError;

  AuthProvider({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService {
    _authSub = _authService.authStateChanges.listen(_onAuthChange);
  }

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  String? get lastError => _lastError;

  Future<void> _onAuthChange(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // Mid-session safety: if we already have a valid user object for this
    // same uid, treat fetch failures or transient missing-doc reads as
    // "keep what we have". Without this, a network blip or a token refresh
    // that re-triggers this listener can null out _currentUser and make
    // every part of the UI fall back to "Welcome / U".
    final hadGoodUser = _currentUser != null &&
        _currentUser!.uid == firebaseUser.uid &&
        _status == AuthStatus.authenticated;

    try {
      final user = await _userService.getUser(firebaseUser.uid);
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else if (hadGoodUser) {
        // Doc missing this read but we have a valid user already — likely
        // a transient Firestore read or a write-in-flight. Keep the user.
      } else {
        _currentUser = null;
        _status = AuthStatus.needsOnboarding;
      }
    } catch (e) {
      _lastError = e.toString();
      if (hadGoodUser) {
        // Same reasoning — don't kick a signed-in user out on transient
        // errors. Stay authenticated with the last known user.
      } else {
        _currentUser = null;
        _status = AuthStatus.needsOnboarding;
      }
    }
    notifyListeners();
  }

  Future<void> completeOnboarding(SignupFormData formData) async {
    final fbUser = _authService.currentFirebaseUser;
    if (fbUser == null) {
      throw StateError('Cannot complete onboarding without an auth user.');
    }
    final now = DateTime.now();
    final firstName = formData.firstName.trim();
    final lastName = formData.lastName.trim();
    final sports = formData.selectedSports.toList();

    // Defensive check — if a doc already exists for this uid, the user is
    // re-entering the onboarding flow (e.g. a transient getUser failure
    // earlier flipped status to needsOnboarding). We must NOT call
    // `createUser` here because that does a full `doc.set()` which would
    // overwrite every existing field — wiping idVerification, location,
    // profileVisible, etc. server-side. Instead, partial-update only the
    // fields onboarding actually collects.
    final existing = await _userService.getUser(fbUser.uid);
    if (existing != null) {
      final displayName = AppUser.buildDisplayName(firstName, lastName);
      await _userService.updateFields(fbUser.uid, {
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'avatarId': formData.avatarId,
        'sports': sports,
      });
      _currentUser = existing.copyWith(
        firstName: firstName,
        lastName: lastName,
        avatarId: formData.avatarId,
        sports: sports,
        updatedAt: now,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return;
    }

    final user = AppUser(
      uid: fbUser.uid,
      email: fbUser.email,
      phone: fbUser.phoneNumber,
      firstName: firstName,
      lastName: lastName,
      avatarId: formData.avatarId,
      sports: sports,
      createdAt: now,
      updatedAt: now,
    );

    await _userService.createUser(user);
    _currentUser = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Persist editable profile fields (name + age + postal code) through the
  /// same Firestore path the rest of the app uses. Pass `null` for `age` or
  /// `postalCode` to clear them.
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required int? age,
    required String? postalCode,
  }) async {
    final user = _currentUser;
    if (user == null) return;

    final newFirstName = firstName.trim();
    final newLastName = lastName.trim();
    final newPostalCode = postalCode?.trim();
    final newDisplayName =
        AppUser.buildDisplayName(newFirstName, newLastName);
    final now = DateTime.now();

    await _userService.updateFields(user.uid, {
      'firstName': newFirstName,
      'lastName': newLastName,
      'displayName': newDisplayName,
      'age': age,
      'postalCode': newPostalCode,
    });

    // CRITICAL: preserve every field that updateProfile doesn't touch
    // (location, idVerification, profileVisible). Earlier this method
    // omitted those three and they silently defaulted to null/null/true
    // in the local AppUser, which is what caused ProfileSettings to
    // show "Not started" right after the user saved an unrelated edit
    // even though Firestore still had the record.
    _currentUser = AppUser(
      uid: user.uid,
      email: user.email,
      phone: user.phone,
      firstName: newFirstName,
      lastName: newLastName,
      displayName: newDisplayName,
      photoUrl: user.photoUrl,
      avatarId: user.avatarId,
      age: age,
      postalCode: newPostalCode,
      location: user.location,
      idVerification: user.idVerification,
      sports: user.sports,
      availability: user.availability,
      profileVisible: user.profileVisible,
      createdAt: user.createdAt,
      updatedAt: now,
    );
    notifyListeners();
  }

  Future<void> updateSports(List<String> sports) async {
    final user = _currentUser;
    if (user == null) return;
    await _userService.updateFields(user.uid, {'sports': sports});
    _currentUser = user.copyWith(sports: sports, updatedAt: DateTime.now());
    notifyListeners();
  }

  Future<void> updateAvailability(
    Map<String, AvailabilitySlot> availability,
  ) async {
    final user = _currentUser;
    if (user == null) return;
    final firestorePayload =
        availability.map((day, slot) => MapEntry(day, slot.toMap()));
    await _userService.updateFields(
      user.uid,
      {'availability': firestorePayload},
    );
    _currentUser =
        user.copyWith(availability: availability, updatedAt: DateTime.now());
    notifyListeners();
  }

  Future<void> updateAvatar(String? avatarId) async {
    final user = _currentUser;
    if (user == null) return;
    await _userService.updateFields(user.uid, {'avatarId': avatarId});
    _currentUser =
        user.copyWith(avatarId: avatarId, updatedAt: DateTime.now());
    notifyListeners();
  }

  /// Apply an uploaded profile photo URL. Clears `avatarId` so the photo
  /// wins cleanly in the UserAvatar priority chain (photoUrl > avatarId >
  /// initials). Callers should already have uploaded the bytes via
  /// `ImageUploadService.uploadProfilePhoto` and have a Cloudinary URL.
  Future<void> setProfilePhotoUrl(String url) async {
    final user = _currentUser;
    if (user == null) return;
    final now = DateTime.now();
    await _userService.updateFields(user.uid, {
      'photoUrl': url,
      'avatarId': null,
    });
    _currentUser = AppUser(
      uid: user.uid,
      email: user.email,
      phone: user.phone,
      firstName: user.firstName,
      lastName: user.lastName,
      photoUrl: url,
      avatarId: null,
      age: user.age,
      postalCode: user.postalCode,
      location: user.location,
      idVerification: user.idVerification,
      sports: user.sports,
      availability: user.availability,
      profileVisible: user.profileVisible,
      createdAt: user.createdAt,
      updatedAt: now,
    );
    notifyListeners();
  }

  /// Clear both the uploaded photo and the preset avatar, falling back to
  /// initials.
  Future<void> clearProfileImage() async {
    final user = _currentUser;
    if (user == null) return;
    final now = DateTime.now();
    await _userService.updateFields(user.uid, {
      'photoUrl': null,
      'avatarId': null,
    });
    _currentUser = AppUser(
      uid: user.uid,
      email: user.email,
      phone: user.phone,
      firstName: user.firstName,
      lastName: user.lastName,
      photoUrl: null,
      avatarId: null,
      age: user.age,
      postalCode: user.postalCode,
      location: user.location,
      idVerification: user.idVerification,
      sports: user.sports,
      availability: user.availability,
      profileVisible: user.profileVisible,
      createdAt: user.createdAt,
      updatedAt: now,
    );
    notifyListeners();
  }

  Future<void> updateProfileVisibility(bool visible) async {
    final user = _currentUser;
    if (user == null) return;
    await _userService.updateFields(user.uid, {'profileVisible': visible});
    _currentUser =
        user.copyWith(profileVisible: visible, updatedAt: DateTime.now());
    notifyListeners();
  }

  Future<void> updateLocation(UserLocation location) async {
    final user = _currentUser;
    if (user == null) return;
    await _userService.updateFields(user.uid, {'location': location.toMap()});
    _currentUser =
        user.copyWith(location: location, updatedAt: DateTime.now());
    notifyListeners();
  }

  /// Submit-for-review only. The caller has already uploaded the images and
  /// must pass a record with `status: IdVerificationStatus.submitted` and
  /// `submittedAt` set to now. Approval / rejection transitions are an
  /// admin-side concern for a later phase — this method intentionally
  /// rejects records with any other status to keep the contract explicit.
  Future<void> submitIdVerification(IdVerification record) async {
    final user = _currentUser;
    if (user == null) return;
    if (record.status != IdVerificationStatus.submitted) {
      throw ArgumentError(
        'submitIdVerification only accepts records with status=submitted. '
        'verified / rejected transitions belong to the admin flow.',
      );
    }
    await _userService.updateFields(
      user.uid,
      {'idVerification': record.toMap()},
    );
    _currentUser =
        user.copyWith(idVerification: record, updatedAt: DateTime.now());
    notifyListeners();
  }

  /// Deletes the Firebase Auth account, then (best-effort) the Firestore
  /// profile doc.
  ///
  /// Invariant — **state is only torn down once auth deletion has
  /// observably succeeded**:
  ///
  ///   * If `fbUser.delete()` throws (e.g. `requires-recent-login`,
  ///     `network-request-failed`), the function rethrows immediately
  ///     **without** touching `_currentUser` / `_status` / listeners. The
  ///     user remains signed in with the same profile they had before, so
  ///     the caller can show a snackbar and let them retry after
  ///     re-authenticating. The UI never enters a "fake signed-out" state.
  ///
  ///   * If `fbUser.delete()` succeeds, the auth account is gone
  ///     server-side. Only then do we clear local state synchronously and
  ///     notify listeners, so AuthGate repaints to SignupScreen on the
  ///     very next frame with no flash of "Your Profile" / "U" fallback
  ///     in between. The Firestore doc delete is best-effort after that —
  ///     a failure there just leaves an orphan that an admin job can reap;
  ///     it can no longer affect the user-facing UI.
  Future<void> deleteAccount() async {
    final fbUser = _authService.currentFirebaseUser;
    if (fbUser == null) return;
    final uid = fbUser.uid;

    // ① Server-side delete. If this throws, control returns to the caller
    //    with our local state untouched — the user is still signed in.
    await fbUser.delete();

    // ② Auth deletion confirmed → it is now safe (and required) to clear
    //    local state. Anything that runs below this line assumes the
    //    server-side account is gone.
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _lastError = null;
    notifyListeners();

    // ③ Best-effort Firestore cleanup. Failure here cannot put us back
    //    into a signed-in state; the user is already gone from auth.
    try {
      await _userService.deleteUser(uid);
    } catch (e) {
      debugPrint(
        'deleteAccount: auth user $uid deleted, but Firestore doc cleanup '
        'failed: $e. The user is effectively deleted; the orphan doc should '
        'be reaped by a server-side cleanup job in a later phase.',
      );
    }
  }

  /// Sign out and clear local state synchronously. We don't wait for the
  /// FirebaseAuth listener (`_onAuthChange`) to fire — that's an extra
  /// async hop where the UI can briefly render with stale state. Clearing
  /// here means by the time `await signOut()` returns, every widget that
  /// watches AuthProvider has already been told to switch to the
  /// unauthenticated branch.
  Future<void> signOut() async {
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _lastError = null;
    notifyListeners();
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
