import 'package:flutter/material.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../widgets/section_header.dart';
import '../../widgets/side_menu_drawer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';

class OpenMatchesPage extends StatelessWidget {
  const OpenMatchesPage({super.key});

  static const _matches = [
    (
      title: 'SCU Evening Tennis Match',
      sport: 'Tennis',
      sportIcon: '🎾',
      when: 'Today, 6:00 PM',
      location: 'SCU Tennis Court A',
      players: '3 / 4',
      level: 'Intermediate',
      host: 'Alex',
      spotLabel: '1 spot left',
      spotColor: AppColors.primary,
      imagePath: 'assets/images/player_details/open_matches/tennis_court.png',
      hostAvatarPath:
          'assets/images/player_details/open_matches/alex_avatar.png',
    ),
    (
      title: 'Bay Badminton Doubles',
      sport: 'Badminton',
      sportIcon: '🏸',
      when: 'Tomorrow, 7:00 PM',
      location: 'Bay Badminton Arena',
      players: '2 / 4',
      level: 'Beginner',
      host: 'Priya',
      spotLabel: '2 spots left',
      spotColor: Color(0xFFD97706),
      imagePath:
          'assets/images/player_details/open_matches/badminton_court.png',
      hostAvatarPath:
          'assets/images/player_details/open_matches/priya_avatar.png',
    ),
    (
      title: 'Weekend Basketball Run',
      sport: 'Basketball',
      sportIcon: '🏀',
      when: 'Sun, 4:00 PM',
      location: 'Downtown Basketball Court',
      players: '7 / 10',
      level: 'Casual',
      host: 'Kevin',
      spotLabel: '3 spots left',
      spotColor: AppColors.warning,
      imagePath:
          'assets/images/player_details/open_matches/basketball_court.png',
      hostAvatarPath:
          'assets/images/player_details/open_matches/kevin_avatar.png',
    ),
    (
      title: 'Bay Badminton Doubles',
      sport: 'Badminton',
      sportIcon: '🏸',
      when: 'Tomorrow, 7:00 PM',
      location: 'Bay Badminton Arena',
      players: '2 / 4',
      level: 'Beginner',
      host: 'Priya',
      spotLabel: '2 spots left',
      spotColor: Color(0xFFEA580C),
      imagePath:
          'assets/images/player_details/open_matches/badminton_court.png',
      hostAvatarPath:
          'assets/images/player_details/open_matches/priya_avatar.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const SideMenuDrawer(),
      bottomNavigationBar: MainBottomNav(currentIndex: 0, onTap: (_) {}),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _OpenMatchesHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            const SliverToBoxAdapter(child: OpenMatchesSportsSelector()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Open Matches Near You',
                actionLabel: 'View all',
                onViewAllTap: () {},
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                0,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              sliver: SliverList.separated(
                itemCount: _matches.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.lg),
                itemBuilder: (context, index) {
                  final match = _matches[index];

                  return OpenMatchCard(
                    title: match.title,
                    sport: match.sport,
                    sportIcon: match.sportIcon,
                    when: match.when,
                    location: match.location,
                    players: match.players,
                    level: match.level,
                    host: match.host,
                    spotLabel: match.spotLabel,
                    spotColor: match.spotColor,
                    imagePath: match.imagePath,
                    hostAvatarPath: match.hostAvatarPath,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenMatchesHeader extends StatelessWidget {
  const _OpenMatchesHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        0,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                    color: AppColors.textPrimary,
                    tooltip: 'Menu',
                  ),
                ),
                Text(
                  'Open Matches',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: AppColors.textPrimary,
                    tooltip: 'Notifications',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Santa Clara, CA',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Search open matches',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.muted,
                        size: 18,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 38,
                height: 38,
                child: IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  tooltip: 'Filters',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
