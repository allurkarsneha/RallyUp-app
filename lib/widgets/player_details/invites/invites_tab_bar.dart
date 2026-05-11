import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class InvitesTabBar extends StatelessWidget {
  const InvitesTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.surface,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Divider(height: 1, color: AppColors.border),
          ),
          Row(
            children: const [
              Expanded(
                child: _InvitesTab(label: 'Sent Invites', selected: true),
              ),
              Expanded(child: _InvitesTab(label: 'Received Invites')),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvitesTab extends StatelessWidget {
  final String label;
  final bool selected;

  const _InvitesTab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? AppColors.primary : AppColors.muted,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (selected)
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
