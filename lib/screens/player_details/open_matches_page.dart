import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rallyup/providers/auth_provider.dart';
import 'package:rallyup/screens/main_shell_nav.dart';
import 'package:rallyup/screens/player_details/match_details_page.dart';
import 'package:rallyup/services/location_picker_handler.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/courts/court_search_bar.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/notification_bell_button.dart';
import '../../widgets/side_menu_drawer.dart';
import '../../widgets/sports_card.dart';
import '../../widgets/player_details/open_matches/open_match_card.dart';

class OpenMatchesPage extends StatefulWidget {
  const OpenMatchesPage({super.key});

  @override
  State<OpenMatchesPage> createState() => _OpenMatchesPageState();
}

class _OpenMatchesPageState extends State<OpenMatchesPage> {
  String _selectedSport = 'All';
  String _selectedSort = 'default';
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _favoriteMatches = {};

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

  final List<Map<String, String>> _allMatches = const [
    {
      'id': 'match_tennis_1',
      'title': 'SCU Evening Tennis Match',
      'sport': 'Tennis',
      'emoji': '🎾',
      'image': 'assets/images/player_details/open_matches/tennis_court.png',
      'when': 'Today, 6:00 PM',
      'location': 'SCU Tennis Court A',
      'address': '500 El Camino Real, Santa Clara, CA',
      'players': '3 / 4',
      'level': 'Intermediate',
      'host': 'Alex',
      'spots': '1 spot left',
      'hostAvatar': 'assets/images/player_details/open_matches/alex_avatar.png',
      'about':
          'Looking for 1 more player for a fun evening doubles match. Let us have a great game!',
    },
    {
      'id': 'match_badminton_1',
      'title': 'Bay Badminton Doubles',
      'sport': 'Badminton',
      'emoji': '🏸',
      'image': 'assets/images/player_details/open_matches/badminton_court.png',
      'when': 'Tomorrow, 7:00 PM',
      'location': 'Bay Badminton Arena',
      'address': '123 Lawrence Expwy, Sunnyvale, CA',
      'players': '2 / 4',
      'level': 'Beginner',
      'host': 'Priya',
      'spots': '2 spots left',
      'hostAvatar':
          'assets/images/player_details/open_matches/priya_avatar.png',
      'about':
          'Beginner-friendly doubles game. Looking for two more players to join and have a relaxed match.',
    },
    {
      'id': 'match_basketball_1',
      'title': 'Weekend Basketball Run',
      'sport': 'Basketball',
      'emoji': '🏀',
      'image': 'assets/images/player_details/open_matches/basketball_court.png',
      'when': 'Sun, 4:00 PM',
      'location': 'Downtown Basketball Court',
      'address': '456 Market St, San Jose, CA',
      'players': '7 / 10',
      'level': 'Casual',
      'host': 'Kevin',
      'spots': '3 spots left',
      'hostAvatar':
          'assets/images/player_details/open_matches/kevin_avatar.png',
      'about':
          'Weekend basketball run with a casual group. Open to all players who want to join.',
    },
    {
      'id': 'match_badminton_2',
      'title': 'Late Night Badminton Rally',
      'sport': 'Badminton',
      'emoji': '🏸',
      'image': 'assets/images/player_details/open_matches/badminton_court.png',
      'when': 'Fri, 8:30 PM',
      'location': 'Bay Badminton Arena',
      'address': '123 Lawrence Expwy, Sunnyvale, CA',
      'players': '2 / 4',
      'level': 'Intermediate',
      'host': 'Priya',
      'spots': '2 spots left',
      'hostAvatar':
          'assets/images/player_details/open_matches/priya_avatar.png',
      'about':
          'Intermediate badminton doubles session with a fun competitive vibe.',
    },
  ];

  List<Map<String, String>> get _filteredMatches {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _allMatches.where((match) {
      final matchesSport =
          _selectedSport == 'All' || match['sport'] == _selectedSport;

      final title = match['title']!.toLowerCase();
      final sport = match['sport']!.toLowerCase();
      final location = match['location']!.toLowerCase();
      final host = match['host']!.toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          sport.contains(query) ||
          location.contains(query) ||
          host.contains(query);

      return matchesSport && matchesSearch;
    }).toList();

    if (_selectedSort == 'distance') {
      filtered.sort((a, b) => _extractSpotsNumber(a['spots']!).compareTo(
            _extractSpotsNumber(b['spots']!),
          ));
    } else if (_selectedSort == 'rating') {
      filtered.sort((a, b) => _extractPlayersJoined(b['players']!).compareTo(
            _extractPlayersJoined(a['players']!),
          ));
    } else if (_selectedSort == 'price_low') {
      filtered.sort((a, b) => a['title']!.compareTo(b['title']!));
    } else if (_selectedSort == 'slots') {
      filtered.sort((a, b) => _extractSpotsNumber(b['spots']!).compareTo(
            _extractSpotsNumber(a['spots']!),
          ));
    }

    return filtered;
  }

