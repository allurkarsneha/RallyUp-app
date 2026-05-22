import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/providers/auth_provider.dart';
import 'package:rallyup/screens/notifications_page.dart';
import 'package:rallyup/screens/player_details/message_page.dart';
import 'package:rallyup/screens/player_details/player_profile_page.dart';
import 'package:rallyup/services/location_picker_handler.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/courts/court_search_bar.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/player_details/player_details_components.dart';
import '../../widgets/side_menu_drawer.dart';
import '../../widgets/sports_card.dart';

class NearbyPlayersPage extends StatefulWidget {
  const NearbyPlayersPage({super.key});

  @override
  State<NearbyPlayersPage> createState() => _NearbyPlayersPageState();
}

class _NearbyPlayersPageState extends State<NearbyPlayersPage> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedLevel = 'All Levels';
  String _selectedSport = 'All';
  String _selectedSort = 'default';

  static const List<String> _sports = ['Tennis', 'Badminton', 'Table Tennis'];

  static const List<_NearbyPlayer> _players = [
    _NearbyPlayer(
      name: 'Alex Johnson',
      initials: 'AJ',
      sport: 'Tennis',
      level: 'Intermediate',
      distance: '0.8 mi',
      bio: 'Looking for evening singles matches',
      availability: 'Available today',
      time: '6 PM - 8 PM',
      action: 'Connect',
      rating: 4.8,
      online: true,
      avatarImagePath:
          'assets/images/player_details/player_profile/alex_johnson.png',
    ),
    _NearbyPlayer(
      name: 'Priya Shah',
      initials: 'PS',
      sport: 'Badminton',
      level: 'Beginner',
      distance: '1.2 mi',
      bio: 'Wants casual weekend games',
      availability: 'Weekends',
      time: '10 AM - 1 PM',
      action: 'Connect',
      rating: 4.6,
      online: false,
      avatarImagePath:
          'assets/images/player_details/open_matches/priya_avatar.png',
    ),
    _NearbyPlayer(
      name: 'David Lee',
      initials: 'DL',
      sport: 'Table Tennis',
      level: 'Advanced',
      distance: '0.5 mi',
      bio: 'Competitive player seeking strong opponents',
      availability: 'Tonight',
      time: '7 PM - 9 PM',
      action: 'Invite',
      rating: 4.9,
      online: true,
    ),
  ];

  List<_NearbyPlayer> get _filteredPlayers {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _players.where((player) {
      final matchesSearch =
          query.isEmpty ||
          player.name.toLowerCase().contains(query) ||
          player.sport.toLowerCase().contains(query) ||
          player.bio.toLowerCase().contains(query);

      final matchesLevel =
          _selectedLevel == 'All Levels' || player.level == _selectedLevel;

      final matchesSport =
          _selectedSport == 'All' || player.sport == _selectedSport;

      return matchesSearch && matchesLevel && matchesSport;
    }).toList();

    if (_selectedSort == 'distance') {
      filtered.sort(
        (a, b) =>
            _extractNumber(a.distance).compareTo(_extractNumber(b.distance)),
      );
    } else if (_selectedSort == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedSort == 'name') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }

  double _extractNumber(String text) {
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(text);
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
      default:
        return '';
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

  Future<void> _openLocationOverlay() => openLocationPicker(context);

  void _openPlayerProfile(_NearbyPlayer player) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => PlayerProfilePage(
          playerName: player.name,
          initials: player.initials,
          sport: player.sport,
          level: player.level,
          distance: player.distance,
          rating: player.rating,
          online: player.online,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openPersonalChat(_NearbyPlayer player) {
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
                  setState(() => _selectedSort = 'default');
                  Navigator.pop(context);
                },
              ),
              _FilterOptionTile(
                title: 'Nearest Distance',
                isSelected: _selectedSort == 'distance',
                onTap: () {
                  setState(() => _selectedSort = 'distance');
                  Navigator.pop(context);
                },
              ),
              _FilterOptionTile(
                title: 'Highest Rating',
                isSelected: _selectedSort == 'rating',
                onTap: () {
                  setState(() => _selectedSort = 'rating');
                  Navigator.pop(context);
                },
              ),
              _FilterOptionTile(
                title: 'Name A-Z',
                isSelected: _selectedSort == 'name',
                onTap: () {
                  setState(() => _selectedSort = 'name');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelChip(String label) {
    final isSelected = _selectedLevel == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8F9FC), Color(0xFFEDEFF5)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8F8FA)],
                ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4D9E5) : AppColors.border,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color.fromARGB(18, 120, 130, 160),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF667085),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = _filteredPlayers;
    final locationLabel = context
            .watch<AuthProvider>()
            .currentUser
            ?.location
            ?.displayLabel ??
        'Set location';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideMenuDrawer(),
      bottomNavigationBar: MainBottomNav(
        currentIndex: null,
        onTap: _onBottomNavTap,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                18,
                AppSpacing.pageHorizontal,
                8,
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
                        'Nearby Players',
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _openLocationOverlay,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${players.length} players nearby',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            locationLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textPrimary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CourtSearchBar(
                    controller: _searchController,
                    hintText: 'Search nearby players',
                    onChanged: (_) => setState(() {}),
                    onFilterTap: _openFilterSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Row(
                children: [
                  _buildLevelChip('All Levels'),
                  const SizedBox(width: AppSpacing.xs),
                  _buildLevelChip('Beginner'),
                  const SizedBox(width: AppSpacing.xs),
                  _buildLevelChip('Intermediate'),
                  const SizedBox(width: AppSpacing.xs),
                  _buildLevelChip('Advanced'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Players Near You',
                          style: AppTextStyles.sectionTitle,
                        ),
                        const Spacer(),
                        Text(
                          '${players.length} found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: players.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Text(
                                'No players found for this search/filter',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (final player in players) ...[
                                PlayerDetailsPlayerCard(
                                  name: player.name,
                                  initials: player.initials,
                                  sport: player.sport,
                                  level: player.level,
                                  distance: player.distance,
                                  bio: player.bio,
                                  availability: player.availability,
                                  time: player.time,
                                  actionLabel: player.action,
                                  rating: player.rating,
                                  online: player.online,
                                  avatarImagePath: player.avatarImagePath,
                                  onViewProfileTap: () =>
                                      _openPlayerProfile(player),
                                  onActionTap: () => _openPersonalChat(player),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              Text(
                                '${players.length} players shown',
                                style: AppTextStyles.caption,
                              ),
                            ],
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

class _NearbyPlayer {
  final String name;
  final String initials;
  final String sport;
  final String level;
  final String distance;
  final String bio;
  final String availability;
  final String time;
  final String action;
  final double rating;
  final bool online;
  final String? avatarImagePath;

  const _NearbyPlayer({
    required this.name,
    required this.initials,
    required this.sport,
    required this.level,
    required this.distance,
    required this.bio,
    required this.availability,
    required this.time,
    required this.action,
    required this.rating,
    required this.online,
    this.avatarImagePath,
  });
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
