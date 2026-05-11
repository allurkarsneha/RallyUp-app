import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'invite_detail_line.dart';
import 'invite_status_chip.dart';

class SentInviteCard extends StatelessWidget {
  final String avatarImagePath;

  const SentInviteCard({super.key, required this.avatarImagePath});

  @override
  Widget build(BuildContext context) {
    return _InvitesSurface(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
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
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tennis • 0.8 mi',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _InvitesSkillChip(label: 'Intermediate'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: AppSpacing.md),
          const InviteDetailLine(
            icon: Icons.location_on_outlined,
            label: 'Central Park Tennis Court',
          ),
          const SizedBox(height: AppSpacing.sm),
          const InviteDetailLine(
            icon: Icons.calendar_today_outlined,
            label: 'Tomorrow, 26 Apr 2026',
            trailing: '6:00 - 8:00 PM',
          ),
          const SizedBox(height: AppSpacing.sm),
          const InviteDetailLine(
            icon: Icons.groups_2_outlined,
            label: '1 More Player Needed',
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const InviteStatusChip(label: 'Pending'),
              const Spacer(),
              Text(
                'Invited just now',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.muted,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvitesSkillChip extends StatelessWidget {
  final String label;

  const _InvitesSkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF3B6FD8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InvitesSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _InvitesSurface({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
