import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_notification.dart';
import '../screens/booking_confirmed_page.dart';
import '../screens/player_details/invites_page.dart';
import '../screens/player_details/match_details_page.dart';
import 'booking_service.dart';
import 'invite_service.dart';
import 'open_match_service.dart';

/// Client-side Firebase Cloud Messaging (FCM) wiring.
///
/// What this DOES:
///   * Requests notification permission (iOS prompts on first call;
///     Android 13+ shows a runtime permission).
///   * Reads the current device's FCM token and stores it under
///     `users/{uid}.fcmTokens` (array-union, so multiple devices per
///     user are supported without overwriting each other).
///   * Subscribes to token-refresh and onMessage streams for the
///     life of the app process.
///   * Shows an in-app SnackBar banner for foreground messages so
///     the user notices the new notification without having to walk
///     to the bell.
///   * Routes notification taps (foreground / background / cold
///     launch) to the right page using the same
///     `targetType` + `targetId` contract as in-app notifications.
///
/// What this DOES NOT do (yet):
///   * iOS production push routing. iOS requires an APNs auth key
///     uploaded in Firebase + an APNs entitlement on the build. On
///     simulator the token can be null and that's expected.
///
/// The server-side sender (Cloud Function) is shipped in
/// /functions/index.js — it listens on `notifications/{id}` create
/// events and delivers the in-app notification to FCM. Deploy with
/// `firebase deploy --only functions` once the project is wired.
///
/// Errors are swallowed + debugPrinted. FCM availability shouldn't
/// block app startup or any user flow.
class PushNotificationService {
  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;
  final BookingService _bookingService;
  final OpenMatchService _openMatchService;
  final InviteService _inviteService;

  PushNotificationService({
    FirebaseFirestore? db,
    FirebaseMessaging? messaging,
    BookingService? bookingService,
    OpenMatchService? openMatchService,
    InviteService? inviteService,
  }) : _db = db ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance,
       _bookingService = bookingService ?? BookingService(),
       _openMatchService = openMatchService ?? OpenMatchService(),
       _inviteService = inviteService ?? InviteService();

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
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      await _storeTokenIfAvailable(uid);

      // Re-write on rotation. FCM rotates tokens periodically and
      // after app reinstalls; without this we'd drift off the
      // user's `fcmTokens` array.
      _messaging.onTokenRefresh.listen(
        (token) async {
          await _writeToken(uid, token);
        },
        onError: (e) {
          debugPrint('PushNotificationService: onTokenRefresh error: $e');
        },
      );

      // Foreground delivery: show a SnackBar so the user notices
      // the new event without having to open the bell. Tapping the
      // SnackBar action routes the same way a system-tray tap would.
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Cold-launch entry point: app opened via a notification tap
      // when it was terminated.
      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        // Defer the route push until after the first frame; the
        // navigator key isn't ready before runApp finishes.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _routeFromMessage(initial);
        });
      }

      // Warm-launch entry point: app opened via notification tap
      // from background.
      FirebaseMessaging.onMessageOpenedApp.listen(_routeFromMessage);
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
  Future<void> _writeToken(String uid, String token) async {
    try {
      await _db.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokensUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('PushNotificationService: token write failed: $e');
    }
  }

  /// Foreground SnackBar banner. The View action runs the same
  /// target-resolver as a system-tray tap.
  void _handleForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    final title = n?.title?.trim() ?? '';
    final body = n?.body?.trim() ?? '';
    final preview = [
      title,
      if (body.isNotEmpty) body,
    ].where((s) => s.isNotEmpty).join(' · ');
    if (preview.isEmpty) return;
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(preview),
        action: _hasRoutableTarget(message.data)
            ? SnackBarAction(
                label: 'View',
                onPressed: () => _routeFromMessage(message),
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  bool _hasRoutableTarget(Map<String, dynamic> data) {
    final type = data['targetType'] as String?;
    final id = data['targetId'] as String?;
    return (type != null && type.isNotEmpty) && (id != null && id.isNotEmpty);
  }

  /// Resolve `data.targetType` + `data.targetId` and push the
  /// matching detail screen. Mirrors `NotificationsPage._onTap`
  /// routing so taps from the tray reach the same destinations.
  Future<void> _routeFromMessage(RemoteMessage message) async {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;
    final data = message.data;
    final type = data['targetType'] as String?;
    final id = data['targetId'] as String?;
    if (type == null || id == null || id.isEmpty) return;

    try {
      switch (type) {
        case AppNotification.targetBooking:
          final booking = await _bookingService.getBooking(id);
          if (booking == null) {
            _toast('This booking is no longer available.');
            return;
          }
          navigator.push(
            MaterialPageRoute(
              builder: (_) => BookingConfirmedPage(booking: booking),
            ),
          );
          break;
        case AppNotification.targetMatch:
          final match = await _openMatchService.getOpenMatch(id);
          if (match == null) {
            _toast('This match is no longer available.');
            return;
          }
          navigator.push(
            MaterialPageRoute(builder: (_) => MatchDetailsPage(match: match)),
          );
          break;
        case AppNotification.targetInvite:
          // Resolved invite → MatchDetails when the match still
          // exists; pending invite → Received tab. Same convention
          // NotificationsPage uses.
          final invite = await _inviteService.getInvite(id);
          if (invite == null || invite.isPending) {
            navigator.push(
              MaterialPageRoute(
                builder: (_) =>
                    const InvitesPage(initialTab: InviteTab.received),
              ),
            );
            return;
          }
          final match = await _openMatchService.getOpenMatch(invite.matchId);
          if (match == null) {
            _toast('This match is no longer available.');
            return;
          }
          navigator.push(
            MaterialPageRoute(builder: (_) => MatchDetailsPage(match: match)),
          );
          break;
        default:
          return;
      }
    } catch (e) {
      debugPrint('PushNotificationService: route failed: $e');
      _toast("Couldn't open that notification.");
    }
  }

  void _toast(String text) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }
}
