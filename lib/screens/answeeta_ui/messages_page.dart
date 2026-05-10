import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../shared/widgets/rally_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static const _threads = [
    ('Harry', 'Hello Good Morning', '11/04/26', 'H'),
    ('Melody', 'Hey there', '13/10/26', 'M'),
    ('Mary', 'Hi', '11/03/26', 'M'),
    ('Dhurmil', 'E', '14/04/26', 'D'),
    ('Sarthak', 'Batminton', '12/03/26', 'S'),
    ('Sanika', 'See you on court', '11/02/23', 'S'),
    ('Alex Johnson', 'Yesterday', 'Yesterday', 'AJ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MainBottomNav(currentIndex: 1, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const RallyHeader(title: 'Messages'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: [
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AnsweetaChip(label: 'All', selected: true),
                        SizedBox(width: AppSpacing.xs),
                        AnsweetaChip(label: 'Unread'),
                        SizedBox(width: AppSpacing.xs),
                        AnsweetaChip(label: 'Blocked'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnsweetaCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final thread in _threads) ...[
                          _MessageThread(
                            name: thread.$1,
                            preview: thread.$2,
                            date: thread.$3,
                            initials: thread.$4,
                          ),
                          if (thread != _threads.last)
                            const Divider(height: 1, color: AppColors.border),
                        ],
                      ],
                    ),
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

class _MessageThread extends StatelessWidget {
  final String name;
  final String preview;
  final String date;
  final String initials;

  const _MessageThread({
    required this.name,
    required this.preview,
    required this.date,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: AnsweetaAvatar(initials: initials, size: 44),
      title: Text(name, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        preview,
        style: AppTextStyles.caption,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(date, style: AppTextStyles.caption),
      onTap: () {},
    );
  }
}
