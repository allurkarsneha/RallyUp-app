import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking_draft.dart';
import '../../models/court.dart';
import '../../screens/confirm_booking_page.dart';
import '../../services/court_availability_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/booking_slots.dart';
import 'players_setup_sheet.dart';

/// Bottom sheet opened by Court Details → Book Now.
///
/// Flow matches the original RallyUp booking UX:
///   1. Pick sport (only shown for multi-sport courts).
///   2. Pick date.
///   3. Pick a 1-hour time slot.
///   4. Pick Match Type — Private Match or Open Match.
///   5. Continue.
///
/// Branches on Match Type:
///   * Private Match → `BookingService.createBooking` writes a real
///     Firestore booking and the user lands on
///     `BookingConfirmedPage(real Booking)`.
///   * Open Match → opens `PlayersSetupSheet` so the user can set
///     "players required" / "players confirmed" via the existing
///     [NumberPickerSheet] flow. Open Match end-to-end integration
///     (invites, match doc creation) is handled there.
///
/// Slot data comes from the shared [bookingSlots] constant so the
/// "X slots today" badge on the court card and the time grid here
/// always agree.
class BookCourtSheet extends StatefulWidget {
  final Court court;
  final String initialSport;

  const BookCourtSheet({
    super.key,
    required this.court,
    required this.initialSport,
  });

  @override
  State<BookCourtSheet> createState() => _BookCourtSheetState();
}

enum _MatchType { privateMatch, openMatch }

class _BookCourtSheetState extends State<BookCourtSheet> {
  late String _selectedSport;
  late DateTime _selectedDate;
  final CourtAvailabilityService _availability = CourtAvailabilityService();

