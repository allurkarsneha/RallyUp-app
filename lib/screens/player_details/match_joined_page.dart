import 'package:flutter/material.dart';

import '../../widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/match_joined/match_joined_widgets.dart';
import '../my_bookings_page.dart';
import 'group_chat_page.dart';

class MatchJoinedPage extends StatelessWidget {
  const MatchJoinedPage({super.key});

  void _openGroupChat(BuildContext context) {
    Navigator.push(context, _fadeRoute<void>(const GroupChatPage()));
  }

  void _openMyBookings(BuildContext context) {
    Navigator.push(context, _fadeRoute<void>(const MyBookingsPage()));
  }

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
              MatchJoinedActionButtons(
                onGroupChatTap: () => _openGroupChat(context),
                onViewBookingsTap: () => _openMyBookings(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PageRouteBuilder<T> _fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
  );
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
