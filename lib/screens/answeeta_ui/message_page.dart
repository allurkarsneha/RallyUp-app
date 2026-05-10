import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MainBottomNav(currentIndex: 1, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    tooltip: 'Back',
                  ),
                  const AnsweetaAvatar(initials: 'AJ', size: 42, online: true),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex Johnson', style: AppTextStyles.bodyMedium),
                        Text('Online', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert_rounded),
                    tooltip: 'More',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: const [
                  Center(child: AnsweetaChip(label: 'Today')),
                  SizedBox(height: AppSpacing.lg),
                  _DirectMessage(text: 'Hey!', time: '10:30 AM'),
                  _DirectMessage(
                    text: 'Hey Alex! Are you free to play tennis this evening?',
                    time: '10:31 AM',
                    mine: true,
                  ),
                  _DirectMessage(
                    text: 'Yes, I am available after 6 PM.',
                    time: '10:32 AM',
                  ),
                  _DirectMessage(
                    text: 'Great! Shall we meet at Central Park Tennis Court?',
                    time: '10:32 AM',
                    mine: true,
                  ),
                  _DirectMessage(text: 'Sounds good.', time: '10:38 AM'),
                  _DirectMessage(
                    text: 'I will book the court.',
                    time: '10:39 AM',
                    mine: true,
                  ),
                  _DirectMessage(
                    text: 'Perfect! See you there.',
                    time: '10:41 AM',
                    mine: true,
                  ),
                  _DirectMessage(text: 'See you!', time: '10:34 AM'),
                ],
              ),
            ),
            const _QuickReplies(),
            const _DirectComposer(),
          ],
        ),
      ),
    );
  }
}

class _DirectMessage extends StatelessWidget {
  final String text;
  final String time;
  final bool mine;

  const _DirectMessage({
    required this.text,
    required this.time,
    this.mine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
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
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Row(
        children: const [
          AnsweetaChip(label: 'Want to play today?'),
          SizedBox(width: AppSpacing.xs),
          AnsweetaChip(label: 'Available at 6 PM?'),
          SizedBox(width: AppSpacing.xs),
          AnsweetaChip(label: 'Book a court?'),
        ],
      ),
    );
  }
}

class _DirectComposer extends StatelessWidget {
  const _DirectComposer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Type a message...',
          filled: true,
          fillColor: AppColors.surface,
          suffixIcon: const Icon(Icons.send_rounded),
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
    );
  }
}
