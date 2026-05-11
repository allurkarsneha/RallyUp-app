import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'invite_to_match_surface.dart';

class InvitePlayerCard extends StatelessWidget {
  final String avatarImagePath;

  const InvitePlayerCard({super.key, required this.avatarImagePath});

  @override
  Widget build(BuildContext context) {
    return InviteToMatchSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              avatarImagePath,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alex Johnson',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const _InviteMiniPill(label: 'Intermediate'),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '🎾 Tennis',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        '📍 0.8 mi',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteMiniPill extends StatelessWidget {
  final String label;

  const _InviteMiniPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: const Color(0xFF2563EB),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
