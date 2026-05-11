import 'package:flutter/material.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/player_details_components.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  static const String _alexAvatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(currentIndex: 1, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const ChatHeader(avatarImagePath: _alexAvatarPath),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  Center(
                    child: Text(
                      'Today',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const ChatBubble(
                    text: 'Hey!👋',
                    time: '10:30 AM',
                    avatarImagePath: _alexAvatarPath,
                  ),
                  const ChatBubble(
                    text: 'Hey Alex! Are you free to play tennis this evening?',
                    time: '10:31 AM',
                    avatarImagePath: _alexAvatarPath,
                    isMine: true,
                    showTicks: true,
                  ),
                  const ChatBubble(
                    text: "Yes, I'm available after 6 PM.",
                    time: '10:32 AM',
                    avatarImagePath: _alexAvatarPath,
                  ),
                  const ChatBubble(
                    text: 'Great! Shall we meet at Central Park Tennis Court?',
                    time: '10:32 AM',
                    avatarImagePath: _alexAvatarPath,
                    isMine: true,
                    showTicks: true,
                  ),
                  const ChatBubble(
                    text: 'Sounds good 👍',
                    time: '10:38 AM',
                    avatarImagePath: _alexAvatarPath,
                  ),
                  const ChatBubble(
                    text: "I'll book the court.",
                    time: '10:39 AM',
                    avatarImagePath: _alexAvatarPath,
                    isMine: true,
                  ),
                  const ChatBubble(
                    text: 'Perfect! See you there.',
                    time: '10:41 AM',
                    avatarImagePath: _alexAvatarPath,
                    isMine: true,
                    showTicks: true,
                  ),
                  const ChatBubble(
                    text: 'See you!🎾',
                    time: '10:34 AM',
                    avatarImagePath: _alexAvatarPath,
                  ),
                ],
              ),
            ),
            const MessageInputBar(),
            const SizedBox(height: AppSpacing.xs),
            const QuickReplyChips(),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
