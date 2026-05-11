import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../shared/widgets/rally_header.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';

class NearbyPlayersPage extends StatelessWidget {
  const NearbyPlayersPage({super.key});

  static const _players = [
    (
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
    ),
    (
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
    ),
    (
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
    (
      name: 'Maria Chen',
      initials: 'MC',
      sport: 'Pickleball',
      level: 'Intermediate',
      distance: '1.0 mi',
      bio: 'Looking for doubles partners nearby',
      availability: 'Available tomorrow',
      time: '5 PM - 7 PM',
      action: 'Connect',
      rating: 4.7,
      online: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MainBottomNav(currentIndex: 2, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const RallyHeader(title: 'Nearby Players', showBackButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              '23 players nearby',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Santa Clara, CA',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Nearby Players',
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
                              PlayerDetailsChip(
                                label: 'All Levels',
                                selected: true,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              PlayerDetailsChip(label: 'Beginner'),
                              SizedBox(width: AppSpacing.xs),
                              PlayerDetailsChip(label: 'Intermediate'),
                              SizedBox(width: AppSpacing.xs),
                              PlayerDetailsChip(label: 'Advanced'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(
                    title: 'Players Near You',
                    actionLabel: '23 found',
                    onViewAllTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Column(
                      children: [
                        for (final player in _players) ...[
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
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        Text(
                          '17 more players nearby',
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
