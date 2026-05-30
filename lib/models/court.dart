import 'package:cloud_firestore/cloud_firestore.dart';

/// A bookable court / venue. Real Firestore data, replaces the
/// hard-coded `_allCourts` map list that the Courts tab used to render.
///
/// Notable shape decisions:
///
///   * `sportTypes` is a list — a single venue can support multiple
///     sports (e.g. Cupertino Sports Center hosts Tennis + Badminton +
///     Pickleball). The CourtsPage sport filter must use
///     `sportTypes.contains(selectedSport)`, never an equality check.
///   * `imageUrls` is a list of fully-built Cloudinary URLs. The
///     seeder converts Cloudinary public IDs into URLs at write time
///     via `CourtService._cloudinaryCourtImage`; clients don't need to
///     know about Cloudinary public IDs.
///   * `isActive` defaults to `true` for legacy/missing docs so we
///     never silently hide an entire court because of a partial doc.
class Court {
  final String id;
  final String name;
  final List<String> sportTypes;
  final String address;
  final String city;
  final String region;
  final double lat;
  final double lng;
  final List<String> imageUrls;
  final double? rating;
  final double pricePerHour;
  final List<String> amenities;
  final String description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Court({
    required this.id,
    required this.name,
    required this.sportTypes,
    required this.address,
    required this.city,
    required this.region,
    required this.lat,
    required this.lng,
    required this.imageUrls,
    required this.rating,
    required this.pricePerHour,
    required this.amenities,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Court copyWith({
    String? name,
    List<String>? sportTypes,
    String? address,
    String? city,
    String? region,
    double? lat,
    double? lng,
    List<String>? imageUrls,
    double? rating,
    double? pricePerHour,
    List<String>? amenities,
    String? description,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Court(
      id: id,
      name: name ?? this.name,
      sportTypes: sportTypes ?? this.sportTypes,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      amenities: amenities ?? this.amenities,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'sportTypes': sportTypes,
    'address': address,
    'city': city,
    'region': region,
    'lat': lat,
    'lng': lng,
    'imageUrls': imageUrls,
    'rating': rating,
    'pricePerHour': pricePerHour,
    'amenities': amenities,
    'description': description,
    'isActive': isActive,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  factory Court.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Court.fromMap({...data, 'id': doc.id});
  }

  factory Court.fromMap(Map<String, dynamic> map) {
    return Court(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      sportTypes: _parseStringList(map['sportTypes']),
      address: (map['address'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      region: (map['region'] as String?) ?? '',
      lat: _parseDouble(map['lat']) ?? 0,
      lng: _parseDouble(map['lng']) ?? 0,
      imageUrls: _parseStringList(map['imageUrls']),
      rating: _parseDouble(map['rating']),
      pricePerHour: _parseDouble(map['pricePerHour']) ?? 0,
      amenities: _parseStringList(map['amenities']),
      description: (map['description'] as String?) ?? '',
      // Missing `isActive` → treat as visible. A court that's been
      // partially written (e.g. the seed half-completed) is better
      // shown than silently dropped.
      isActive: (map['isActive'] as bool?) ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static double? _parseDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return const [];
  }
}
