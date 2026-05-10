import 'package:flutter/material.dart';

import '../../shared/widgets/rally_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class InviteToMatchPage extends StatelessWidget {
  const InviteToMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const RallyHeader(
              title: 'Invite to Match',
              showBackButton: true,
              showNotificationButton: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: [
                  Center(
                    child: Text(
                      'Send an invite to play together',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AnsweetaCard(
                    child: Row(
                      children: [
                        AnsweetaAvatar(initials: 'AJ', size: 58),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alex Johnson',
                                style: AppTextStyles.bodyMedium,
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  AnsweetaChip(label: 'Intermediate'),
                                  AnsweetaChip(label: 'Tennis'),
                                  AnsweetaChip(label: '0.8 mi'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _InviteField(
                    label: 'Sport',
                    value: 'Tennis',
                    icon: Icons.sports_tennis,
                  ),
                  const _InviteField(
                    label: 'Court',
                    value: 'Central Park Tennis Court',
                    icon: Icons.location_on_outlined,
                  ),
                  const _InviteField(
                    label: 'Date',
                    value: 'Tomorrow, 26 Apr 2026',
                    icon: Icons.calendar_today_outlined,
                  ),
                  const _InviteField(
                    label: 'Time',
                    value: '6:00 PM - 8:00 PM',
                    icon: Icons.schedule_rounded,
                  ),
                  const _InviteField(
                    label: 'Players Needed',
                    value: '1 More Player',
                    icon: Icons.groups_2_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Message (Optional)', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Hi Alex, want to join for a friendly match?',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('42/100', style: AppTextStyles.caption),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AnsweetaPrimaryButton(
                    label: 'Send Invite',
                    icon: Icons.send_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InviteField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AnsweetaCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AnsweetaInfoRow(icon: icon, title: value, subtitle: label),
      ),
    );
  }
}
