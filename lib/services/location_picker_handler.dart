import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/location_picker_sheet.dart';
import 'location_service.dart';

/// Opens the location picker and persists the user's choice through
/// AuthProvider so every header in the app (home, courts, nearby players,
/// open matches) immediately reflects the same value.
///
/// Returns true if any change was written, false if the user cancelled or
/// the choice failed.
Future<bool> openLocationPicker(BuildContext context) async {
  final result = await showModalBottomSheet<LocationPickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const LocationPickerSheet(),
  );

  if (result == null) return false;
  if (!context.mounted) return false;

  final auth = context.read<AuthProvider>();
  final messenger = ScaffoldMessenger.maybeOf(context);

  switch (result) {
    case CurrentLocationRequest():
      try {
        final captured = await LocationService().captureCurrent();
        await auth.updateLocation(captured);
        return true;
      } catch (_) {
        messenger?.showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't read your location. Check location permission and try again.",
            ),
          ),
        );
        return false;
      }
    case ManualLocationPick(:final label):
      // Forward-geocode the label so the saved record has real lat/lng.
      // The legacy `UserLocation.manual(label)` shortcut stored `(0, 0)`,
      // which made every haversine distance against real players read as
      // ~7,900 mi — that's the Cupertino/San Mateo bug. If geocoding can't
      // resolve the label, surface a SnackBar instead of silently saving
      // bad coordinates.
      try {
        final resolved =
            await LocationService().resolveManualLocation(label);
        await auth.updateLocation(resolved);
        return true;
      } catch (_) {
        messenger?.showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't set that location. Please try another city.",
            ),
          ),
        );
        return false;
      }
  }
}
