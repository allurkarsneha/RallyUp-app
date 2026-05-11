import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/messages/messages_widgets.dart';
import 'group_messages_page.dart';

class UnreadMessagesPage extends StatelessWidget {
  const UnreadMessagesPage({super.key});

  static const String _alexAvatarPath =
      'assets/images/player_details/message_chat/alex_johnson.png';

  static const List<_UnreadMessageThread> _threads = [
    _UnreadMessageThread(
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
    _UnreadMessageThread(
      name: 'Priya Shah',
      message: 'Are we still playing badminton today?',
      time: 'Yesterday',
      status: 'Offline',
      unreadCount: 1,
      avatars: [
        MessageAvatarData(initials: 'PS', backgroundColor: Color(0xFF7C3AED)),
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
            const MessagesHeader(
              title: 'Unread Messages',
              showBackButton: true,
            ),
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
                    selectedFilter: 'Unread',
                    onAllTap: () => Navigator.maybePop(context),
                    onUnreadTap: () {},
                    onGroupsTap: () {
                      Navigator.of(context).pushReplacement(
                        _fadeRoute<void>(const GroupMessagesPage()),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Unread conversations',
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

class _UnreadMessageThread {
  final String name;
  final String message;
  final String time;
  final String status;
  final int unreadCount;
  final bool online;
  final List<MessageAvatarData> avatars;

  const _UnreadMessageThread({
    required this.name,
    required this.message,
    required this.time,
    required this.status,
    required this.unreadCount,
    required this.avatars,
    this.online = false,
  });
}
