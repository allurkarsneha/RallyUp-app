import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class MessageInputBar extends StatelessWidget {
  const MessageInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.muted,
            tooltip: 'Add',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 36),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.muted,
                  ),
                  suffixIcon: const Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton.filled(
              onPressed: () {},
              icon: const Icon(Icons.send_rounded, size: 20),
              color: AppColors.white,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              tooltip: 'Send',
            ),
          ),
        ],
      ),
    );
  }
}
