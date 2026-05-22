import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/providers/auth_provider.dart';
import 'package:rallyup/screens/booking_confirmed_page.dart';
import 'package:rallyup/screens/court_details_page.dart';
import 'package:rallyup/screens/courts_page.dart';
import 'package:rallyup/screens/my_bookings_page.dart';
import 'package:rallyup/screens/notifications_page.dart';
import 'package:rallyup/screens/player_details/match_details_page.dart';
import 'package:rallyup/screens/player_details/message_page.dart';
import 'package:rallyup/screens/player_details/nearby_players_page.dart';
import 'package:rallyup/screens/player_details/open_matches_page.dart';
import 'package:rallyup/screens/profile/subscription_screen.dart';
import 'package:rallyup/services/location_picker_handler.dart';
import 'package:rallyup/services/location_service.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/booking_preview_card.dart';
import '../../widgets/home/home_nearby_player_preview_card.dart';
import '../../widgets/home/home_section_header.dart';
import '../../widgets/home/home_suggested_court_preview_card.dart';
import '../../widgets/home/home_suggested_open_match_preview_card.dart';
import '../../widgets/home_top_header.dart';
import '../../widgets/sports_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedSport = 'All';

  final LocationService _locationService = LocationService();
  bool _locationCaptureStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoFetchLocation();
    });
  }

  /// Fires once per HomePage lifetime, only if the signed-in user has no
  /// stored location yet. Silent on permission denial — the user can tap
  /// the location chip in the header to retry.
  Future<void> _maybeAutoFetchLocation() async {
    if (_locationCaptureStarted) return;
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null || user.location != null) return;
    _locationCaptureStarted = true;
    try {
      final captured = await _locationService.captureCurrent();
      if (!mounted) return;
      await auth.updateLocation(captured);
    } catch (_) {
      // Permission denied, service off, or geocoding failed. Keep the
      // "Set location" fallback; user can retry via the picker.
    }
  }

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
      ];

  List<Map<String, String>> get _allNearbyPlayers => [
        {
          'name': 'Alex Johnson',
          'age': '24',
          'sport': 'Tennis',
          'initials': 'AJ',
        },
        {
          'name': 'Priya Shah',
          'age': '26',
          'sport': 'Badminton',
          'initials': 'PS',
        },
      ];

  List<Map<String, String>> get _allSuggestedCourts => [
        {
          'title': 'SCU Tennis Court A',
          'sport': 'Tennis',
          'emoji': '🎾',
          'image': 'assets/images/courts/tenniscourt.png',
          'distance': '1.2 mi away',
          'rating': '4.6',
          'price': '\$22/hr',
          'slots': '2 slots today',
        },
        {
          'title': 'Bay Badminton Arena',
          'sport': 'Badminton',
          'emoji': '🏸',
          'image': 'assets/images/courts/badmintoncourt.png',
          'distance': '1.2 mi away',
          'rating': '4.6',
          'price': '\$16/hr',
          'slots': '6 slots today',
        },
        {
          'title': 'Downtown Basketball Court',
          'sport': 'Basketball',
          'emoji': '🏀',
          'image': 'assets/images/courts/basketballcourt.png',
          'distance': '2.4 mi away',
          'rating': '4.6',
          'price': '\$20/hr',
          'slots': '3 slots today',
        },
      ];

  List<Map<String, String>> get _allSuggestedOpenMatches => [
        {
          'title': 'SCU Tennis Court A',
          'sport': 'Tennis',
          'emoji': '🎾',
          'image': 'assets/images/player_details/open_matches/tennis_court.png',
          'date': 'Mon, 17 Aug 2025',
          'time': '6:00 PM',
          'players': '3/4 players',
          'location': 'SCU Tennis Court A',
          'address': '500 El Camino Real, Santa Clara, CA',
          'level': 'Intermediate',
          'host': 'Alex',
          'hostAvatar':
              'assets/images/player_details/open_matches/alex_avatar.png',
          'about':
              'Looking for 1 more player for a fun evening doubles match. Let us have a great game!',
          'spots': '1 spot left',
        },
        {
          'title': 'Bay Badminton Area',
          'sport': 'Badminton',
          'emoji': '🏸',
          'image':
              'assets/images/player_details/open_matches/badminton_court.png',
          'date': 'Mon, 18 Aug 2025',
          'time': '6:00 PM',
          'players': '2/4 players',
          'location': 'Bay Badminton Arena',
          'address': '123 Lawrence Expwy, Sunnyvale, CA',
          'level': 'Beginner',
          'host': 'Priya',
          'hostAvatar':
              'assets/images/player_details/open_matches/priya_avatar.png',
          'about':
              'Beginner-friendly doubles game. Looking for two more players to join and have a relaxed match.',
          'spots': '2 spots left',
        },
        {
          'title': 'Downtown Basketball Run',
          'sport': 'Basketball',
          'emoji': '🏀',
          'image':
              'assets/images/player_details/open_matches/basketball_court.png',
          'date': 'Mon, 19 Aug 2025',
          'time': '6:00 PM',
          'players': '7/10 players',
          'location': 'Downtown Basketball Court',
          'address': '456 Market St, San Jose, CA',
          'level': 'Casual',
          'host': 'Kevin',
          'hostAvatar':
              'assets/images/player_details/open_matches/kevin_avatar.png',
          'about':
              'Weekend basketball run with a casual group. Open to all players who want to join.',
          'spots': '3 spots left',
        },
      ];

  List<Map<String, String>> get _filteredBookings {
    if (_selectedSport == 'All') return _allBookings;
    return _allBookings
        .where((booking) => booking['sport'] == _selectedSport)
        .toList();
  }

  List<Map<String, String>> get _filteredNearbyPlayers {
    if (_selectedSport == 'All') return _allNearbyPlayers;
    return _allNearbyPlayers
        .where((player) => player['sport'] == _selectedSport)
        .toList();
  }

  List<Map<String, String>> get _filteredSuggestedCourts {
    if (_selectedSport == 'All') return _allSuggestedCourts;
    return _allSuggestedCourts
        .where((court) => court['sport'] == _selectedSport)
        .toList();
  }

  List<Map<String, String>> get _filteredSuggestedOpenMatches {
    if (_selectedSport == 'All') return _allSuggestedOpenMatches;
    return _allSuggestedOpenMatches
        .where((match) => match['sport'] == _selectedSport)
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

  Future<void> _performLogout(BuildContext context) async {
    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;
    // AuthGate now reports unauthenticated. Pop everything pushed above it.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4A4A4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Log out?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              fontSize: 16,
            ),
          ),
          content: Text(
            'Are you sure you want\nto logout of your\naccount?',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _performLogout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
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

  void _openProfilePage() {
    // Switch to the existing MainShell's Profile tab instead of pushing a
    // new MainShell. The old `pushAndRemoveUntil((route) => false)` popped
    // AuthGate off the stack, which broke sign-out gating and made the UI
    // lose track of the current user mid-session.
    Navigator.of(context).popUntil((route) => route.isFirst);
    MainShell.globalKey.currentState?.switchTo(2);
  }

  void _openMembershipPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const SubscriptionScreen(),
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
                  width: 200,
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
                    children: [
                      _ProfileOptionTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                        onTap: () {
                          Navigator.pop(context);
                          _openProfilePage();
                        },
                      ),
                      _ProfileOptionTile(
                        icon: Icons.card_membership_rounded,
                        title: 'Membership',
                        onTap: () {
                          Navigator.pop(context);
                          _openMembershipPage();
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileOptionTile(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        isDanger: true,
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(this.context);
                        },
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

  Future<void> _openLocationOverlay() => openLocationPicker(context);

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

  void _openNearbyPlayersPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const NearbyPlayersPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openCourtsPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CourtsPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openOpenMatchesPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const OpenMatchesPage(),
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

  void _openPersonalMessagePage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MessagePage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openCourtDetailsPage(Map<String, String> court) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => CourtDetailsPage(
          courtName: court['title']!,
          sport: court['sport']!,
          sportEmoji: court['emoji']!,
          imagePath: court['image']!,
          distanceText: court['distance']!,
          ratingText: court['rating']!,
          priceText: court['price']!,
          locationText: context.read<AuthProvider>().currentUser?.location
                  ?.displayLabel ??
              '',
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openMatchDetailsPage(Map<String, String> match) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MatchDetailsPage(
          title: match['title']!,
          sport: match['sport']!,
          sportEmoji: match['emoji']!,
          when: '${match['date']}, ${match['time']}',
          location: match['location']!,
          address: match['address']!,
          players: match['players']!.replaceAll(' players', ''),
          level: match['level']!,
          host: match['host']!,
          imagePath: match['image']!,
          hostAvatarPath: match['hostAvatar']!,
          about: match['about']!,
          spotsLeftLabel: match['spots']!,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    // Same rationale as profile_page: render nothing while AuthGate is
    // about to swap us out for SignupScreen. SizedBox.shrink() (instead
    // of an opaque Scaffold) makes this a non-event visually — if this
    // build happens to land before AuthGate's repaint, the user never
    // sees a blank background page.
    if (currentUser == null) {
      return const SizedBox.shrink();
    }
    final bookings = _filteredBookings;
    final nearbyPlayers = _filteredNearbyPlayers;
    final suggestedCourts = _filteredSuggestedCourts;
    final suggestedOpenMatches = _filteredSuggestedOpenMatches;
    final firstName = currentUser.firstName;
    final initials = currentUser.initials;
    final avatarId = currentUser.avatarId;
    final locationLabel =
        currentUser.location?.displayLabel ?? 'Set location';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HomeTopHeader(
              firstName: firstName,
              initials: initials,
              avatarId: avatarId,
              photoUrl: currentUser.photoUrl,
              locationText: locationLabel,
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
                separatorBuilder: (_, _) =>
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
                  HomeSectionHeader(
                    title: 'My Bookings',
                    onViewAllTap: _openMyBookingsPage,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 232,
                    child: bookings.isEmpty
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
                            itemCount: bookings.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final booking = bookings[index];

                              return BookingPreviewCard(
                                imagePath: booking['image']!,
                                title: booking['title']!,
                                sport: booking['sport']!,
                                dateText: booking['date']!,
                                timeText: booking['time']!,
                                onTap: null,
                                onViewDetailsTap: () =>
                                    _openBookingConfirmedPage(booking),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 26),
                  HomeSectionHeader(
                    title: 'Nearby Players',
                    onViewAllTap: _openNearbyPlayersPage,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 134,
                    child: nearbyPlayers.isEmpty
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
                                child: Text(
                                  'No nearby players for this sport',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: nearbyPlayers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final player = nearbyPlayers[index];
                              return HomeNearbyPlayerPreviewCard(
                                name: player['name']!,
                                age: player['age']!,
                                sport: player['sport']!,
                                initials: player['initials']!,
                                onConnectTap: _openPersonalMessagePage,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 26),
                  HomeSectionHeader(
                    title: 'Suggested Courts',
                    onViewAllTap: _openCourtsPage,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 246,
                    child: suggestedCourts.isEmpty
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
                                child: Text(
                                  'No suggested courts for this sport',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: suggestedCourts.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final court = suggestedCourts[index];
                              return HomeSuggestedCourtPreviewCard(
                                imagePath: court['image']!,
                                sport: court['sport']!,
                                distanceText: court['distance']!,
                                ratingText: court['rating']!,
                                onViewDetailsTap: () =>
                                    _openCourtDetailsPage(court),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 26),
                  HomeSectionHeader(
                    title: 'Suggested Open Matches',
                    onViewAllTap: _openOpenMatchesPage,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 252,
                    child: suggestedOpenMatches.isEmpty
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
                                child: Text(
                                  'No open matches for this sport',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: suggestedOpenMatches.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final match = suggestedOpenMatches[index];
                              return HomeSuggestedOpenMatchPreviewCard(
                                imagePath: match['image']!,
                                title: match['title']!,
                                sport: match['sport']!,
                                players: match['players']!,
                                dateText: match['date']!,
                                timeText: match['time']!,
                                onViewDetailsTap: () =>
                                    _openMatchDetailsPage(match),
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
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.redAccent : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}