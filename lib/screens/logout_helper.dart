import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Performs a clean sign-out from any entry point (Profile page,
/// SideMenuDrawer, Home avatar overlay).
///
/// The "black/blank page" bug we kept hitting on logout came from
/// ordering: every call site previously did
///
///   1. `await auth.signOut()` — clears `_currentUser`, notifies
///      listeners, so AuthGate immediately rebuilds the home route to
///      SignupScreen.
///   2. `Navigator.popUntil((r) => r.isFirst)` — pops anything pushed
///      above the home route.
///
/// Between (1) and (2), pushed routes (the side-menu drawer's overlay,
/// `NearbyPlayersPage`, `InvitesPage`, etc.) are still on top of the
/// stack. Those routes call `context.watch<AuthProvider>().currentUser`,
/// see `null`, and render a stale Scaffold — sometimes a dark or blank
/// one — for a couple of frames until popUntil finally clears them.
///
/// Fix: reset the route stack to the home route BEFORE signing out, so
/// when AuthGate flips to SignupScreen there is nothing above it to
/// paint with a null user.
Future<void> performLogout(BuildContext context) async {
  // Capture everything that depends on `context` up front. The caller
  // typically invokes this from a dialog or drawer item, both of which
  // are about to be unmounted by the popUntil below.
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  final auth = context.read<AuthProvider>();

  // Close any drawer attached to the current Scaffold. Scaffold drawers
  // are LocalHistoryEntries on their parent route — popUntil(isFirst)
  // would close them as a side effect, but closing explicitly here keeps
  // the dismiss animation tied to the user's tap instead of the
  // signOut frame.
  final scaffold = Scaffold.maybeOf(context);
  if (scaffold?.isDrawerOpen ?? false) {
    scaffold!.closeDrawer();
  }

  // Collapse the navigator down to the AuthGate home route, then sign
  // out. AuthGate will rebuild on the very next frame — by that point
  // it is the only thing visible.
  rootNavigator.popUntil((route) => route.isFirst);
  await auth.signOut();
}
