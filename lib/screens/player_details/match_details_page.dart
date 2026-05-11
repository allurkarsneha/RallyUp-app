import 'package:flutter/material.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../widgets/rally_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';

class MatchDetailsPage extends StatelessWidget {
  const MatchDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: MainBottomNav(currentIndex: 0, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const RallyHeader(
              title: 'Match Details',
              showBackButton: true,
              showNotificationButton: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      // TODO: Replace with the Figma court photo once the asset
                      // is available in the Flutter project.
                      child: Icon(
                        Icons.sports_tennis_rounded,
                        color: AppColors.primary,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'SCU Evening Tennis Match',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const PlayerDetailsChip(
                    label: 'Tennis',
                    icon: Icons.sports_tennis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const PlayerDetailsInfoRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'Today, 6:00 PM',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const PlayerDetailsInfoRow(
                    icon: Icons.location_on_outlined,
                    title: 'SCU Tennis Court A',
                    subtitle: '500 El Camino Real, Santa Clara, CA',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const PlayerDetailsInfoRow(
                    icon: Icons.groups_2_outlined,
                    title: '3 / 4 players joined',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const PlayerDetailsInfoRow(
                    icon: Icons.bar_chart_rounded,
                    title: 'Intermediate Level',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const PlayerDetailsInfoRow(
                    icon: Icons.verified_rounded,
                    title: 'Hosted by Alex',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('About this match', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Looking for 1 more player for a fun evening doubles match. Let us have a great game!',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Players (3/4)', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: const [
                        _MatchPlayer(initials: 'AJ', label: 'Alex\n(Host)'),
                        SizedBox(width: AppSpacing.md),
                        _MatchPlayer(initials: 'YO', label: 'You'),
                        SizedBox(width: AppSpacing.md),
                        _MatchPlayer(initials: 'PS', label: 'Priya'),
                        SizedBox(width: AppSpacing.md),
                        _OpenSpot(),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const PlayerDetailsPrimaryButton(label: 'Join Match'),
                  const SizedBox(height: AppSpacing.sm),
                  const PlayerDetailsPrimaryButton(
                    label: 'Message Host',
                    outlined: true,
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

class _MatchPlayer extends StatelessWidget {
  final String initials;
  final String label;

  const _MatchPlayer({required this.initials, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          PlayerDetailsAvatar(initials: initials, size: 48),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OpenSpot extends StatelessWidget {
  const _OpenSpot();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(Icons.add_rounded, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '1 spot left',
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
