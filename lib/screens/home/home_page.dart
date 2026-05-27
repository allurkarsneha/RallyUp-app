import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rallyup/main.dart';
import 'package:intl/intl.dart';
import 'package:rallyup/models/app_user.dart';
import 'package:rallyup/models/booking.dart';
import 'package:rallyup/models/court.dart';
import 'package:rallyup/models/user_location.dart';
import 'package:rallyup/providers/auth_provider.dart';
import 'package:rallyup/screens/booking_confirmed_page.dart';
import 'package:rallyup/screens/court_details_page.dart';
import 'package:rallyup/screens/courts_page.dart';
import 'package:rallyup/screens/my_bookings_page.dart';
import 'package:rallyup/screens/player_details/match_details_page.dart';
import 'package:rallyup/screens/player_details/nearby_players_page.dart';
import 'package:rallyup/screens/player_details/open_matches_page.dart';
import 'package:rallyup/screens/player_details/player_profile_page.dart';
import 'package:rallyup/screens/profile/subscription_screen.dart';
import 'package:rallyup/screens/logout_helper.dart';
import 'package:rallyup/services/booking_service.dart';
import 'package:rallyup/services/court_service.dart';
import 'package:rallyup/services/location_picker_handler.dart';
import 'package:rallyup/services/location_service.dart';
import 'package:rallyup/services/user_service.dart';
import 'package:rallyup/utils/sport_emoji.dart';

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
  final UserService _userService = UserService();
  final CourtService _courtService = CourtService();
  final BookingService _bookingService = BookingService();
  bool _locationCaptureStarted = false;

  // Maximum entries in the home preview row; "View all" goes to the
  // full NearbyPlayersPage if the user wants more.
  static const int _homeNearbyPreviewLimit = 6;

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

  /// Returns the subset of streamed users that should appear in the
  /// home preview. When a specific sport is selected, players whose
  /// `sports` list contains that sport surface first; users with a
  /// matching same-city location come next so the preview matches what
  /// `NearbyPlayersPage` shows at the top of its list.
  List<_HomeRankedPlayer> _rankForHome(
    List<AppUser> users,
    UserLocation? myLocation,
  ) {
    final filtered = _selectedSport == 'All'
        ? users
        : users
            .where(
              (u) => u.sports.any(
                (s) => s.toLowerCase() == _selectedSport.toLowerCase(),
              ),
            )
            .toList();
    final ranked = filtered
        .map((u) => _HomeRankedPlayer.from(u, myLocation))
        .toList()
      ..sort((a, b) {
        if (a.sameCity != b.sameCity) return a.sameCity ? -1 : 1;
        final aD = a.distanceKm ?? double.infinity;
        final bD = b.distanceKm ?? double.infinity;
        return aD.compareTo(bD);
      });
    return ranked.length > _homeNearbyPreviewLimit
        ? ranked.sublist(0, _homeNearbyPreviewLimit)
        : ranked;
  }

  String _primarySport(AppUser u) =>
      u.sports.isEmpty ? 'Multi-sport' : u.sports.first;

  void _openPlayerProfileFromHome(_HomeRankedPlayer ranked) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => PlayerProfilePage(
          user: ranked.user,
          distance: ranked.distanceLabel,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Same-city-first / nearest-first ranking applied to the real
  /// court stream feeding the home "Suggested Courts" rail. Sport
  /// filter uses `sportTypes.contains(...)` so multi-sport venues
  /// surface for every supported sport.
  List<_HomeRankedCourt> _rankCourts(
    List<Court> courts,
    UserLocation? myLocation,
  ) {
    final filtered = _selectedSport == 'All'
        ? courts
        : courts
            .where(
              (c) => c.sportTypes.any(
                (s) => s.toLowerCase() == _selectedSport.toLowerCase(),
              ),
            )
            .toList();
    final ranked =
        filtered.map((c) => _HomeRankedCourt.from(c, myLocation)).toList()
          ..sort((a, b) {
            if (a.sameCity != b.sameCity) return a.sameCity ? -1 : 1;
            final aD = a.distanceKm ?? double.infinity;
            final bD = b.distanceKm ?? double.infinity;
            return aD.compareTo(bD);
          });
    const homeCourtsLimit = 6;
    return ranked.length > homeCourtsLimit
        ? ranked.sublist(0, homeCourtsLimit)
        : ranked;
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

  Future<void> _performLogout(BuildContext context) async {
    await performLogout(context);
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

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _fmtClock(BuildContext context, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: h, minute: m));
  }

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

  void _openCourtDetails(_HomeRankedCourt ranked) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => CourtDetailsPage(
          court: ranked.court,
          distanceText: ranked.distanceText,
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
                    child: StreamBuilder<List<Booking>>(
                      stream:
                          _bookingService.streamBookingsForUser(currentUser.uid),
                      builder: (context, snapshot) {
                        final waitingFirst = snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData;
                        if (waitingFirst) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final todayStart = _startOfToday();
                        final upcoming = (snapshot.data ?? const <Booking>[])
                            .where((b) =>
                                !b.isCancelled &&
                                !b.date.isBefore(todayStart))
                            .toList()
                          // Soonest first matches MyBookingsPage's
                          // upcoming-tab ordering.
                          ..sort((a, b) {
                            final byDate = a.date.compareTo(b.date);
                            if (byDate != 0) return byDate;
                            return a.startTime.compareTo(b.startTime);
                          });
                        // Filter by selected sport AFTER the upcoming
                        // filter so the rail still shows other-sport
                        // bookings when "All" is selected.
                        final filtered = _selectedSport == 'All'
                            ? upcoming
                            : upcoming
                                .where((b) =>
                                    b.sportType.toLowerCase() ==
                                    _selectedSport.toLowerCase())
                                .toList();
                        final preview = filtered.take(6).toList();

                        if (preview.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: AppColors.border),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'No bookings yet',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Book a court to see it here',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: preview.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final booking = preview[index];
                            final dateText = DateFormat(
                              'EEE, MMM d',
                            ).format(booking.date);
                            final timeText =
                                '${_fmtClock(context, booking.startTime)}'
                                ' - '
                                '${_fmtClock(context, booking.endTime)}';
                            return BookingPreviewCard(
                              imageUrl: booking.courtImageUrl,
                              title: booking.courtName,
                              sport:
                                  '${sportEmojiFor(booking.sportType)}  '
                                  '${booking.sportType}',
                              dateText: dateText,
                              timeText: timeText,
                              onTap: () => _openBookingDetails(booking),
                              onViewDetailsTap: () =>
                                  _openBookingDetails(booking),
                            );
                          },
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
                    child: StreamBuilder<List<AppUser>>(
                      stream: _userService.streamAllUsers(
                        excludeUid: currentUser.uid,
                      ),
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
                        final ranked = _rankForHome(
                          snapshot.data ?? const <AppUser>[],
                          currentUser.location,
                        );
                        if (ranked.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: AppColors.border),
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
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: ranked.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final r = ranked[index];
                            final subtitleParts = <String>[
                              _primarySport(r.user),
                              r.distanceLabel,
                            ].where((s) => s.isNotEmpty).toList();
                            return HomeNearbyPlayerPreviewCard(
                              name: r.user.displayName,
                              subtitle: subtitleParts.join('  •  '),
                              initials: r.user.initials,
                              photoUrl: r.user.photoUrl,
                              avatarId: r.user.avatarId,
                              onConnectTap: () =>
                                  _openPlayerProfileFromHome(r),
                            );
                          },
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
                    child: StreamBuilder<List<Court>>(
                      stream: _courtService.streamActiveCourts(),
                      builder: (context, snapshot) {
                        final waitingFirst = snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData;
                        if (waitingFirst) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final ranked = _rankCourts(
                          snapshot.data ?? const <Court>[],
                          currentUser.location,
                        );
                        if (ranked.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: AppColors.border),
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
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: ranked.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final r = ranked[index];
                            // Sport label: when a sport is selected
                            // and supported, show that; otherwise show
                            // the court's first sport so the rail
                            // never reads as "Tennis" for a basketball
                            // court.
                            final sportLabel = _selectedSport != 'All' &&
                                    r.court.sportTypes.any((s) =>
                                        s.toLowerCase() ==
                                        _selectedSport.toLowerCase())
                                ? _selectedSport
                                : (r.court.sportTypes.isNotEmpty
                                    ? r.court.sportTypes.first
                                    : 'Tennis');
                            return HomeSuggestedCourtPreviewCard(
                              imageUrl: r.court.imageUrls.isNotEmpty
                                  ? r.court.imageUrls.first
                                  : null,
                              sport:
                                  '${sportEmojiFor(sportLabel)}  $sportLabel',
                              distanceText: r.distanceText,
                              ratingText: (r.court.rating ?? 0)
                                  .toStringAsFixed(1),
                              onViewDetailsTap: () => _openCourtDetails(r),
                            );
                          },
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

/// View model that pairs a real [AppUser] with the distance bookkeeping
/// the home preview needs. Distance + same-city logic is intentionally
/// duplicated from `nearby_players_page.dart`'s private `_RankedPlayer`
/// rather than refactored into a shared helper — the spec for this bug
/// fix said "minimally duplicate safe logic; do not do a large refactor."
class _HomeRankedPlayer {
  final AppUser user;
  final double? distanceKm;
  final bool sameCity;

  const _HomeRankedPlayer({
    required this.user,
    required this.distanceKm,
    required this.sameCity,
  });

  factory _HomeRankedPlayer.from(AppUser u, UserLocation? me) {
    if (me == null || u.location == null) {
      return _HomeRankedPlayer(user: u, distanceKm: null, sameCity: false);
    }
    return _HomeRankedPlayer(
      user: u,
      distanceKm: _haversineKm(me.lat, me.lng, u.location!.lat, u.location!.lng),
      sameCity: u.location!.city.isNotEmpty &&
          u.location!.city.toLowerCase() == me.city.toLowerCase(),
    );
  }

  String get distanceLabel {
    if (distanceKm == null) {
      return user.location?.displayLabel ?? 'Location unavailable';
    }
    final mi = distanceKm! * 0.621371;
    if (mi < 0.1) return '< 0.1 mi';
    return '${mi.toStringAsFixed(1)} mi';
  }
}

double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  double toRad(double d) => d * math.pi / 180;
  final dLat = toRad(lat2 - lat1);
  final dLng = toRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(toRad(lat1)) *
          math.cos(toRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * r * math.asin(math.sqrt(a));
}

/// Court-side analogue of [_HomeRankedPlayer]. Carries the
/// pre-computed distance label so the home preview tile reads the
/// same as the Courts tab list rather than re-doing haversine math
/// per render.
class _HomeRankedCourt {
  final Court court;
  final double? distanceKm;
  final bool sameCity;

  const _HomeRankedCourt({
    required this.court,
    required this.distanceKm,
    required this.sameCity,
  });

  factory _HomeRankedCourt.from(Court court, UserLocation? me) {
    if (me == null) {
      return _HomeRankedCourt(
        court: court,
        distanceKm: null,
        sameCity: false,
      );
    }
    return _HomeRankedCourt(
      court: court,
      distanceKm: _haversineKm(me.lat, me.lng, court.lat, court.lng),
      sameCity: me.city.isNotEmpty &&
          me.city.toLowerCase() == court.city.toLowerCase(),
    );
  }

  String get distanceText {
    if (distanceKm == null) return court.city;
    final mi = distanceKm! * 0.621371;
    if (mi < 0.1) return '< 0.1 mi away';
    return '${mi.toStringAsFixed(1)} mi away';
  }
}