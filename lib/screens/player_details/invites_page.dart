import 'package:flutter/material.dart';
import 'package:rallyup/screens/main_shell_nav.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';
import 'invite_sent_page.dart';
import 'received_invites_page.dart';

class InvitesPage extends StatelessWidget {
  const InvitesPage({super.key});

  static const String _alexAvatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';

  void _backToInviteSent(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.maybePop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      _fadeRoute<void>(const InviteSentPage()),
    );
  }

  void _openReceivedInvites(BuildContext context) {
    Navigator.push(context, _fadeRoute<void>(const ReceivedInvitesPage()));
  }

  void _onBottomNavTap(BuildContext context, int index) {
    switchToMainShellTab(context, index);
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
            InvitesHeader(onBackTap: () => _backToInviteSent(context)),
            InvitesTabBar(
              onSentTap: () {},
              onReceivedTap: () => _openReceivedInvites(context),
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
                    'Sent Invites (1)',
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SentInviteCard(avatarImagePath: _alexAvatarPath),
                  const SizedBox(height: AppSpacing.xl),
                  const InviteMorePlayersCard(),
                  const SizedBox(height: AppSpacing.xl),
                  const InviteInfoCard(),
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