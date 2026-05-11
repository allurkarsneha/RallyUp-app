import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'player_details_avatar.dart';
import 'player_details_card.dart';
import 'player_details_primary_button.dart';

class PlayerDetailsPlayerCard extends StatelessWidget {
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
  final String? avatarImagePath;
  final VoidCallback? onViewProfileTap;
  final VoidCallback? onActionTap;
  final VoidCallback? onMessageTap;

  const PlayerDetailsPlayerCard({
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
    this.avatarImagePath,
    this.onViewProfileTap,
    this.onActionTap,
    this.onMessageTap,
  });

  Color _levelChipColor() {
    switch (level) {
      case 'Beginner':
        return const Color(0xFFF7E8B5);
      case 'Intermediate':
        return const Color(0xFFDCE7FF);
      case 'Advanced':
        return const Color(0xFFE7D9FF);
      default:
        return AppColors.primaryLight;
    }
  }

  IconData _sportIcon() {
    switch (sport) {
      case 'Tennis':
        return Icons.sports_tennis;
      case 'Badminton':
        return Icons.sports;
      case 'Table Tennis':
        return Icons.sports_tennis;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlayerDetailsCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerDetailsAvatar(
                  initials: initials,
                  online: online,
                  imagePath: avatarImagePath,
                  size: 58,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.star_outline_rounded,
                            color: Color(0xFFF5A623),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MetaText(
                            label: sport,
                            icon: _sportIcon(),
                          ),
                          const Text(
                            '•',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _levelChipColor(),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              level,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Text(
                            '•',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          _MetaText(
                            label: distance,
                            icon: Icons.location_on_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bio,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_available_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            availability,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: _MetaText(
                    label: time,
                    icon: Icons.schedule_rounded,
                  ),
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
                  child: PlayerDetailsPrimaryButton(
                    label: 'View Profile',
                    outlined: true,
                    onPressed: onViewProfileTap,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: PlayerDetailsPrimaryButton(
                    label: actionLabel,
                    icon: actionLabel == 'Invite'
                        ? Icons.mail_outline_rounded
                        : Icons.person_add_alt_1_rounded,
                    onPressed: onActionTap,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF15D8CF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onMessageTap ?? () {},
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.textPrimary,
                    ),
                    tooltip: 'Message',
                  ),
                ),
              ],
            ),
          ),
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
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}