import 'package:flutter/material.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';

class InviteSentPage extends StatelessWidget {
  const InviteSentPage({super.key});

  static const String _alexAvatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(currentIndex: 0, onTap: (_) {}),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                42,
                AppSpacing.pageHorizontal,
                AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    const InviteSentSuccessIcon(),
                    const SizedBox(height: AppSpacing.lg),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          height: 1.2,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Your match invite has been sent to\n',
                          ),
                          TextSpan(
                            text: 'Alex Johnson.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const InviteSentSummaryCard(
                      avatarImagePath: _alexAvatarPath,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const InviteSentActionButtons(),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Invite Sent!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