  double _extractSpotsNumber(String text) {
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(text);
    return double.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  double _extractPlayersJoined(String text) {
    final match = RegExp(r'(\d+)\s*/').firstMatch(text);
    return double.tryParse(match?.group(1) ?? '0') ?? 0;
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

  Color _getSpotColor(String label) {
    if (label.contains('1')) return AppColors.primary;
    if (label.contains('2')) return const Color(0xFFD97706);
    if (label.contains('3')) return AppColors.warning;
    return AppColors.primary;
  }

  Future<void> _openLocationOverlay() => openLocationPicker(context);

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort & Filter',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 16),
              _FilterOptionTile(
                title: 'Default',
                isSelected: _selectedSort == 'default',
                onTap: () {
                  setState(() {
                    _selectedSort = 'default';
                  });
                  Navigator.pop(context);
                },
              ),
              _FilterOptionTile(
                title: 'Nearest Distance',
                isSelected: _selectedSort == 'distance',
                onTap: () {
                  setState(() {
                    _selectedSort = 'distance';
                  });
                  Navigator.pop(context);
                },
              ),
              _FilterOptionTile(
                title: 'Highest Rating',
                isSelected: _selectedSort == 'rating',
                onTap: () {
                  setState(() {
                    _selectedSort = 'rating';
                  });
                  Navigator.pop(context);
                },
              ),
              _FilterOptionTile(
                title: 'Lowest Price',
                isSelected: _selectedSort == 'price_low',
                onTap: () {
                  setState(() {
                    _selectedSort = 'price_low';
                  });
                  Navigator.pop(context);
                },
              ),
              _FilterOptionTile(
                title: 'Most Available Slots',
                isSelected: _selectedSort == 'slots',
                onTap: () {
                  setState(() {
                    _selectedSort = 'slots';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleFavorite(String matchId) {
    setState(() {
      if (_favoriteMatches.contains(matchId)) {
        _favoriteMatches.remove(matchId);
      } else {
        _favoriteMatches.add(matchId);
      }
    });
  }

  void _openMatchDetails(Map<String, String> match) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MatchDetailsPage(
          title: match['title']!,
          sport: match['sport']!,
          sportEmoji: match['emoji']!,
          when: match['when']!,
          location: match['location']!,
          address: match['address']!,
          players: match['players']!,
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

  void _onBottomNavTap(int index) {
    switchToMainShellTab(context, index);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _filteredMatches;
    final locationLabel = context
            .watch<AuthProvider>()
            .currentUser
            ?.location
            ?.displayLabel ??
        'Set location';

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
                6,
              ),
              child: Column(
                children: [
                  Row(
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
                        'Open Matches',
                        style: AppTextStyles.pageTitle.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const NotificationBellButton(size: 30),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _openLocationOverlay,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locationLabel,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CourtSearchBar(
                    controller: _searchController,
                    hintText: 'Search open matches',
                    onChanged: (_) => setState(() {}),
                    onFilterTap: _openFilterSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Text(
                      'Open Matches Near You',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (matches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'No open matches found',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try another sport or search term',
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
                  else
                    ...matches.map(
                      (match) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: OpenMatchCard(
                          imagePath: match['image']!,
                          title: match['title']!,
                          sport: match['sport']!,
                          sportEmoji: match['emoji']!,
                          when: match['when']!,
                          location: match['location']!,
                          players: match['players']!,
                          level: match['level']!,
                          host: match['host']!,
                          spotLabel: match['spots']!,
                          spotColor: _getSpotColor(match['spots']!),
                          hostAvatarPath: match['hostAvatar']!,
                          isFavorite: _favoriteMatches.contains(match['id']!),
                          onJoinTap: () => _openMatchDetails(match),
                          onFavoriteTap: () => _toggleFavorite(match['id']!),
                        ),
                      ),
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

class _FilterOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}