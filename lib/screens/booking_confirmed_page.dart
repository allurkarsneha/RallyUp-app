import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/screens/my_bookings_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/main_bottom_nav.dart';

class BookingConfirmedPage extends StatelessWidget {
  final String courtName;
  final String sport;
  final String sportEmoji;
  final String imagePath;
  final String dateText;
  final String timeText;
  final int totalPlayers;
  final int confirmedPlayers;
  final int playersNeeded;
  final String totalAmount;

  const BookingConfirmedPage({
    super.key,
    required this.courtName,
    required this.sport,
    required this.sportEmoji,
    required this.imagePath,
    required this.dateText,
    required this.timeText,
    required this.totalPlayers,
    required this.confirmedPlayers,
    required this.playersNeeded,
    required this.totalAmount,
  });

  void _openShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share Match',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 16),
              _ShareOptionTile(
                icon: Icons.chat_rounded,
                title: 'WhatsApp',
                onTap: () => Navigator.pop(context),
              ),
              _ShareOptionTile(
                icon: Icons.link_rounded,
                title: 'Copy Link',
                onTap: () => Navigator.pop(context),
              ),
              _ShareOptionTile(
                icon: Icons.share_rounded,
                title: 'More',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMyBookings(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MyBookingsPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
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
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                8,
                AppSpacing.pageHorizontal,
                20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    const _ConfirmationGraphic(),
                    const SizedBox(height: 2),
                    Text(
                      'Booking Confirmed!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                imagePath,
                                width: 150,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
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
                                    const SizedBox(height: 8),
                                    Text(
                                      '$sportEmoji  $sport',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      dateText,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      timeText,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                        height: 1.25,
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
                    _SummaryRow(label: 'Total Players', value: '$totalPlayers'),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      label: 'Confirmed Players',
                      value: '$confirmedPlayers',
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      label: 'Players Needed',
                      value: '$playersNeeded',
                    ),
                    const SizedBox(height: 14),
                    _SummaryRow(
                      label: 'Total',
                      value: totalAmount,
                      isBold: true,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Share Match',
                      height: 48,
                      backgroundColor: AppColors.primary,
                      onPressed: () => _openShareOptions(context),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _openMyBookings(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          'View My Bookings',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: null,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }
}

class _ConfirmationGraphic extends StatelessWidget {
  const _ConfirmationGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/confetti.png',
            width: 400,
            height: 400,
            fit: BoxFit.contain,
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF1DB954),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.bodyMedium.copyWith(
      fontSize: 15,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: AppColors.textPrimary,
    );

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}