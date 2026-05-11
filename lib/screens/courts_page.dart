import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/screens/court_details_page.dart';
import 'package:rallyup/screens/notifications_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/courts/court_listing_card.dart';
import '../widgets/courts/court_search_bar.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/side_menu_drawer.dart';
import '../widgets/sports_card.dart';

class CourtsPage extends StatefulWidget {
  const CourtsPage({super.key});

  @override
  State<CourtsPage> createState() => _CourtsPageState();
}

class _CourtsPageState extends State<CourtsPage> {
  String _selectedSport = 'All';
  String _selectedSort = 'default';
  String _selectedLocation = 'Santa Clara, CA';
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _favoriteCourts = {};

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

  final List<Map<String, String>> _allCourts = const [
    {
      'title': 'SCU Tennis Court A',
      'sport': 'Tennis',
      'emoji': '🎾',
      'image': 'assets/images/courts/tenniscourt.png',
      'distance': '0.8 mi away',
      'rating': '4.9',
      'price': '\$22/hr',
      'slots': '2 slots today',
    },
    {
      'title': 'Bay Badminton Arena',
      'sport': 'Badminton',
      'emoji': '🏸',
      'image': 'assets/images/courts/badmintoncourt.png',
      'distance': '2.6 mi away',
      'rating': '4.4',
      'price': '\$16/hr',
      'slots': '6 slots today',
    },
    {
      'title': 'Downtown Basketball Court',
      'sport': 'Basketball',
      'emoji': '🏀',
      'image': 'assets/images/courts/basketballcourt.png',
      'distance': '3.9 mi away',
      'rating': '4.2',
      'price': '\$20/hr',
      'slots': '3 slots today',
    },
    {
      'title': 'Sunnyvale Pickleball Courts',
      'sport': 'Pickleball',
      'emoji': '🎾',
      'image': 'assets/images/courts/pickleballcourt.png',
      'distance': '1.4 mi away',
      'rating': '4.8',
      'price': '\$14/hr',
      'slots': '8 slots today',
    },
    {
      'title': 'SCU Volleyball Arena',
      'sport': 'Volleyball',
      'emoji': '🏐',
      'image': 'assets/images/courts/volleyballcourt.png',
      'distance': '2.1 mi away',
      'rating': '4.6',
      'price': '\$18/hr',
      'slots': '4 slots today',
    },
  ];

  List<Map<String, String>> get _filteredCourts {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _allCourts.where((court) {
      final matchesSport =
          _selectedSport == 'All' || court['sport'] == _selectedSport;

      final title = court['title']!.toLowerCase();
      final sport = court['sport']!.toLowerCase();

      final matchesSearch =
          query.isEmpty || title.contains(query) || sport.contains(query);

      return matchesSport && matchesSearch;
    }).toList();

    if (_selectedSort == 'distance') {
      filtered.sort(
        (a, b) => _extractNumber(a['distance']!).compareTo(
          _extractNumber(b['distance']!),
        ),
      );
    } else if (_selectedSort == 'rating') {
      filtered.sort(
        (a, b) => _extractNumber(b['rating']!).compareTo(
          _extractNumber(a['rating']!),
        ),
      );
    } else if (_selectedSort == 'price_low') {
      filtered.sort(
        (a, b) => _extractNumber(a['price']!).compareTo(
          _extractNumber(b['price']!),
        ),
      );
    } else if (_selectedSort == 'slots') {
      filtered.sort(
        (a, b) => _extractNumber(b['slots']!).compareTo(
          _extractNumber(a['slots']!),
        ),
      );
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

  void _toggleFavorite(String courtTitle) {
    setState(() {
      if (_favoriteCourts.contains(courtTitle)) {
        _favoriteCourts.remove(courtTitle);
      } else {
        _favoriteCourts.add(courtTitle);
      }
    });
  }

  void _openCourtDetails(Map<String, String> court) {
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
          locationText: _selectedLocation,
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courts = _filteredCourts;

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
                        'Courts',
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
                            _selectedLocation,
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
                      'Nearby Courts',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (courts.isEmpty)
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
                                'No courts found',
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
                    ...courts.map(
                      (court) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: CourtListingCard(
                          imagePath: court['image']!,
                          title: court['title']!,
                          sport: court['sport']!,
                          sportEmoji: court['emoji']!,
                          distanceText: court['distance']!,
                          ratingText: court['rating']!,
                          priceText: court['price']!,
                          slotsText: court['slots']!,
                          isFavorite: _favoriteCourts.contains(court['title']!),
                          onViewDetailsTap: () => _openCourtDetails(court),
                          onFavoriteTap: () => _toggleFavorite(court['title']!),
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