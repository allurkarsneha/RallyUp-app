import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_location.dart';
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
      await auth.updateLocation(UserLocation.manual(label));
      return true;
  }
}
