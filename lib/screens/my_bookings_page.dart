import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../services/booking_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/sport_emoji.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/my_booking_list_card.dart';
import '../widgets/notification_bell_button.dart';
import '../widgets/side_menu_drawer.dart';
import 'booking_confirmed_page.dart';
import 'main_shell_nav.dart';

/// Real bookings list for the signed-in user. Replaces the prior
/// hard-coded `_upcomingBookings` / `_pastBookings` lists.
///
/// Upcoming vs. Past is computed off the booking's actual `date`:
/// today-or-later goes to Upcoming, before-today goes to Past. Cancelled
/// bookings stay in the list with a distinct tag so the user can see
/// what they cancelled — same rationale as the soft-cancel in
/// BookingService.
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final BookingService _bookingService = BookingService();
  bool _showUpcoming = true;

  void _openBookingDetails(Booking booking) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => BookingConfirmedPage(booking: booking),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openBookingOptions(Booking booking) {
    if (booking.isCancelled) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                title: Text(
                  'Cancel booking',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  // Capture before the sheet's context unmounts.
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(sheetContext);
                  try {
                    await _bookingService.cancelBooking(booking.id);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Booking cancelled')),
                    );
                  } catch (_) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Couldn't cancel this booking. Try again.",
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
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

  /// Combines `booking.date` (midnight) with the booking's
  /// `endTime` ("HH:mm") so we can compare against
  /// `DateTime.now()` exactly — a 6-7 PM booking on today's date
  /// counts as "Upcoming" up to 7 PM and "Past" from 7 PM onward.
  DateTime _bookingEndDateTime(Booking booking) {
    final parts = booking.endTime.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      h,
      m,
    );
  }

  /// Three-way bucket the bookings stream lands in. Cancelled rows
  /// always belong to Past regardless of date so they disappear from
  /// Upcoming the moment cancel succeeds.
  ({bool isUpcoming, bool isPast, bool isCancelled}) _bucketFor(
    Booking booking,
    DateTime now,
  ) {
    if (booking.isCancelled) {
      return (isUpcoming: false, isPast: true, isCancelled: true);
    }
    final endsAt = _bookingEndDateTime(booking);
    final isUpcoming =
        booking.isConfirmed && endsAt.isAfter(now);
    final isPast = booking.isConfirmed && endsAt.isBefore(now);
    return (
      isUpcoming: isUpcoming,
      isPast: isPast,
      isCancelled: false,
    );
  }

  String _tagFor(Booking booking, DateTime now) {
    if (booking.isCancelled) return 'Cancelled';
    final endsAt = _bookingEndDateTime(booking);
    if (booking.isConfirmed && endsAt.isAfter(now)) return 'Confirmed';
    return 'Completed';
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().currentUser;
    final sectionTitle = _showUpcoming ? 'Upcoming Bookings' : 'Past Bookings';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideMenuDrawer(),
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
                  Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.menu_rounded,
                          size: 34,
                          color: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 18),
                  Text(
                    'My Bookings',
                    style: AppTextStyles.pageTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const NotificationBellButton(size: 30),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Container(
                height: 56,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 241, 241),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: 'Upcoming',
                        icon: Icons.calendar_today_outlined,
                        isSelected: _showUpcoming,
                        onTap: () => setState(() => _showUpcoming = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SegmentButton(
                        label: 'Past',
                        icon: Icons.history_toggle_off_rounded,
                        isSelected: !_showUpcoming,
                        onTap: () => setState(() => _showUpcoming = false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: me == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Text('Sign in to view your bookings.'),
                      ),
                    )
                  : StreamBuilder<List<Booking>>(
                      stream: _bookingService.streamBookingsForUser(me.uid),
                      builder: (context, snapshot) {
                        final waitingFirst =
                            snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData;
                        if (waitingFirst) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final all = snapshot.data ?? const <Booking>[];
                        // Recompute "now" inside the builder so the
                        // bucketing is fresh each rebuild — a
                        // booking that ends while the user is on
                        // this page will move to Past on the next
                        // snapshot.
                        final now = DateTime.now();
                        final visible = all.where((b) {
                          final bucket = _bucketFor(b, now);
                          return _showUpcoming
                              ? bucket.isUpcoming
                              : (bucket.isPast || bucket.isCancelled);
                        }).toList();
                        // Sort:
                        //   Upcoming → soonest-end first.
                        //   Past → newest-end first (most recently
                        //   completed/cancelled at the top).
                        if (_showUpcoming) {
                          visible.sort((a, b) =>
                              _bookingEndDateTime(a)
                                  .compareTo(_bookingEndDateTime(b)));
                        } else {
                          visible.sort((a, b) =>
                              _bookingEndDateTime(b)
                                  .compareTo(_bookingEndDateTime(a)));
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.pageHorizontal,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    sectionTitle,
                                    style: AppTextStyles.sectionTitle
                                        .copyWith(fontSize: 18),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      '${visible.length} bookings',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: visible.isEmpty
                                  ? _EmptyState(showUpcoming: _showUpcoming)
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        AppSpacing.pageHorizontal,
                                        0,
                                        AppSpacing.pageHorizontal,
                                        24,
                                      ),
                                      itemCount: visible.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: 18),
                                      itemBuilder: (context, index) {
                                        final b = visible[index];
                                        final bucket = _bucketFor(b, now);
                                        final dateText = DateFormat(
                                          'EEE, MMM d, y',
                                        ).format(b.date);
                                        final timeText =
                                            '${_formatTime(context, b.startTime)}'
                                            ' - '
                                            '${_formatTime(context, b.endTime)}';
                                        return MyBookingListCard(
                                          imageUrl: b.courtImageUrl,
                                          title: b.courtName,
                                          sport: b.sportType,
                                          sportEmoji:
                                              sportEmojiFor(b.sportType),
                                          dateText: dateText,
                                          timeText: timeText,
                                          tagText: _tagFor(b, now),
                                          onTap: () =>
                                              _openBookingDetails(b),
                                          onViewDetailsTap: () =>
                                              _openBookingDetails(b),
                                          // Only future, confirmed
                                          // bookings can be cancelled.
                                          // Past + already-cancelled
                                          // rows hide the More menu.
                                          onMoreTap: bucket.isUpcoming
                                              ? () =>
                                                  _openBookingOptions(b)
                                              : null,
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
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

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool showUpcoming;
  const _EmptyState({required this.showUpcoming});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              showUpcoming ? 'No upcoming bookings' : 'No past bookings',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              showUpcoming
                  ? 'Book a court from the Courts tab to see it here.'
                  : "Bookings you've played will appear here.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
