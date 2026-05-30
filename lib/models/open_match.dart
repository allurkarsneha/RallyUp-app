import 'package:cloud_firestore/cloud_firestore.dart';

/// Open match doc — `open_matches/{matchId}`.
///
/// Stores a small host snapshot (`hostName / hostInitials /
/// hostPhotoUrl / hostAvatarId`) so the OpenMatchesPage card can
/// render the host's avatar without doing a `users/{hostUid}` fetch
/// per card, and so a later rename of the host's profile doesn't
/// retroactively rewrite every match they ever hosted.
///
/// Joined-player tracking is intentionally a pair of parallel arrays
/// (`joinedPlayerIds` + `joinedPlayerNames`) rather than a list of
/// objects. Arrays of primitives play well with Firestore security
/// rules + `arrayUnion` updates, and we only need uid + display name
/// for the participants-strip on MatchDetailsPage. If we later need
/// per-player metadata (avatarId, photoUrl, joinedAt, payment state),
/// the cleanest migration is a subcollection — not a list of maps.
///
/// "Players already confirmed" support (the count the host enters on
/// PlayersSetupSheet that exceeds the host themself) is stored via
/// [confirmedGuestCount]. We don't fabricate fake uids for those
/// guests — they have no [joinedPlayerIds] entry — but they are
/// counted toward [effectiveJoinedCount] and [spotsLeft] / [isFull].
class OpenMatch {
  static const String statusOpen = 'open';
  static const String statusFull = 'full';
  static const String statusCancelled = 'cancelled';

  final String id;

  final String hostUid;
  final String hostName;
  final String hostInitials;
  final String? hostPhotoUrl;
  final String? hostAvatarId;

  final String courtId;
  final String courtName;
  final String courtAddress;

  /// First image — kept for backward compatibility with old docs and
  /// the list cards / home rail (which only need a single thumbnail).
  /// Index 0 of [courtImageUrls] when both are present.
  final String courtImageUrl;

  /// Full carousel set fed into [CourtImageCarousel] on
  /// MatchDetailsPage. Old docs without this field fall back to
  /// `[courtImageUrl]` (or `[]` when neither is present).
  final List<String> courtImageUrls;

  final String sportType;
  final DateTime date;

  /// 24-hour `HH:mm`.
  final String startTime;
  final String endTime;
  final double pricePerHour;
  final double totalPrice;

  final int playersRequired;
  final List<String> joinedPlayerIds;
  final List<String> joinedPlayerNames;

