import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class MessageFilterTabs extends StatelessWidget {
  const MessageFilterTabs({super.key});

  static const List<String> _tabs = ['All', 'Unread', 'Groups'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final tab in _tabs) ...[
          _MessageFilterChip(label: tab, selected: tab == 'All'),
          if (tab != _tabs.last) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _MessageFilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _MessageFilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: selected ? AppColors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
