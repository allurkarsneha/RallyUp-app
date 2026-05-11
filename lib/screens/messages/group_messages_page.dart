import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/messages/messages_widgets.dart';
import 'unread_messages_page.dart';

class GroupMessagesPage extends StatelessWidget {
  const GroupMessagesPage({super.key});

  static const String _alexAvatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';

  static const List<_GroupMessageThread> _threads = [
    _GroupMessageThread(
      name: 'SCU Evening Tennis Match',
      message: 'Alex: See you at the court!',
      time: 'Fri',
      participants: '3 participants',
      unreadCount: 2,
      avatars: [
        MessageAvatarData(
          initials: 'AJ',
          backgroundColor: AppColors.primary,
          imagePath: _alexAvatarPath,
        ),
        MessageAvatarData(initials: 'MP', backgroundColor: Color(0xFF0EA5E9)),
      ],
    ),
    _GroupMessageThread(
      name: 'Bay Badminton Doubles',
      message: 'Priya: I booked Court 2 for tonight.',
      time: 'Thu',
      participants: '4 participants',
      avatars: [
        MessageAvatarData(initials: 'PS', backgroundColor: Color(0xFF7C3AED)),
        MessageAvatarData(initials: 'KC', backgroundColor: Color(0xFFEA580C)),
      ],
    ),
    _GroupMessageThread(
      name: 'Weekend Basketball Run',
      message: 'Kevin: We still need one more player.',
      time: 'Wed',
      participants: '6 participants',
      unreadCount: 1,
      avatars: [
        MessageAvatarData(initials: 'KC', backgroundColor: Color(0xFFEA580C)),
        MessageAvatarData(initials: 'JL', backgroundColor: Color(0xFF475569)),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const MessagesHeader(title: 'Group Messages', showBackButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxl,
                ),
                children: [
                  const MessageSearchBar(),
                  const SizedBox(height: AppSpacing.md),
                  MessageFilterTabs(
                    selectedFilter: 'Groups',
                    onAllTap: () => Navigator.of(context).maybePop(),
                    onUnreadTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const UnreadMessagesPage(),
                        ),
                      );
                    },
                    onGroupsTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Group conversations',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final thread in _threads)
                    MessageThreadTile(
                      name: thread.name,
                      message: thread.message,
                      time: thread.time,
                      status: thread.participants,
                      unreadCount: thread.unreadCount,
                      isGroup: true,
                      avatars: thread.avatars,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupMessageThread {
  final String name;
  final String message;
  final String time;
  final String participants;
  final int unreadCount;
  final List<MessageAvatarData> avatars;

  const _GroupMessageThread({
    required this.name,
    required this.message,
    required this.time,
    required this.participants,
    required this.avatars,
    this.unreadCount = 0,
  });
}
