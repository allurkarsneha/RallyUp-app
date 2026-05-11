import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class MatchJoinedDetailsCard extends StatelessWidget {
  const MatchJoinedDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          _MatchDetailRow(
            icon: Icons.sports_tennis_rounded,
            text: 'SCU Evening Tennis Match',
          ),
          SizedBox(height: AppSpacing.md),
          _MatchDetailRow(
            icon: Icons.calendar_today_outlined,
            text: 'Sat, 17 May 2025',
          ),
          SizedBox(height: AppSpacing.md),
          _MatchDetailRow(
            icon: Icons.schedule_rounded,
            text: '6:00 PM - 7:00 PM',
          ),
        ],
      ),
    );
  }
}

class _MatchDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MatchDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
