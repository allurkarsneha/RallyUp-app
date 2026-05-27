import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking_draft.dart';
import '../providers/auth_provider.dart';
import '../services/booking_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/sport_emoji.dart';
import '../widgets/courts/court_network_image.dart';
import '../widgets/main_bottom_nav.dart';
import 'booking_confirmed_page.dart';
import 'main_shell_nav.dart';

/// Review-before-confirm page. Sits between BookCourtSheet (or the
/// Open Match `PlayersSetupSheet`) and the final
/// `BookingConfirmedPage`.
///
/// Why a separate page exists:
///   * The user explicitly needs a "review your selection" beat
///     before money / commitment language fires. We don't want
///     `BookCourtSheet`'s sport/date/time chips to also double as
///     the place where Firestore writes happen — that was the cause
///     of the prior "Tap continue → instant booking" misstep.
///   * Open Match drafts hit the same review surface but their
///     Confirm button is a clearly-marked "coming next" placeholder —
///     no Firestore write, no fake confirmation.
///
/// `BookingDraft` is intentionally an in-memory model. Nothing lives
/// in Firestore until `Confirm Booking` runs `BookingService.createBooking`
/// (private path only).
class ConfirmBookingPage extends StatefulWidget {
  final BookingDraft draft;

  const ConfirmBookingPage({super.key, required this.draft});

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final BookingService _bookingService = BookingService();
  bool _busy = false;

  Future<void> _confirmPrivateBooking() async {
    final me = context.read<AuthProvider>().currentUser;
    if (me == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to confirm this booking.'),
        ),
      );
      return;
    }
    // Capture before the async write — by the time we navigate, the
    // local context may be on the way out.
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _busy = true);
    try {
      final booking = await _bookingService.createBooking(
        userId: me.uid,
        court: widget.draft.court,
        sportType: widget.draft.sportType,
        date: widget.draft.date,
        startTime: widget.draft.startTime,
        endTime: widget.draft.endTime,
      );
      if (!mounted) return;
      rootNavigator.pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              BookingConfirmedPage(booking: booking),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (_) {
      if (!mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Couldn't confirm this booking. Try again."),
          ),
        );
        return;
      }
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Couldn't confirm this booking. Try again."),
        ),
      );
    }
  }

  /// Open Match path: deliberately a no-write placeholder.
  /// `open_matches/{id}` integration ships later — for now we surface
  /// a clear SnackBar so the user understands their selection wasn't
  /// saved as a private booking.
  void _confirmOpenMatch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Open Match creation is coming next. Nothing was booked.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    switchToMainShellTab(context, index);
  }

  String _formatTime(BuildContext context, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: h, minute: m));
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final dateText = DateFormat('EEE, MMM d, y').format(draft.date);
    final timeText =
        '${_formatTime(context, draft.startTime)} - '
        '${_formatTime(context, draft.endTime)}';
    final emoji = sportEmojiFor(draft.sportType);
    final matchTypeLabel =
        draft.isOpenMatch ? 'Open match' : 'Private match';
    final priceText = '\$${draft.court.pricePerHour.toStringAsFixed(2)}';
    final totalText = '\$${draft.totalPrice.toStringAsFixed(2)}';
    final imageUrl = draft.court.imageUrls.isNotEmpty
        ? draft.court.imageUrls.first
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                18,
                AppSpacing.pageHorizontal,
                10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Confirm Booking',
                    style: AppTextStyles.pageTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  8,
                  AppSpacing.pageHorizontal,
                  24,
                ),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(16, 0, 0, 0),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: CourtNetworkImage(
                                url: imageUrl,
                                iconSize: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draft.court.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (draft.court.address.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      draft.court.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    '$emoji  ${draft.sportType}',
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    dateText,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeText,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Booking Details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Match type',
                    value: matchTypeLabel,
                    valueColor: AppColors.primary,
                  ),
                  if (draft.isOpenMatch) ...[
                    _DetailRow(
                      label: 'Players required',
                      value: '${draft.playersRequired ?? 0}',
                    ),
                    _DetailRow(
                      label: 'Players confirmed',
                      value:
                          '${draft.playersConfirmed ?? 0} (including you)',
                    ),
                    _DetailRow(
                      label: 'Still needed',
                      value: '${draft.playersStillNeeded}',
                    ),
                  ],
                  const Divider(color: AppColors.border, height: 28),
                  Text(
                    'Price Details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Price per hour',
                    value: priceText,
                  ),
                  _DetailRow(
                    label: draft.isOpenMatch ? 'Total court price' : 'Total',
                    value: totalText,
                    isBold: !draft.isOpenMatch,
                  ),
                  if (draft.isOpenMatch) ...[
                    // Cost split for Open Match. We divide the court
                    // total by `playersRequired` (clamped to at least
                    // 1 so a misconfigured draft can't divide by zero
                    // — the BookCourtSheet validation already enforces
                    // a positive value, but the model nominally
                    // allows null/0). This matches the host-pays-
                    // their-share model the earlier mock confirmation
                    // surfaced; later phases will track per-player
                    // payment state inside the open match doc.
                    () {
                      final players =
                          (draft.playersRequired ?? 0) <= 0
                              ? 1
                              : (draft.playersRequired ?? 1);
                      final perPlayer = draft.totalPrice / players;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DetailRow(
                            label: 'Split between',
                            value: players == 1
                                ? '1 player'
                                : '$players players',
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 4,
                              bottom: 6,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Each player pays',
                                  style:
                                      AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${perPlayer.toStringAsFixed(2)}',
                                  style:
                                      AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }(),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _busy
                          ? null
                          : (draft.isOpenMatch
                              ? _confirmOpenMatch
                              : _confirmPrivateBooking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                              draft.isOpenMatch
                                  ? 'Confirm Open Match'
                                  : 'Confirm Booking',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secure Booking',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: null,
        onTap: _onBottomNavTap,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 170,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