  /// Players the host claims are already confirmed but who don't have
  /// a real RallyUp account / uid in [joinedPlayerIds]. Equals
  /// `playersConfirmed - 1` at create time (the `-1` strips the host
  /// out of the count, since the host is always real and lives in
  /// `joinedPlayerIds[0]`). Defaults to 0 on legacy docs.
  final int confirmedGuestCount;

  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OpenMatch({
    required this.id,
    required this.hostUid,
    required this.hostName,
    required this.hostInitials,
    required this.hostPhotoUrl,
    required this.hostAvatarId,
    required this.courtId,
    required this.courtName,
    required this.courtAddress,
    required this.courtImageUrl,
    required this.courtImageUrls,
    required this.sportType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.totalPrice,
    required this.playersRequired,
    required this.joinedPlayerIds,
    required this.joinedPlayerNames,
    required this.confirmedGuestCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Real users present in `joinedPlayerIds` — host plus anyone who
  /// tapped Join through MatchDetailsPage. Use this when you need a
  /// uid-backed identity (DM, profile lookup, dedupe, transactions).
  int get realJoinedCount => joinedPlayerIds.length;

  /// `realJoinedCount + confirmedGuestCount`. Use this for any
  /// user-visible "joined" count or capacity check — spots-left
  /// labels, "Players (5 / 6)" headers, full/open status. It's the
  /// count the host filled out, not the array length.
  int get effectiveJoinedCount => joinedPlayerIds.length + confirmedGuestCount;

  /// Backward-compat alias: existing card widgets and labels that
  /// already read `joinedCount` automatically pick up the effective
  /// number. New code should prefer [effectiveJoinedCount] for
  /// clarity.
  int get joinedCount => effectiveJoinedCount;

  int get spotsLeft {
    final left = playersRequired - effectiveJoinedCount;
    return left < 0 ? 0 : left;
  }

  bool get isOpen => status == statusOpen;
  bool get isFull => status == statusFull;
  bool get isCancelled => status == statusCancelled;

  /// Per-player share. Guard against `playersRequired == 0` so a
  /// hand-edited doc can't divide by zero — fall back to 1 player so
  /// the result equals the court total.
  double get pricePerPlayer {
    final divisor = playersRequired <= 0 ? 1 : playersRequired;
    return totalPrice / divisor;
  }

  bool hasJoined(String uid) => joinedPlayerIds.contains(uid);
  bool isHost(String uid) => hostUid == uid;

  OpenMatch copyWith({
    List<String>? joinedPlayerIds,
    List<String>? joinedPlayerNames,
    int? confirmedGuestCount,
    String? status,
    DateTime? updatedAt,
  }) {
    return OpenMatch(
      id: id,
      hostUid: hostUid,
      hostName: hostName,
      hostInitials: hostInitials,
      hostPhotoUrl: hostPhotoUrl,
      hostAvatarId: hostAvatarId,
      courtId: courtId,
      courtName: courtName,
      courtAddress: courtAddress,
      courtImageUrl: courtImageUrl,
      courtImageUrls: courtImageUrls,
      sportType: sportType,
      date: date,
      startTime: startTime,
      endTime: endTime,
      pricePerHour: pricePerHour,
      totalPrice: totalPrice,
      playersRequired: playersRequired,
      joinedPlayerIds: joinedPlayerIds ?? this.joinedPlayerIds,
      joinedPlayerNames: joinedPlayerNames ?? this.joinedPlayerNames,
      confirmedGuestCount: confirmedGuestCount ?? this.confirmedGuestCount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'hostUid': hostUid,
    'hostName': hostName,
    'hostInitials': hostInitials,
    'hostPhotoUrl': hostPhotoUrl,
    'hostAvatarId': hostAvatarId,
    'courtId': courtId,
    'courtName': courtName,
    'courtAddress': courtAddress,
    'courtImageUrl': courtImageUrl,
    'courtImageUrls': courtImageUrls,
    'sportType': sportType,
    'date': Timestamp.fromDate(date),
    'startTime': startTime,
    'endTime': endTime,
    'pricePerHour': pricePerHour,
    'totalPrice': totalPrice,
    'playersRequired': playersRequired,
    'joinedPlayerIds': joinedPlayerIds,
    'joinedPlayerNames': joinedPlayerNames,
    'confirmedGuestCount': confirmedGuestCount,
    'status': status,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  factory OpenMatch.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return OpenMatch.fromMap({...data, 'id': doc.id});
  }

  factory OpenMatch.fromMap(Map<String, dynamic> map) {
    final courtImageUrl = (map['courtImageUrl'] as String?) ?? '';
    // Backward compat: older docs only have `courtImageUrl`. Promote
    // it into the carousel list so MatchDetailsPage's hero still
    // shows that image instead of dropping to a placeholder.
    final parsedUrls = _parseStringList(map['courtImageUrls']);
    final urls = parsedUrls.isNotEmpty
        ? parsedUrls
        : (courtImageUrl.isEmpty ? const <String>[] : [courtImageUrl]);

    return OpenMatch(
      id: (map['id'] as String?) ?? '',
      hostUid: (map['hostUid'] as String?) ?? '',
      hostName: (map['hostName'] as String?) ?? '',
      hostInitials: (map['hostInitials'] as String?) ?? '?',
      hostPhotoUrl: map['hostPhotoUrl'] as String?,
      hostAvatarId: map['hostAvatarId'] as String?,
      courtId: (map['courtId'] as String?) ?? '',
      courtName: (map['courtName'] as String?) ?? '',
      courtAddress: (map['courtAddress'] as String?) ?? '',
      courtImageUrl: courtImageUrl,
      courtImageUrls: urls,
      sportType: (map['sportType'] as String?) ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: (map['startTime'] as String?) ?? '',
      endTime: (map['endTime'] as String?) ?? '',
      pricePerHour: _parseDouble(map['pricePerHour']) ?? 0,
      totalPrice: _parseDouble(map['totalPrice']) ?? 0,
      playersRequired: _parseInt(map['playersRequired']) ?? 0,
      joinedPlayerIds: _parseStringList(map['joinedPlayerIds']),
      joinedPlayerNames: _parseStringList(map['joinedPlayerNames']),
      // Missing → 0. Old docs without the field behave exactly like
      // before: only the real uids count.
      confirmedGuestCount: _parseInt(map['confirmedGuestCount']) ?? 0,
      // Missing status → treat as open. Conservative: a half-written
      // doc shouldn't accidentally read as `full` and hide itself.
      status: (map['status'] as String?) ?? OpenMatch.statusOpen,
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

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return const [];
  }
}
