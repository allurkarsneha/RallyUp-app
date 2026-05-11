import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/messages/messages_widgets.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static const String _alexAvatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';

  static const List<_MessageThread> _threads = [
    _MessageThread(
      name: 'Alex Johnson',
      message: 'Sounds good 👍',
      time: '10:34 AM',
      status: 'Online',
      unreadCount: 2,
      online: true,
      avatars: [
        MessageAvatarData(
          initials: 'AJ',
          backgroundColor: AppColors.primary,
          imagePath: _alexAvatarPath,
        ),
      ],
    ),
    _MessageThread(
      name: 'Priya Shah',
      message: 'Are we still playing badminton today?',
      time: 'Yesterday',
      status: 'Offline',
      unreadCount: 1,
      avatars: [
        MessageAvatarData(initials: 'PS', backgroundColor: Color(0xFF7C3AED)),
      ],
    ),
    _MessageThread(
      name: 'Kevin Chen',
      message: 'I can join the basketball run at 4 PM.',
      time: 'Mon',
      status: 'Offline',
      avatars: [
        MessageAvatarData(initials: 'KC', backgroundColor: Color(0xFFEA580C)),
      ],
    ),
    _MessageThread(
      name: 'Maya Patel',
      message: 'Court booking is confirmed.',
      time: 'Sun',
      status: 'Online',
      online: true,
      avatars: [
        MessageAvatarData(initials: 'MP', backgroundColor: Color(0xFF0EA5E9)),
      ],
    ),
    _MessageThread(
      name: 'Jordan Lee',
      message: 'Let me know if you need one more player.',
      time: 'Sat',
      status: 'Offline',
      avatars: [
        MessageAvatarData(initials: 'JL', backgroundColor: Color(0xFF475569)),
      ],
    ),
    _MessageThread(
      name: 'SCU Tennis Group',
      message: 'Alex: See you at the court!',
      time: 'Fri',
      status: 'Group chat',
      isGroup: true,
      avatars: [
        MessageAvatarData(
          initials: 'AJ',
          backgroundColor: AppColors.primary,
          imagePath: _alexAvatarPath,
        ),
        MessageAvatarData(initials: 'MP', backgroundColor: Color(0xFF0EA5E9)),
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
            const MessagesHeader(),
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
                  const MessageFilterTabs(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Recent conversations',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final thread in _threads)
                    MessageThreadTile(
                      name: thread.name,
                      message: thread.message,
                      time: thread.time,
                      status: thread.status,
                      unreadCount: thread.unreadCount,
                      online: thread.online,
                      isGroup: thread.isGroup,
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

class _MessageThread {
  final String name;
  final String message;
  final String time;
  final String status;
  final int unreadCount;
  final bool online;
  final bool isGroup;
  final List<MessageAvatarData> avatars;

  const _MessageThread({
    required this.name,
    required this.message,
    required this.time,
    required this.status,
    required this.avatars,
    this.unreadCount = 0,
    this.online = false,
    this.isGroup = false,
  });
}