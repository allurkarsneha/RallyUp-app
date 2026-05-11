import 'package:flutter/material.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/match_joined/match_joined_widgets.dart';

class MatchJoinedPage extends StatelessWidget {
  const MatchJoinedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(currentIndex: 1, onTap: (_) {}),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.xxl,
          ),
          child: Column(
            children: [
              const MatchJoinedSuccessHeader(),
              const SizedBox(height: AppSpacing.xxl),
              const MatchJoinedDetailsCard(),
              const SizedBox(height: AppSpacing.lg),
              const _MatchJoinedSummaryRow(label: 'Host', value: 'Alex'),
              const Divider(height: AppSpacing.lg, color: AppColors.border),
              const _MatchJoinedSummaryRow(
                label: 'Your Share',
                value: r'$4.95',
              ),
              const SizedBox(height: AppSpacing.lg),
              const MatchJoinedPaymentCard(),
              const SizedBox(height: AppSpacing.xl),
              const MatchJoinedActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchJoinedSummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _MatchJoinedSummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
