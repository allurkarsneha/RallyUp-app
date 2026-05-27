import 'package:flutter/material.dart';

import '../main.dart';

/// Switches the active bottom-nav tab inside the existing [MainShell]
/// without pushing a new shell as the navigator root.
///
/// Why this exists:
/// Many pushed routes used to wire their bottom nav with
/// `Navigator.pushAndRemoveUntil(... MainShell(initialIndex: index), (r) => false)`.
/// That call REMOVES `AuthGate` from the route stack and installs a
/// fresh `MainShell` as the root. After logout, the AuthProvider
/// clears `currentUser` and notifies listeners; `MainShell` rebuilds,
/// sees `user == null`, and returns `SizedBox.shrink()` — but
/// `AuthGate` is no longer in the stack to flip to `SignupScreen`.
/// Result: a blank/black page until the user kills the app.
///
/// The correct pattern is to keep `AuthGate` as the root (it's the
/// only widget allowed to decide which top-level screen to show
/// based on auth state) and treat MainShell as a singleton living
/// underneath it. To "switch tabs from a pushed route" we:
///
///   1. Pop every route above the AuthGate home route, exposing the
///      already-mounted MainShell.
///   2. Call `MainShell.globalKey.currentState?.switchTo(index)` on
///      that shell to flip its IndexedStack.
///
/// Use this helper from `_onBottomNavTap` (or equivalent) in any
/// pushed screen. Do NOT push a new `MainShell`.
void switchToMainShellTab(BuildContext context, int index) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  MainShell.globalKey.currentState?.switchTo(index);
}
