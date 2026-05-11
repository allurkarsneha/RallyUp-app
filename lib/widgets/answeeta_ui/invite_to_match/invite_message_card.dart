import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'invite_to_match_surface.dart';

class InviteMessageCard extends StatelessWidget {
  const InviteMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InviteToMatchSurface(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message (Optional)',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hi Alex, want to join for a friendly match?',
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '42/100',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
