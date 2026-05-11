import 'package:flutter/material.dart';
import 'package:rallyup/screens/booking_confirmed_page.dart';
import 'package:rallyup/screens/my_bookings_page.dart';
import 'package:rallyup/screens/notifications_page.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/booking_preview_card.dart';
import '../../widgets/home_top_header.dart';
import '../../widgets/location_picker_sheet.dart';
import '../../widgets/sports_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedSport = 'All';
  String _selectedLocation = 'Santa Clara, CA';

  final List<String> _sports = const [
    'Tennis',
    'Badminton',
    'Table Tennis',
    'Basketball',
    'Volleyball',
    'Pickleball',
    'Soccer',
    'Football',
    'Cricket',
    'Swimming',
  ];

  List<Map<String, String>> get _allBookings => [
        {
          'sport': 'Tennis',
          'title': 'SCU Tennis Court A',
          'image': 'assets/images/courts/tenniscourt.png',
          'date': 'Mon, 17 Aug 2025',
          'time': '6:00 PM - 7:00 PM (1 hour)',
        },
        {
          'sport': 'Badminton',
          'title': 'Bay Badminton Arena',
          'image': 'assets/images/courts/badmintoncourt.png',
          'date': 'Tue, 18 Aug 2025',
          'time': '6:00 PM - 7:00 PM (1 hour)',
        },
        {
          'sport': 'Basketball',
          'title': 'Downtown Basketball Court',
          'image': 'assets/images/courts/basketballcourt.png',
          'date': 'Wed, 19 Aug 2025',
          'time': '6:00 PM - 7:00 PM (1 hour)',
        },
        {
          'sport': 'Pickleball',
          'title': 'Sunnyvale Pickleball Courts',
          'image': 'assets/images/courts/pickleballcourt.png',
          'date': 'Thu, 20 Aug 2025',
          'time': '7:00 PM - 8:00 PM (1 hour)',
        },
      ];

  List<Map<String, String>> get _filteredBookings {
    if (_selectedSport == 'All') return _allBookings;
    return _allBookings
        .where((booking) => booking['sport'] == _selectedSport)
        .toList();
  }

  String _getSportImagePath(String sport) {
    switch (sport) {
      case 'Tennis':
        return 'assets/images/sports/tennis.png';
      case 'Badminton':
        return 'assets/images/sports/badminton.png';
      case 'Table Tennis':
        return 'assets/images/sports/table_tennis.png';
      case 'Basketball':
        return 'assets/images/sports/basketball.png';
      case 'Volleyball':
        return 'assets/images/sports/volleyball.png';
      case 'Pickleball':
        return 'assets/images/sports/pickleball.png';
      case 'Soccer':
        return 'assets/images/sports/soccer.png';
      case 'Football':
        return 'assets/images/sports/football.png';
      case 'Cricket':
        return 'assets/images/sports/cricket.png';
      case 'Swimming':
        return 'assets/images/sports/swimming.png';
      default:
        return '';
    }
  }

  String _getSportEmoji(String sport) {
    switch (sport) {
      case 'Tennis':
        return '🎾';
      case 'Badminton':
        return '🏸';
      case 'Basketball':
        return '🏀';
      case 'Volleyball':
        return '🏐';
      case 'Pickleball':
        return '🎾';
      case 'Soccer':
        return '⚽';
      case 'Football':
        return '🏈';
      case 'Cricket':
        return '🏏';
      case 'Swimming':
        return '🏊';
      case 'Table Tennis':
        return '🏓';
      default:
        return '🎾';
    }
  }

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

  void _openProfileOptionsOverlay() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 82,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 158,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(18, 0, 0, 0),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _ProfileOptionTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                      ),
                      _ProfileOptionTile(
                        icon: Icons.card_membership_rounded,
                        title: 'Membership',
                      ),
                      Divider(height: 1),
                      _ProfileOptionTile(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        isDanger: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLocationOverlay() async {
    final pickedLocation = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LocationPickerSheet(
          selectedLocation: _selectedLocation,
        );
      },
    );

    if (pickedLocation != null) {
      setState(() {
        _selectedLocation = pickedLocation;
      });
    }
  }

  void _openMyBookingsPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MyBookingsPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openBookingConfirmedPage(Map<String, String> booking) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => BookingConfirmedPage(
          courtName: booking['title']!,
          sport: booking['sport']!,
          sportEmoji: _getSportEmoji(booking['sport']!),
          imagePath: booking['image']!,
          dateText: booking['date']!,
          timeText: booking['time']!,
          totalPlayers: 4,
          confirmedPlayers: 1,
          playersNeeded: 3,
          totalAmount: '\$21.80',
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HomeTopHeader(
              userName: 'Person name',
              locationText: _selectedLocation,
              profileImagePath: null,
              onNotificationTap: _openNotificationsPage,
              onProfileTap: _openProfileOptionsOverlay,
              onLocationTap: _openLocationOverlay,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'All Sports',
                  style: AppTextStyles.sectionTitle,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 140,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _sports.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return SportsCard(
                      isAllCard: true,
                      isSelected: _selectedSport == 'All',
                      onTap: () {
                        setState(() {
                          _selectedSport = 'All';
                        });
                      },
                    );
                  }

                  final sport = _sports[index - 1];

                  return SportsCard(
                    imagePath: _getSportImagePath(sport),
                    isSelected: _selectedSport == sport,
                    onTap: () {
                      setState(() {
                        _selectedSport = sport;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'My Bookings',
                          style: AppTextStyles.sectionTitle,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _openMyBookingsPage,
                          child: Text(
                            'View All',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 220,
                    child: _filteredBookings.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'No bookings yet',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Try booking a court for this sport',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: _filteredBookings.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final booking = _filteredBookings[index];

                              return BookingPreviewCard(
                                imagePath: booking['image']!,
                                title: booking['title']!,
                                sport: booking['sport']!,
                                dateText: booking['date']!,
                                timeText: booking['time']!,
                                onTap: () => _openBookingConfirmedPage(booking),
                                onViewDetailsTap: () =>
                                    _openBookingConfirmedPage(booking),
                              );
                            },
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
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.redAccent : AppColors.textPrimary;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}