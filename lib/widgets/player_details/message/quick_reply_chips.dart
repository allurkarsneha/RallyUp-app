import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class QuickReplyChips extends StatelessWidget {
  const QuickReplyChips({super.key});

  static const List<String> _replies = [
    'Want to play today?',
    'Available at 6 PM?',
    'Book a court?',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          for (final reply in _replies) ...[
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.brightGreen),
              ),
              child: Text(
                reply,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brightGreen,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (reply != _replies.last) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
