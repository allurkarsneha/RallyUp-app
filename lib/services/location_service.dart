import 'package:geocoding/geocoding.dart' as gc;
import 'package:geolocator/geolocator.dart';

import '../models/user_location.dart';

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  geocodingFailed,
  unknown,
}

class LocationFailure implements Exception {
  final LocationFailureReason reason;
  final String? detail;
  const LocationFailure(this.reason, [this.detail]);

  @override
  String toString() => 'LocationFailure($reason${detail != null ? ': $detail' : ''})';
}

/// Thin wrapper around `geolocator` + `geocoding` returning a fully-formed
/// [UserLocation] in one call. Phase 2 only needs an on-demand capture —
/// no background tracking, no streaming.
class LocationService {
  Future<UserLocation> captureCurrent() async {
    // 1. Device-level location services on?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(LocationFailureReason.serviceDisabled);
    }

    // 2. App permission state.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationFailureReason.permissionDeniedForever);
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure(LocationFailureReason.permissionDenied);
    }

    // 3. Get a single position fix. Medium accuracy is plenty for a city
    //    label; lower accuracy is much faster and saves battery.
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );

    // 4. Reverse-geocode. Failure here is non-fatal — we still return a
    //    valid UserLocation with empty city/region so the UI can show
    //    coordinates or a generic label.
    String city = '';
    String region = '';
    String country = '';
    try {
      final placemarks =
          await gc.placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city = p.locality ??
            p.subAdministrativeArea ??
            p.subLocality ??
            '';
        region = p.administrativeArea ?? '';
        country = p.country ?? '';
      }
    } catch (_) {
      // Reverse-geocoding can fail on some emulators / offline. Continue.
    }

    return UserLocation(
      lat: pos.latitude,
      lng: pos.longitude,
      city: city,
      region: region,
      country: country,
      source: LocationSource.gps,
      updatedAt: DateTime.now(),
    );
  }
}
