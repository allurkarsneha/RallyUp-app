import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Client-side Firebase Cloud Messaging (FCM) wiring.
///
/// What this DOES:
///   * Requests notification permission (iOS prompts on first call;
///     Android 13+ shows a runtime permission).
///   * Reads the current device's FCM token and stores it under
///     `users/{uid}.fcmTokens` (array-union, so multiple devices per
///     user are supported without overwriting each other).
///   * Subscribes to token-refresh and onMessage streams for the
///     life of the app process; foreground messages are debug-printed
///     for now.
///
/// What this DOES NOT do (yet):
///   * Server-side push send. Background delivery from "a notification
///     doc was written" to "the user sees a banner" requires a trusted
///     sender — typically a Cloud Function that listens on
///     `notifications/{id}` create events and posts to FCM via the
///     Admin SDK. That sender + APNs key upload is out of scope for
///     this client-only phase.
///   * iOS production push routing. iOS requires an APNs auth key
///     uploaded in Firebase + an APNs entitlement on the build. On
///     simulator the token can be null and that's expected.
///
/// Errors are swallowed + debugPrinted. FCM availability shouldn't
/// block app startup or any user flow.
class PushNotificationService {
  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;

  PushNotificationService({
    FirebaseFirestore? db,
    FirebaseMessaging? messaging,
  })  : _db = db ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  bool _initialised = false;

  /// Called once per signed-in session (best-effort) after auth
  /// settles. Safe to call multiple times — `_initialised` makes
  /// repeat calls a no-op so we don't re-register listeners.
  Future<void> initForUser(String uid) async {
    if (_initialised) {
      // Re-register the token under this uid in case the user signed
      // out + signed in as someone else. Token retrieval is cheap and
      // we only write to Firestore when the token is non-null.
      await _storeTokenIfAvailable(uid);
      return;
    }
    _initialised = true;

    try {
      // Permission prompt (iOS always; Android 13+ runtime).
      // alert/badge/sound match Apple's defaults; criticalAlert &
      // provisional left at defaults so we don't claim entitlements
      // we don't have.
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await _storeTokenIfAvailable(uid);

      // Re-write on rotation. FCM rotates tokens periodically and
      // after app reinstalls; without this we'd drift off the
      // user's `fcmTokens` array.
      _messaging.onTokenRefresh.listen((token) async {
        await _writeToken(uid, token);
      }, onError: (e) {
        debugPrint('PushNotificationService: onTokenRefresh error: $e');
      });

      // Foreground delivery. For now we just log; once a server-side
      // sender exists, this is where we'd surface an in-app banner
      // or refresh the bell badge eagerly.
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint(
          'PushNotificationService: foreground message — '
          'title=${message.notification?.title}, '
          'body=${message.notification?.body}, '
          'data=${message.data}',
        );
      });

      // Cold-launch entry point: app opened via a notification tap
      // when it was terminated. We just log for now; routing by
      // notification type lands when the targetType→deep-link table
      // ships.
      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        debugPrint(
          'PushNotificationService: launched from notification — '
          'data=${initial.data}',
        );
      }

      // Warm-launch entry point: app opened via notification tap
      // from background.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint(
          'PushNotificationService: opened from background — '
          'data=${message.data}',
        );
      });
    } catch (e) {
      // Most common failure here is a simulator without APNs setup
      // (iOS) — token retrieval throws. We deliberately let the app
      // run anyway; Firestore in-app notifications still work.
      debugPrint('PushNotificationService: init failed: $e');
    }
  }

  Future<void> _storeTokenIfAvailable(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint(
          'PushNotificationService: no FCM token yet (simulator or '
          "APNs not configured) — skipping store.",
        );
        return;
      }
      await _writeToken(uid, token);
    } catch (e) {
      debugPrint('PushNotificationService: getToken failed: $e');
    }
  }

  /// Append [token] to `users/{uid}.fcmTokens` via array-union.
  /// Idempotent: re-storing the same token is a no-op server-side.
  /// Failures are swallowed (debugPrint only) so a Firestore rules
  /// blip doesn't crash the auth/session flow.
  Future<void> _writeToken(String uid, String token) async {
    try {
      await _db.collection('users').doc(uid).set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]),
          // Useful for cleanup jobs that drop tokens that haven't
          // refreshed in N days.
          'fcmTokensUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('PushNotificationService: token write failed: $e');
    }
  }
}
