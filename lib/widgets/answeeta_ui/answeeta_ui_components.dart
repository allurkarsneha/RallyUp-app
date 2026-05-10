import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class AnsweetaPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;

  const AnsweetaPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = outlined ? AppColors.surface : AppColors.primary;
    final Color foreground = outlined ? AppColors.textPrimary : AppColors.white;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed ?? () {},
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(
            color: outlined ? AppColors.border : AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class AnsweetaChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;

  const AnsweetaChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: selected ? AppColors.white : AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AnsweetaAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final bool online;

  const AnsweetaAvatar({
    super.key,
    required this.initials,
    this.size = 56,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              initials,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (online)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class AnsweetaInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AnsweetaInfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.body),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class AnsweetaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AnsweetaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AnsweetaPlayerCard extends StatelessWidget {
  final String name;
  final String initials;
  final String sport;
  final String level;
  final String distance;
  final String bio;
  final String availability;
  final String time;
  final String actionLabel;
  final double rating;
  final bool online;

  const AnsweetaPlayerCard({
    super.key,
    required this.name,
    required this.initials,
    required this.sport,
    required this.level,
    required this.distance,
    required this.bio,
    required this.availability,
    required this.time,
    this.actionLabel = 'Connect',
    this.rating = 4.8,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnsweetaCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnsweetaAvatar(initials: initials, online: online),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name, style: AppTextStyles.bodyMedium),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF5A623),
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MetaText(label: sport, icon: Icons.sports_tennis),
                          AnsweetaChip(label: level),
                          _MetaText(
                            label: distance,
                            icon: Icons.location_on_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(bio, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnsweetaChip(
                    label: availability,
                    icon: Icons.event_available_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: _MetaText(label: time, icon: Icons.schedule_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: AnsweetaPrimaryButton(
                    label: 'View Profile',
                    outlined: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AnsweetaPrimaryButton(
                    label: actionLabel,
                    icon: actionLabel == 'Invite'
                        ? Icons.mail_outline_rounded
                        : Icons.person_add_alt_1_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  tooltip: 'Message',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnsweetaMatchCard extends StatelessWidget {
  final String title;
  final String sport;
  final String when;
  final String place;
  final String players;
  final String level;
  final String host;
  final String spots;
  final bool compact;

  const AnsweetaMatchCard({
    super.key,
    required this.title,
    required this.sport,
    required this.when,
    required this.place,
    required this.players,
    required this.level,
    required this.host,
    required this.spots,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnsweetaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
              AnsweetaChip(label: spots, selected: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _MetaText(label: sport, icon: Icons.sports_tennis),
              _MetaText(label: when, icon: Icons.schedule_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnsweetaInfoRow(icon: Icons.location_on_outlined, title: place),
          const SizedBox(height: AppSpacing.sm),
          AnsweetaInfoRow(
            icon: Icons.groups_2_outlined,
            title: '$players players - $level',
            trailing: Text(host, style: AppTextStyles.caption),
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.md),
            AnsweetaPrimaryButton(label: 'Join Match'),
          ],
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MetaText({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
