import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../shared/widgets/rally_header.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class OpenMatchesPage extends StatelessWidget {
  const OpenMatchesPage({super.key});

  static const _matches = [
    (
      title: 'SCU Evening Tennis Match',
      sport: 'Tennis',
      when: 'Today, 6:00 PM',
      place: 'SCU Tennis Court A',
      players: '3 / 4',
      level: 'Intermediate',
      host: 'Hosted by Alex',
      spots: '1 spot left',
    ),
    (
      title: 'Bay Badminton Doubles',
      sport: 'Badminton',
      when: 'Tomorrow, 7:00 PM',
      place: 'Bay Badminton Arena',
      players: '2 / 4',
      level: 'Beginner',
      host: 'Hosted by Priya',
      spots: '2 spots left',
    ),
    (
      title: 'Weekend Basketball Run',
      sport: 'Basketball',
      when: 'Sun, 4:00 PM',
      place: 'Downtown Basketball Court',
      players: '7 / 10',
      level: 'Casual',
      host: 'Hosted by Kevin',
      spots: '3 spots left',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MainBottomNav(currentIndex: 0, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const RallyHeader(title: 'Open Matches', showMenuButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Santa Clara, CA',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search open matches',
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: const [
                              AnsweetaChip(label: 'All', selected: true),
                              SizedBox(width: AppSpacing.xs),
                              AnsweetaChip(label: 'Tennis'),
                              SizedBox(width: AppSpacing.xs),
                              AnsweetaChip(label: 'Badminton'),
                              SizedBox(width: AppSpacing.xs),
                              AnsweetaChip(label: 'Basketball'),
                              SizedBox(width: AppSpacing.xs),
                              AnsweetaChip(label: 'Pickleball'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(
                    title: 'Open Matches Near You',
                    actionLabel: 'View all',
                    onViewAllTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Column(
                      children: [
                        for (final match in _matches) ...[
                          AnsweetaMatchCard(
                            title: match.title,
                            sport: match.sport,
                            when: match.when,
                            place: match.place,
                            players: match.players,
                            level: match.level,
                            host: match.host,
                            spots: match.spots,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
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
