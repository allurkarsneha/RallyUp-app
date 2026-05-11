import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';
import 'match_joined_page.dart';

class JoinMatchPage extends StatelessWidget {
  const JoinMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: PlayerDetailsCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Join this match?',
                      style: AppTextStyles.sectionTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'You will join the group chat and other players will be notified.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PlayerDetailsPrimaryButton(
                      label: 'Yes, Join',
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder<void>(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const MatchJoinedPage(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 220,
                            ),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 180,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PlayerDetailsPrimaryButton(
                      label: 'Cancel',
                      outlined: true,
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
