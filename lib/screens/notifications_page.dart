import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../shared/widgets/main_bottom_nav.dart';
import '../shared/widgets/side_menu_drawer.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  void _onBottomNavTap(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainShell(initialIndex: index),
        transitionsBuilder: (_, animation, __, child) {
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
    final notifications = [
      {
        'title': 'Court booking confirmed',
        'subtitle': 'Your tennis court booking is confirmed.',
        'time': '2 min ago',
      },
      {
        'title': 'Match invite accepted',
        'subtitle': 'A player accepted your open match invite.',
        'time': '10 min ago',
      },
      {
        'title': 'Upcoming booking reminder',
        'subtitle': 'Your badminton booking starts in 1 hour.',
        'time': '1 hour ago',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideMenuDrawer(),
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
                  Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.menu_rounded,
                          size: 34,
                          color: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 18),
                  Text(
                    'Notifications',
                    style: AppTextStyles.pageTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  8,
                  AppSpacing.pageHorizontal,
                  24,
                ),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = notifications[index];

                  return Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['subtitle']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['time']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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