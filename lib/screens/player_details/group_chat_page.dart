import 'package:flutter/material.dart';
import 'package:rallyup/screens/main_shell_nav.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/player_details/group_chat/group_chat_widgets.dart';
import '../../widgets/player_details/message/message_input_bar.dart';
import 'match_joined_page.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({super.key});

  static const String _courtImagePath =
      'assets/images/player_details/open_matches/tennis_court.png';
  static const String _alexAvatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';
  static const String _priyaAvatarPath =
      'assets/images/player_details/open_matches/priya_avatar.png';

  void _backToMatchJoined(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.maybePop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      _fadeRoute<void>(const MatchJoinedPage()),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    switchToMainShellTab(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 1,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            GroupChatHeader(onBackTap: () => _backToMatchJoined(context)),
            const Expanded(
              child: GroupChatMessageList(
                courtImagePath: _courtImagePath,
                alexAvatarPath: _alexAvatarPath,
                priyaAvatarPath: _priyaAvatarPath,
              ),
            ),
            const MessageInputBar(),
            const SizedBox(height: AppSpacing.xs),
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