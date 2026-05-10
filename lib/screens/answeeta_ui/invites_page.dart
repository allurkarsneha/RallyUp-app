import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../shared/widgets/rally_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class InvitesPage extends StatelessWidget {
  const InvitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MainBottomNav(currentIndex: 0, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const RallyHeader(title: 'Invites', showBackButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: const [
                  Row(
                    children: [
                      Expanded(
                        child: AnsweetaChip(
                          label: 'Sent Invites',
                          selected: true,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(child: AnsweetaChip(label: 'Received Invites')),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text('Sent Invites (1)', style: AppTextStyles.sectionTitle),
                  SizedBox(height: AppSpacing.md),
                  _SentInviteCard(),
                  SizedBox(height: AppSpacing.lg),
                  _InviteMoreCard(),
                  SizedBox(height: AppSpacing.lg),
                  _InviteNotice(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentInviteCard extends StatelessWidget {
  const _SentInviteCard();

  @override
  Widget build(BuildContext context) {
    return const AnsweetaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnsweetaAvatar(initials: 'AJ', size: 52),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alex Johnson', style: AppTextStyles.bodyMedium),
                    SizedBox(height: AppSpacing.xs),
                    Text('Tennis - 0.8 mi', style: AppTextStyles.caption),
                  ],
                ),
              ),
              AnsweetaChip(label: 'Intermediate'),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AnsweetaInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Central Park Tennis Court',
          ),
          SizedBox(height: AppSpacing.sm),
          AnsweetaInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Tomorrow, 26 Apr 2026',
            subtitle: '6:00 - 8:00 PM',
          ),
          SizedBox(height: AppSpacing.sm),
          AnsweetaInfoRow(
            icon: Icons.groups_2_outlined,
            title: '1 More Player Needed',
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AnsweetaChip(label: 'Pending'),
              Spacer(),
              Text('Invited just now', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _InviteMoreCard extends StatelessWidget {
  const _InviteMoreCard();

  @override
  Widget build(BuildContext context) {
    return AnsweetaCard(
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'Invite more players to fill your game',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          AnsweetaPrimaryButton(
            label: 'Add Players',
            icon: Icons.person_add_alt_1_rounded,
          ),
        ],
      ),
    );
  }
}

class _InviteNotice extends StatelessWidget {
  const _InviteNotice();

  @override
  Widget build(BuildContext context) {
    return AnsweetaCard(
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Once your invite is accepted, it will move to your bookings.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
