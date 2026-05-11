import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';

class InviteToMatchPage extends StatelessWidget {
  const InviteToMatchPage({super.key});

  static const String _avatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(currentIndex: 0, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const _InviteHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                children: const [
                  InvitePlayerCard(avatarImagePath: _avatarPath),
                  SizedBox(height: AppSpacing.lg),
                  InviteDetailCard(),
                  SizedBox(height: AppSpacing.lg),
                  InviteMessageCard(),
                  SizedBox(height: AppSpacing.lg),
                  PrimaryInviteButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteHeader extends StatelessWidget {
  const _InviteHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: AppSpacing.xs,
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.textPrimary,
              tooltip: 'Back',
            ),
          ),
          Positioned(
            left: 72,
            right: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Invite to Match',
                    style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Send an invite to play together',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
