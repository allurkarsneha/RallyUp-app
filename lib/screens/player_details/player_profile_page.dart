import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';

class PlayerProfilePage extends StatelessWidget {
  const PlayerProfilePage({super.key});

  static const String _heroImagePath =
      'assets/images/player_details/player_profile/player_profile_hero.png';
  static const String _avatarImagePath =
      'assets/images/player_details/player_profile/alex_johnson.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: MainBottomNav(currentIndex: 2, onTap: (_) {}),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PlayerProfileHero(
                heroImagePath: _heroImagePath,
                avatarImagePath: _avatarImagePath,
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Alex Johnson',
                    style: AppTextStyles.pageTitle.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 46),
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
