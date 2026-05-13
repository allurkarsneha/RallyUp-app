import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'invite_detail_line.dart';
import 'invite_status_chip.dart';

class ReceivedInviteCard extends StatelessWidget {
  final String playerName;
  final String initials;
  final String sport;
  final String level;
  final String location;
  final String date;
  final String time;
  final String status;
  final String note;
  final Color avatarColor;

  const ReceivedInviteCard({
    super.key,
    required this.playerName,
    required this.initials,
    required this.sport,
    required this.level,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    required this.note,
    required this.avatarColor,
  });

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
              CircleAvatar(
                radius: 26,
                backgroundColor: avatarColor,
                child: Text(
                  initials,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$sport • $note',
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
              _InvitesSkillChip(label: level),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: AppSpacing.md),
          InviteDetailLine(icon: Icons.location_on_outlined, label: location),
          const SizedBox(height: AppSpacing.sm),
          InviteDetailLine(
            icon: Icons.calendar_today_outlined,
            label: date,
            trailing: time,
          ),
          const SizedBox(height: AppSpacing.sm),
          InviteDetailLine(icon: Icons.sports_tennis_rounded, label: sport),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              InviteStatusChip(label: status),
              const Spacer(),
              _InviteActionButton(
                label: 'Decline',
                outlined: true,
                onPressed: () {},
              ),
              const SizedBox(width: AppSpacing.sm),
              _InviteActionButton(label: 'Accept', onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _InviteActionButton extends StatelessWidget {
  final String label;
  final bool outlined;
  final VoidCallback onPressed;

  const _InviteActionButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );

    if (outlined) {
      return SizedBox(
        height: 38,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.3),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
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
