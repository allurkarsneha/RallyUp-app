import 'court.dart';

/// In-memory bag of the user's booking selections, passed from
/// `BookCourtSheet` / `PlayersSetupSheet` into `ConfirmBookingPage`.
///
/// NOT persisted to Firestore. The actual `bookings/{id}` doc is only
/// written by `BookingService.createBooking` after the user taps
/// "Confirm Booking" on the review page. For Open Match drafts, no
/// Firestore write happens at all in this phase — the review page
/// just shows a SnackBar.
class BookingDraft {
  static const String matchTypePrivate = 'private';
  static const String matchTypeOpen = 'open';

  final Court court;
  final String sportType;
  final DateTime date;
  /// 24-hour `HH:mm`, e.g. `'18:00'`.
  final String startTime;
  final String endTime;
  /// One of `BookingDraft.matchTypePrivate` / `matchTypeOpen`.
  final String matchType;
  /// Only meaningful for [matchTypeOpen] drafts. Private drafts may
  /// leave these null.
  final int? playersRequired;
  final int? playersConfirmed;

  const BookingDraft({
    required this.court,
    required this.sportType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.matchType,
    this.playersRequired,
    this.playersConfirmed,
  });

  bool get isOpenMatch => matchType == matchTypeOpen;
  bool get isPrivateMatch => matchType == matchTypePrivate;

  /// For Open Match only — how many more players the host needs.
  /// Returns 0 (rather than negative) if the host overshoots.
  int get playersStillNeeded {
    final req = playersRequired ?? 0;
    final con = playersConfirmed ?? 0;
    final diff = req - con;
    return diff < 0 ? 0 : diff;
  }

  /// Total price for the booking. Slots are 1-hour for now so this is
  /// just the court's per-hour rate; once variable-length slots ship,
  /// multiply by hours-in-slot here so every consumer sees the same
  /// number.
  double get totalPrice => court.pricePerHour;
}
