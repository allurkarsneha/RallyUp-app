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
  String toString() =>
      'LocationFailure($reason${detail != null ? ': $detail' : ''})';
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
      throw const LocationFailure(
        LocationFailureReason.permissionDeniedForever,
      );
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
      final placemarks = await gc.placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city = p.locality ?? p.subAdministrativeArea ?? p.subLocality ?? '';
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

  /// Resolve a user-picked label (e.g. `"Cupertino, CA"`) into a fully
  /// populated [UserLocation] with real lat/lng. The legacy
  /// `UserLocation.manual(label)` constructor stored `(0, 0)` for
  /// coordinates, which made every haversine distance against real player
  /// docs read as ~7,900 mi. That constructor remains as a last-resort
  /// fallback; this method is the supported path for manual picks now.
  ///
  /// Pipeline:
  ///   1. Forward-geocode the label → lat/lng.
  ///   2. Best-effort reverse-geocode that lat/lng → city/region/country.
  ///   3. If reverse-geocoding returns nothing useful, fall back to the
  ///      city/region/country parsed out of the label itself
  ///      ([UserLocation.manual]) so we still write a readable record.
  ///
  /// Throws [LocationFailure(LocationFailureReason.geocodingFailed)] if
  /// forward-geocoding returns no results, so the caller can show a
  /// targeted "couldn't set that location" message rather than silently
  /// persisting `(0, 0)`.
  Future<UserLocation> resolveManualLocation(String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      throw const LocationFailure(
        LocationFailureReason.geocodingFailed,
        'Empty label',
      );
    }

    List<gc.Location> locations;
    try {
      locations = await gc.locationFromAddress(trimmed);
    } catch (e) {
      throw LocationFailure(
        LocationFailureReason.geocodingFailed,
        e.toString(),
      );
    }
    if (locations.isEmpty) {
      throw const LocationFailure(
        LocationFailureReason.geocodingFailed,
        'No results for label',
      );
    }

    final first = locations.first;
    final lat = first.latitude;
    final lng = first.longitude;

    String city = '';
    String region = '';
    String country = '';
    try {
      final placemarks = await gc.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city = p.locality ?? p.subAdministrativeArea ?? p.subLocality ?? '';
        region = p.administrativeArea ?? '';
        country = p.country ?? '';
      }
    } catch (_) {
      // Reverse-geocoding failed (offline emulator, rate-limited service).
      // Fall through; we'll use the parsed label as a backstop below.
    }

    if (city.isEmpty && region.isEmpty && country.isEmpty) {
      final parsed = UserLocation.manual(trimmed);
      city = parsed.city;
      region = parsed.region;
      country = parsed.country;
    }

    return UserLocation(
      lat: lat,
      lng: lng,
      city: city,
      region: region,
      country: country,
      source: LocationSource.manual,
      updatedAt: DateTime.now(),
    );
  }
}