  /// We persist the picked slot itself, not its index into
  /// [bookingSlots]. Reason: once we filter past slots for today, the
  /// visible grid no longer maps 1:1 onto `bookingSlots`, so an
  /// index-based selection would silently point at the wrong slot
  /// after the user changes date.
  BookingSlot? _selectedSlot;
  _MatchType _matchType = _MatchType.openMatch;
  bool _busy = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final supported = widget.court.sportTypes;
    _selectedSport = supported.contains(widget.initialSport)
        ? widget.initialSport
        : (supported.isNotEmpty ? supported.first : '');
    _selectedDate = DateTime.now();
  }

  Future<void> _openDatePicker() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(firstDate)
          ? firstDate
          : _selectedDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // If the previously selected slot no longer exists on the
        // new date (e.g. user moved from tomorrow to today and the
        // slot is now in the past), clear it so the user is forced
        // to repick. Without this clear, Continue would happily fire
        // a booking against a slot that's no longer offered.
        final stillAvailable = _availableSlotsFor(_selectedDate);
        final keep = _selectedSlot;
        if (keep != null &&
            !stillAvailable.any(
              (s) => s.start == keep.start && s.end == keep.end,
            )) {
          _selectedSlot = null;
        }
        _formError = null;
      });
    }
  }

  /// Returns the slot list that should be shown to the user for the
  /// given [date].
  ///
  ///   * Today → only slots whose start time is strictly after the
  ///     current wall clock. A 6 AM slot at 3:45 PM is hidden;
  ///     5 PM / 6 PM / 7 PM / 8 PM remain.
  ///   * Any future date → every slot in [bookingSlots].
  ///   * Any past date (shouldn't happen because the date picker's
  ///     firstDate is today, but defensive) → empty list.
  ///
  /// Per-slot availability against existing bookings is still
  /// deferred — this is only time-based filtering.
  List<BookingSlot> _availableSlotsFor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOnly = DateTime(date.year, date.month, date.day);
    if (dayOnly.isBefore(today)) return const [];
    if (dayOnly.isAfter(today)) return bookingSlots;
    // dayOnly == today → keep slots whose start is after `now`.
    return bookingSlots
        .where((slot) {
          final parts = slot.start.split(':');
          final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
          final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
          final slotStart = DateTime(date.year, date.month, date.day, h, m);
          return slotStart.isAfter(now);
        })
        .toList(growable: false);
  }

  /// Validate the form, then branch on match type. Captures any
  /// context-dependent values up front so the async work doesn't
  /// race the sheet's own dismissal.
  ///
  /// IMPORTANT: This Continue button DOES NOT create a booking. It
  /// only builds a [BookingDraft] and routes to the review surface
  /// (ConfirmBookingPage for private, PlayersSetupSheet → review for
  /// open). The Firestore write only happens after the user taps
  /// "Confirm Booking" on that review screen.
  Future<void> _continue() async {
    if (_busy) return;
    if (_selectedSport.isEmpty) {
      setState(() => _formError = 'Pick a sport to continue.');
      return;
    }
    final slot = _selectedSlot;
    if (slot == null) {
      setState(() => _formError = 'Pick a time slot to continue.');
      return;
    }
    // Defensive recheck — the user may have left the sheet open
    // past the slot's start time. Re-validate against the live
    // availability list before any booking write happens downstream.
    final stillAvailable = _availableSlotsFor(
      _selectedDate,
    ).any((s) => s.start == slot.start && s.end == slot.end);
    if (!stillAvailable) {
      setState(() {
        _selectedSlot = null;
        _formError =
            'That time slot is no longer available. Pick another slot.';
      });
      return;
    }

    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    setState(() {
      _busy = true;
      _formError = null;
    });

    switch (_matchType) {
      case _MatchType.privateMatch:
        await _openPrivateReview(slot, date);
        break;
      case _MatchType.openMatch:
        await _openPlayersSetup(slot, date);
        break;
    }
  }

  Future<void> _openPrivateReview(BookingSlot slot, DateTime date) async {
    // Capture before the sheet pops — once unmounted, `context`
    // can't drive Navigator pushes.
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final draft = BookingDraft(
      court: widget.court,
      sportType: _selectedSport,
      date: date,
      startTime: slot.start,
      endTime: slot.end,
      matchType: BookingDraft.matchTypePrivate,
    );
    Navigator.of(context).pop(); // close this sheet
    rootNavigator.push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => ConfirmBookingPage(draft: draft),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Future<void> _openPlayersSetup(BookingSlot slot, DateTime date) async {
    // PlayersSetupSheet now also routes into ConfirmBookingPage
    // (Open Match draft). When the user returns here, reset our busy
    // flag so they can edit & re-continue.
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayersSetupSheet(
        court: widget.court,
        sportType: _selectedSport,
        date: date,
        startTime: slot.start,
        endTime: slot.end,
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Widget _buildSportChip(String sport) {
    final isSelected = _selectedSport == sport;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSport = sport;
          _formError = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          sport,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(BookingSlot slot, BuildContext context) {
    final picked = _selectedSlot;
    final isSelected =
        picked != null && picked.start == slot.start && picked.end == slot.end;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSlot = slot;
          _formError = null;
        });
      },
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          slot.label(context),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchTypeCard({
    required _MatchType value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _matchType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _matchType = value;
          _formError = null;
        });
      },
      child: Container(
        height: 180,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 34, color: AppColors.textPrimary),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final court = widget.court;
    final priceText = '\$${court.pricePerHour.toStringAsFixed(0)}/hr';
    // Recompute every build so a sheet that the user keeps open
    // across a slot-start boundary (e.g. picks 4–5 PM at 3:55 PM,
    // sits idle until 4:01) reflects reality on the next rebuild.
    final visibleSlots = _availableSlotsFor(_selectedDate);

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Book Court',
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    priceText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                court.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              if (court.sportTypes.length > 1) ...[
                Text(
                  'Select sport',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in court.sportTypes) _buildSportChip(s),
                  ],
                ),
                const SizedBox(height: 22),
              ],
              Text(
                'Select date',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _openDatePicker,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('EEE, MMM d, y').format(_selectedDate),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 28,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Select time',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // Live availability against occupied bookings/matches.
              // While the fetch is in flight we still render the
              // time-only filtered slots so the grid never blanks —
              // an in-flight tap is also re-validated in
              // [_continue].
              FutureBuilder<List<BookingSlot>>(
                future: _availability.availableSlotsFor(
                  courtId: court.id,
                  date: _selectedDate,
                ),
                builder: (context, snap) {
                  final showSlots = snap.data ?? visibleSlots;
                  if (showSlots.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        snap.connectionState == ConnectionState.waiting
                            ? 'Checking availability…'
                            : 'No slots available for this date. Please choose another date.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    itemCount: showSlots.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 48,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      return _buildTimeChip(showSlots[index], context);
                    },
                  );
                },
              ),
              const SizedBox(height: 22),
              Text(
                'Match type',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMatchTypeCard(
                      value: _MatchType.privateMatch,
                      title: 'Private Match',
                      subtitle: 'Only invited players\ncan join',
                      icon: Icons.lock_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMatchTypeCard(
                      value: _MatchType.openMatch,
                      title: 'Open Match',
                      subtitle: 'Anyone can join\nthis match',
                      icon: Icons.groups_rounded,
                    ),
                  ),
                ],
              ),
              if (_formError != null) ...[
                const SizedBox(height: 14),
                Text(
                  _formError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _busy ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.4,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
