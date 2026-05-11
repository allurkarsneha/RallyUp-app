import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/screens/booking_confirmed_page.dart';
import 'package:rallyup/screens/notifications_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/main_bottom_nav.dart';

class ConfirmBookingPage extends StatelessWidget {
  final String courtName;
  final String sport;
  final String sportEmoji;
  final String imagePath;
  final String dateText;
  final String timeText;
  final String priceText;
  final String matchType;
  final int totalPlayers;
  final int confirmedPlayers;

  const ConfirmBookingPage({
    super.key,
    required this.courtName,
    required this.sport,
    required this.sportEmoji,
    required this.imagePath,
    required this.dateText,
    required this.timeText,
    required this.priceText,
    required this.matchType,
    required this.totalPlayers,
    required this.confirmedPlayers,
  });

  int get playersNeeded {
    final value = totalPlayers - confirmedPlayers;
    return value < 0 ? 0 : value;
  }

  double get courtPrice => 18.00;
  double get taxesAndFees => 2.00;
  double get serviceFee => 1.80;
  double get totalAmount => courtPrice + taxesAndFees + serviceFee;

  double get eachPlayerPays {
    if (totalPlayers <= 0) return 0;
    return totalAmount / totalPlayers;
  }

  void _openNotificationsPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const NotificationsPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openBookingConfirmed(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => BookingConfirmedPage(
          courtName: courtName,
          sport: sport,
          sportEmoji: sportEmoji,
          imagePath: imagePath,
          dateText: dateText,
          timeText: timeText,
          totalPlayers: totalPlayers,
          confirmedPlayers: confirmedPlayers,
          playersNeeded: playersNeeded,
          totalAmount: '\$${totalAmount.toStringAsFixed(2)}',
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MainShell(initialIndex: index),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool valueGreen = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 170,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueGreen ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchTypeLabel =
        matchType == 'Open Match' ? 'Open match' : 'Private match';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                18,
                AppSpacing.pageHorizontal,
                10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Confirm Booking',
                    style: AppTextStyles.pageTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _openNotificationsPage(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 30,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  8,
                  AppSpacing.pageHorizontal,
                  24,
                ),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(16, 0, 0, 0),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              imagePath,
                              width: 100,
                              height: 88,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courtName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$sportEmoji  $sport',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    dateText,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeText,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    priceText,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Booking Details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    'Match type',
                    matchTypeLabel,
                    valueGreen: true,
                  ),
                  _buildDetailRow('Total Players', '$totalPlayers'),
                  _buildDetailRow(
                    'Confirmed Players',
                    '$confirmedPlayers (including you)',
                  ),
                  _buildDetailRow('Players Needed', '$playersNeeded'),
                  const Divider(color: AppColors.border, height: 28),
                  Text(
                    'Price Details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    'Court Price (1 hour)',
                    '\$${courtPrice.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Taxes and Fees',
                    '\$${taxesAndFees.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Service Fee',
                    '\$${serviceFee.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Total',
                    '\$${totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  const Divider(color: AppColors.border, height: 28),
                  Text(
                    'Cost Split',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    'Total Amount',
                    '\$${totalAmount.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow('Split Between', '$totalPlayers'),
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Each player pays',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${eachPlayerPays.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _openBookingConfirmed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm Booking',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secure Payment',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: null,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }
}