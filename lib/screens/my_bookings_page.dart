import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import 'booking_confirmed_page.dart';
import 'notifications_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/side_menu_drawer.dart';
import '../widgets/my_booking_list_card.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  bool _showUpcoming = true;

  final List<Map<String, String>> _upcomingBookings = [
    {
      'title': 'SCU Tennis Court A',
      'sport': 'Tennis',
      'emoji': '🎾',
      'date': 'Mon, 17 Aug 2025',
      'time': '6:00 PM - 7:00 PM (1 hour)',
      'players': '4/4 Players',
      'tag': 'Open Match',
      'image': 'assets/images/courts/tenniscourt.png',
    },
    {
      'title': 'Bay Badminton Arena',
      'sport': 'Badminton',
      'emoji': '🏸',
      'date': 'Tue, 18 Aug 2025',
      'time': '6:00 PM - 7:00 PM (1 hour)',
      'players': '2/4 Players',
      'tag': 'Private Match',
      'image': 'assets/images/courts/badmintoncourt.png',
    },
    {
      'title': 'Downtown Basketball Court',
      'sport': 'Basketball',
      'emoji': '🏀',
      'date': 'Wed, 19 Aug 2025',
      'time': '6:00 PM - 7:00 PM (1 hour)',
      'players': '3/4 Players',
      'tag': 'Open Match',
      'image': 'assets/images/courts/basketballcourt.png',
    },
  ];

  final List<Map<String, String>> _pastBookings = [
    {
      'title': 'Sunnyvale Pickleball Courts',
      'sport': 'Pickleball',
      'emoji': '🎾',
      'date': 'Thu, 10 Aug 2025',
      'time': '5:00 PM - 6:00 PM (1 hour)',
      'players': '4/4 Players',
      'tag': 'Completed',
      'image': 'assets/images/courts/pickleballcourt.png',
    },
    {
      'title': 'SCU Volleyball Arena',
      'sport': 'Volleyball',
      'emoji': '🏐',
      'date': 'Fri, 11 Aug 2025',
      'time': '7:00 PM - 8:00 PM (1 hour)',
      'players': '6/6 Players',
      'tag': 'Completed',
      'image': 'assets/images/courts/volleyballcourt.png',
    },
  ];

  List<Map<String, String>> get _currentBookings =>
      _showUpcoming ? _upcomingBookings : _pastBookings;

  void _openNotificationsPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const NotificationsPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openBookingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openBookingDetails(Map<String, String> booking) {
    final totalPlayers = int.tryParse(
          booking['players']!.split('/').first.trim(),
        ) ??
        4;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => BookingConfirmedPage(
          courtName: booking['title']!,
          sport: booking['sport']!,
          sportEmoji: booking['emoji']!,
          imagePath: booking['image']!,
          dateText: booking['date']!,
          timeText: booking['time']!,
          totalPlayers: totalPlayers,
          confirmedPlayers: 1,
          playersNeeded: _showUpcoming ? 3 : 0,
          totalAmount: '\$21.80',
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onBottomNavTap(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MainShell(initialIndex: index),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitle = _showUpcoming ? 'Upcoming Bookings' : 'Past Bookings';
    final bookingCountText = '${_currentBookings.length} bookings';

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
                  IconButton(
                    onPressed: _openNotificationsPage,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 30,
                      color: AppColors.textPrimary,
                    ),
                  ),
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
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showUpcoming = true;
                          });
                        },
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                _showUpcoming ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _showUpcoming
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: _showUpcoming
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Upcoming',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _showUpcoming
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showUpcoming = false;
                          });
                        },
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                !_showUpcoming ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: !_showUpcoming
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_toggle_off_rounded,
                                size: 22,
                                color: !_showUpcoming
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Past',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: !_showUpcoming
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Row(
                children: [
                  Text(
                    sectionTitle,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
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
                      bookingCountText,
                      style: AppTextStyles.bodyMedium.copyWith(
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
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  0,
                  AppSpacing.pageHorizontal,
                  24,
                ),
                itemCount: _currentBookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final booking = _currentBookings[index];

                  return MyBookingListCard(
                    imagePath: booking['image']!,
                    title: booking['title']!,
                    sport: booking['sport']!,
                    sportEmoji: booking['emoji']!,
                    dateText: booking['date']!,
                    timeText: booking['time']!,
                    playersText: booking['players']!,
                    tagText: booking['tag']!,
                    onTap: () => _openBookingDetails(booking),
                    onViewDetailsTap: () => _openBookingDetails(booking),
                    onMoreTap: _openBookingOptions,
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