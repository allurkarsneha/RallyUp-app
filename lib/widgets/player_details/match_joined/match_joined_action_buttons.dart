import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class MatchJoinedActionButtons extends StatelessWidget {
  final VoidCallback? onGroupChatTap;
  final VoidCallback? onViewBookingsTap;

  const MatchJoinedActionButtons({
    super.key,
    this.onGroupChatTap,
    this.onViewBookingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: onGroupChatTap ?? () {},
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
            label: const Text('Go to Group Chat'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: onViewBookingsTap ?? () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('View My Bookings'),
          ),
        ),
      ],
    );
  }
}
