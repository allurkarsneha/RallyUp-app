import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'invite_detail_row.dart';
import 'invite_to_match_surface.dart';

class InviteDetailCard extends StatelessWidget {
  const InviteDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      InviteDetailRow(
        label: 'Sport',
        value: 'Tennis',
        icon: Icons.language_rounded,
        iconColor: AppColors.brightGreen,
        iconBackground: AppColors.primaryLight,
      ),
      InviteDetailRow(
        label: 'Court',
        value: 'Central Park Tennis Court',
        icon: Icons.location_on_outlined,
        iconColor: Color(0xFF2563EB),
        iconBackground: Color(0xFFEFF6FF),
      ),
      InviteDetailRow(
        label: 'Date',
        value: 'Tomorrow, 26 Apr 2026',
        icon: Icons.calendar_today_outlined,
        iconColor: Color(0xFFEA580C),
        iconBackground: Color(0xFFFFF7ED),
      ),
      InviteDetailRow(
        label: 'Time',
        value: '6:00 PM - 8:00 PM',
        icon: Icons.schedule_rounded,
        iconColor: AppColors.brightGreen,
        iconBackground: AppColors.primaryLight,
      ),
      InviteDetailRow(
        label: 'Players Needed',
        value: '1 More Player',
        icon: Icons.groups_2_outlined,
        iconColor: AppColors.textSecondary,
        iconBackground: Color(0xFFF1F5F9),
        showDivider: false,
      ),
    ];

    return InviteToMatchSurface(
      padding: EdgeInsets.zero,
      child: Column(children: rows),
    );
  }
}
