import 'package:flutter/material.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';
import 'invite_sent_page.dart';
import 'player_profile_page.dart';

class InviteToMatchPage extends StatelessWidget {
  const InviteToMatchPage({super.key});

  static const String _avatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';

  void _goBackToProfile(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.maybePop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      _fadeRoute<void>(const PlayerProfilePage()),
    );
  }

  void _sendInvite(BuildContext context) {
    Navigator.push(context, _fadeRoute<void>(const InviteSentPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(currentIndex: 0, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            _InviteHeader(onBackTap: () => _goBackToProfile(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                children: [
                  const InvitePlayerCard(avatarImagePath: _avatarPath),
                  const SizedBox(height: AppSpacing.lg),
                  const InviteDetailCard(),
                  const SizedBox(height: AppSpacing.lg),
                  const InviteMessageCard(),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryInviteButton(onPressed: () => _sendInvite(context)),
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
  final VoidCallback? onBackTap;

  const _InviteHeader({this.onBackTap});

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
              onPressed: onBackTap ?? () => Navigator.maybePop(context),
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

PageRouteBuilder<T> _fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
  );
}
