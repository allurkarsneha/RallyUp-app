import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class GroupChatHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const GroupChatHeader({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackTap ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.textPrimary,
            tooltip: 'Back',
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCU Evening Tennis Match',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '3 participants',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
            color: AppColors.textSecondary,
            tooltip: 'More',
          ),
        ],
      ),
    );
  }
}
