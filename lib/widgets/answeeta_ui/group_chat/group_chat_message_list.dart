import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import 'group_chat_bubble.dart';
import 'group_match_summary_card.dart';

class GroupChatMessageList extends StatelessWidget {
  final String courtImagePath;
  final String alexAvatarPath;
  final String priyaAvatarPath;

  const GroupChatMessageList({
    super.key,
    required this.courtImagePath,
    required this.alexAvatarPath,
    required this.priyaAvatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
      ),
      children: [
        GroupMatchSummaryCard(imagePath: courtImagePath),
        const SizedBox(height: AppSpacing.xl),
        GroupChatBubble(
          sender: 'Alex (Host)',
          message:
              'Hi everyone! 👋\nMatch is at 6 PM today.\nSee you all there!',
          time: '5:30 PM',
          initials: 'AJ',
          avatarImagePath: alexAvatarPath,
        ),
        GroupChatBubble(
          sender: 'Priya',
          message: "I'll reach by 5:45 PM.",
          time: '5:32 PM',
          initials: 'PS',
          avatarImagePath: priyaAvatarPath,
          avatarColor: const Color(0xFF7C3AED),
        ),
        const GroupChatBubble(
          message: 'Just joined! Looking forward to the game. 🎾',
          time: '5:33 PM',
          isMine: true,
        ),
        const GroupChatBubble(
          sender: 'Michael',
          message: "Great! Let's have a good match.",
          time: '5:35 PM',
          initials: 'M',
          avatarColor: Color(0xFF0EA5E9),
        ),
      ],
    );
  }
}
