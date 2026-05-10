import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MainBottomNav(currentIndex: 1, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    tooltip: 'Back',
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCU Evening Tennis Match',
                          style: AppTextStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('3 participants', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz_rounded),
                    tooltip: 'More',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xs,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: const [
                  _VenueCard(),
                  SizedBox(height: AppSpacing.xl),
                  _ChatBubble(
                    sender: 'Alex (Host)',
                    text:
                        'Hi everyone!\nMatch is at 6 PM today.\nSee you all there!',
                    time: '5:30 PM',
                  ),
                  _ChatBubble(
                    sender: 'Priya',
                    text: 'I will reach by 5:45 PM.',
                    time: '5:32 PM',
                  ),
                  _ChatBubble(
                    text: 'Just joined! Looking forward to the game.',
                    time: '5:33 PM',
                    mine: true,
                  ),
                  _ChatBubble(
                    sender: 'Michael',
                    text: 'Great! Let us have a good match.',
                    time: '5:35 PM',
                  ),
                ],
              ),
            ),
            const _MessageComposer(),
          ],
        ),
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard();

  @override
  Widget build(BuildContext context) {
    return AnsweetaCard(
      child: Row(
        children: [
          Container(
            width: 112,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              // TODO: Replace with venue image when the project has the asset.
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SCU Tennis Court A', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                const AnsweetaInfoRow(
                  icon: Icons.sports_tennis,
                  title: 'Tennis',
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Mon, 17 Aug 2025', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '6:00 PM - 7:00 PM (1 hour)',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(r'$18/hour', style: AppTextStyles.sectionTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String? sender;
  final String text;
  final String time;
  final bool mine;

  const _ChatBubble({
    required this.text,
    required this.time,
    this.sender,
    this.mine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!mine) ...[
            AnsweetaAvatar(initials: sender?.substring(0, 1) ?? 'P', size: 32),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: mine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (sender != null) Text(sender!, style: AppTextStyles.caption),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: mine ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: mine ? null : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.body.copyWith(
                      color: mine ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(time, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add',
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: AppColors.surface,
                suffixIcon: const Icon(Icons.attach_file_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton.filled(
            onPressed: () {},
            icon: const Icon(Icons.send_rounded),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
