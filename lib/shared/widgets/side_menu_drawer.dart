import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

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
                children: const [
                  _MenuItem(icon: Icons.home_outlined, title: 'Home'),
                  _MenuItem(icon: Icons.people_outline_rounded, title: 'Nearby Players'),
                  _MenuItem(icon: Icons.sports_tennis_rounded, title: 'Open Matches'),
                  _MenuItem(icon: Icons.location_on_outlined, title: 'Courts'),
                  _MenuItem(icon: Icons.mail_outline_rounded, title: 'Invites'),
                  _MenuItem(icon: Icons.calendar_month_outlined, title: 'My Bookings'),
                  _MenuItem(icon: Icons.notifications_none_rounded, title: 'Notifications'),
                  _MenuItem(icon: Icons.settings_outlined, title: 'Settings'),
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

  const _MenuItem({
    required this.icon,
    required this.title,
    this.isDanger = false,
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
        onTap: () {
          // We’ll wire actual navigation later once the main shell is ready.
        },
      ),
    );
  }
}