import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';

class PlayerProfilePage extends StatelessWidget {
  final String playerName;
  final String initials;
  final String sport;
  final String level;
  final String distance;
  final double rating;
  final bool online;

  const PlayerProfilePage({
    super.key,
    this.playerName = 'Alex Johnson',
    this.initials = 'AJ',
    this.sport = 'Tennis',
    this.level = 'Intermediate',
    this.distance = '0.8 mi',
    this.rating = 4.8,
    this.online = true,
  });

  static const String _heroImagePath =
      'assets/images/player_details/player_profile/player_profile_hero.png';
  static const String _avatarImagePath =
      'assets/images/player_details/player_profile/alex_johnson.png';

  void _onBottomNavTap(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainShell(initialIndex: index),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: MainBottomNav(
        currentIndex: null,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PlayerProfileHero(
                heroImagePath: _heroImagePath,
                avatarImagePath: _avatarImagePath,
                onBackTap: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    playerName,
                    style: AppTextStyles.pageTitle.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      PlayerDetailsChip(label: sport),
                      PlayerDetailsChip(label: level),
                      PlayerDetailsChip(
                        label: distance,
                        icon: Icons.location_on_outlined,
                      ),
                      PlayerDetailsChip(
                        label: rating.toStringAsFixed(1),
                        icon: Icons.star_rounded,
                      ),
                      PlayerDetailsChip(
                        label: online ? 'Online' : 'Offline',
                        icon: Icons.circle,
                        selected: online,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const PlayerProfileActionButtons(),
                  const SizedBox(height: AppSpacing.xxl),
                  const PlayerProfileAboutSection(),
                  const SizedBox(height: AppSpacing.xl),
                  const AvailabilitySection(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}