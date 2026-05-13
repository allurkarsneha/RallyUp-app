import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/player_details/player_details_components.dart';
import 'invites_page.dart';

class ReceivedInvitesPage extends StatelessWidget {
  const ReceivedInvitesPage({super.key});

  void _openSentInvites(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.maybePop(context);
      return;
    }

    Navigator.pushReplacement(context, _fadeRoute<void>(const InvitesPage()));
  }

  void _onBottomNavTap(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute<void>(MainShell(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(
        currentIndex: null,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const InvitesHeader(),
            InvitesTabBar(
              receivedSelected: true,
              onSentTap: () => _openSentInvites(context),
              onReceivedTap: () {},
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxl,
                ),
                children: [
                  Text(
                    'Received Invites (2)',
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const ReceivedInviteCard(
                    playerName: 'Priya Shah',
                    initials: 'PS',
                    sport: 'Badminton',
                    level: 'Intermediate',
                    location: 'Malley Center Court',
                    date: 'Tomorrow, 26 Apr 2026',
                    time: '5:00 - 7:00 PM',
                    status: 'New Invite',
                    note: 'Invited you to join',
                    avatarColor: Color(0xFF7C3AED),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const ReceivedInviteCard(
                    playerName: 'Kevin Chen',
                    initials: 'KC',
                    sport: 'Basketball',
                    level: 'Advanced',
                    location: 'Leavey Center',
                    date: 'Saturday, 27 Apr 2026',
                    time: '4:00 - 6:00 PM',
                    status: 'Pending Response',
                    note: 'Invited you recently',
                    avatarColor: Color(0xFFEA580C),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _ReceivedInvitesInfoCard(),
                ],
              ),
            ),
          ],
        ),
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

class _ReceivedInvitesInfoCard extends StatelessWidget {
  const _ReceivedInvitesInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.muted),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Accepted invites will move to your bookings.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}