import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/screens/courts_page.dart';
import 'package:rallyup/screens/my_bookings_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  void _openHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainShell(initialIndex: 0),
      ),
      (route) => false,
    );
  }

  void _openMyBookings(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
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

  void _openCourts(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CourtsPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 288,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MenuHeader(),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                children: [
                  _MenuItem(
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () => _openHome(context),
                  ),
                  const _MenuItem(
                    icon: Icons.people_outline_rounded,
                    title: 'Nearby Players',
                  ),
                  const _MenuItem(
                    icon: Icons.sports_tennis_rounded,
                    title: 'Open Matches',
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Courts',
                    onTap: () => _openCourts(context),
                  ),
                  const _MenuItem(
                    icon: Icons.mail_outline_rounded,
                    title: 'Invites',
                  ),
                  _MenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'My Bookings',
                    onTap: () => _openMyBookings(context),
                  ),
                  const _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                  ),
                  const _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: _MenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDanger: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Sneha',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 4),
              Text(
                'Verified Player',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.isDanger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isDanger ? AppColors.warning : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(color: color),
        ),
        onTap: onTap,
      ),
    );
  }
}