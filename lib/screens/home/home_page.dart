import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../shared/widgets/rally_header.dart';
import '../../shared/widgets/sports_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedSport = 'All';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RallyHeader(
              title: 'Home',
              showNotificationButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                children: [
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Text(
                      'All Sports',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 160,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}