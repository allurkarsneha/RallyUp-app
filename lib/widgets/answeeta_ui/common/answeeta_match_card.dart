import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'answeeta_card.dart';
import 'answeeta_chip.dart';
import 'answeeta_info_row.dart';
import 'answeeta_primary_button.dart';

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
