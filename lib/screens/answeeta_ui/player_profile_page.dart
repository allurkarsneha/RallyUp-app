import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../shared/widgets/rally_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class PlayerProfilePage extends StatelessWidget {
  const PlayerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const timings = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MainBottomNav(currentIndex: 2, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const RallyHeader(title: 'Player Profile', showBackButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: [
                  const Center(
                    child: AnsweetaAvatar(
                      initials: 'AJ',
                      size: 96,
                      online: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Text('Alex Johnson', style: AppTextStyles.pageTitle),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Center(
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      alignment: WrapAlignment.center,
                      children: [
                        AnsweetaChip(label: 'Tennis'),
                        AnsweetaChip(label: 'Intermediate'),
                        AnsweetaChip(label: '0.8 mi'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5A623),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text('4.8', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: const [
                      Expanded(
                        child: AnsweetaPrimaryButton(
                          label: 'Connect',
                          icon: Icons.person_add_alt_1_rounded,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AnsweetaPrimaryButton(
                          label: 'Invite',
                          icon: Icons.mail_outline_rounded,
                          outlined: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('About Alex', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'I love playing tennis and improving every day. Usually available in the evenings and weekends.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: const [
                      Expanded(
                        child: AnsweetaCard(
                          child: AnsweetaInfoRow(
                            icon: Icons.sports_tennis,
                            title: 'Tennis',
                            subtitle: 'Sports',
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AnsweetaCard(
                          child: AnsweetaInfoRow(
                            icon: Icons.bar_chart_rounded,
                            title: 'Intermediate',
                            subtitle: 'Skill Level',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Availability', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Days', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final day in days)
                        AnsweetaChip(label: day, selected: true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Daywise Timings', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AnsweetaCard(
                    child: Column(
                      children: [
                        for (final day in timings) ...[
                          _TimingRow(day: day),
                          if (day != timings.last)
                            const Divider(color: AppColors.border),
                        ],
                      ],
                    ),
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

class _TimingRow extends StatelessWidget {
  final String day;

  const _TimingRow({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(day, style: AppTextStyles.body)),
          Text(
            '9:00 PM - 11:55 PM',
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
