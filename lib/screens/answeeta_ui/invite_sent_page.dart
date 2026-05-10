import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class InviteSentPage extends StatelessWidget {
  const InviteSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
                  Icons.mark_email_read_outlined,
                  color: AppColors.primary,
                  size: 42,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Invite Sent!', style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your match invite has been sent to Alex Johnson.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              const AnsweetaCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        AnsweetaAvatar(initials: 'AJ', size: 52),
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
                              Text(
                                'Intermediate - Tennis - 0.8 mi',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    AnsweetaInfoRow(
                      icon: Icons.location_on_outlined,
                      title: 'Central Park Tennis Court',
                    ),
                    SizedBox(height: AppSpacing.md),
                    AnsweetaInfoRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Tomorrow, 26 Apr 2026',
                      subtitle: '6:00 - 8:00 PM',
                    ),
                    SizedBox(height: AppSpacing.md),
                    AnsweetaInfoRow(
                      icon: Icons.groups_2_outlined,
                      title: '1 More Player Needed',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const AnsweetaPrimaryButton(label: 'View Invites'),
              const SizedBox(height: AppSpacing.sm),
              const AnsweetaPrimaryButton(
                label: 'Back to Players',
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
