import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class OpenMatchCard extends StatelessWidget {
  final String title;
  final String sport;
  final String sportIcon;
  final String when;
  final String location;
  final String players;
  final String level;
  final String host;
  final String spotLabel;
  final Color spotColor;
  final String imagePath;
  final String hostAvatarPath;

  const OpenMatchCard({
    super.key,
    required this.title,
    required this.sport,
    required this.sportIcon,
    required this.when,
    required this.location,
    required this.players,
    required this.level,
    required this.host,
    required this.spotLabel,
    required this.spotColor,
    required this.imagePath,
    required this.hostAvatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 366),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OpenMatchImageBanner(
                  imagePath: imagePath,
                  spotLabel: spotLabel,
                  spotColor: spotColor,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _OpenMatchMetaRow(
                        icon: Text(
                          sportIcon,
                          style: const TextStyle(fontSize: 11, height: 1),
                        ),
                        text: '$sport - $when',
                      ),
                      const SizedBox(height: 5),
                      _OpenMatchMetaRow(
                        icon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 12,
                        ),
                        text: location,
                      ),
                      const SizedBox(height: 5),
                      _OpenMatchMetaRow(
                        icon: const Icon(
                          Icons.groups_2_outlined,
                          color: AppColors.primary,
                          size: 12,
                        ),
                        text: '$players players - $level',
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              hostAvatarPath,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Hosted by $host',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            height: 32,
                            width: 92,
                            child: FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: AppTextStyles.caption.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Join Match'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpenMatchImageBanner extends StatelessWidget {
  final String imagePath;
  final String spotLabel;
  final Color spotColor;

  const _OpenMatchImageBanner({
    required this.imagePath,
    required this.spotLabel,
    required this.spotColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              height: 23,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: spotColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                spotLabel,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenMatchMetaRow extends StatelessWidget {
  final Widget icon;
  final String text;

  const _OpenMatchMetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 12, height: 13, child: Center(child: icon)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
