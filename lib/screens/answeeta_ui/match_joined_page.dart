import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class MatchJoinedPage extends StatelessWidget {
  const MatchJoinedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: MainBottomNav(currentIndex: 1, onTap: (_) {}),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.xl,
            AppSpacing.pageHorizontal,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 52,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Match Joined!', style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'You are all set.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const AnsweetaCard(
                child: Column(
                  children: [
                    AnsweetaInfoRow(
                      icon: Icons.sports_tennis,
                      title: 'SCU Evening Tennis Match',
                    ),
                    SizedBox(height: AppSpacing.md),
                    AnsweetaInfoRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Sat, 17 May 2025',
                    ),
                    SizedBox(height: AppSpacing.md),
                    AnsweetaInfoRow(
                      icon: Icons.schedule_rounded,
                      title: '6:00 PM - 7:00 PM',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SummaryRow(label: 'Host', value: 'Alex'),
              const Divider(color: AppColors.border),
              const _SummaryRow(label: 'Your Share', value: r'$4.95'),
              const SizedBox(height: AppSpacing.lg),
              AnsweetaCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Please pay your share directly to the host.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const AnsweetaPrimaryButton(
                label: 'Go to Group Chat',
                icon: Icons.chat_bubble_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              const AnsweetaPrimaryButton(
                label: 'View My Bookings',
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
