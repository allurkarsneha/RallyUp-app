import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/screens/courts_page.dart';
import 'package:rallyup/screens/my_bookings_page.dart';
import 'package:rallyup/screens/notifications_page.dart';
import 'package:rallyup/screens/player_details/invites_page.dart';
import 'package:rallyup/screens/player_details/nearby_players_page.dart';
import 'package:rallyup/screens/player_details/open_matches_page.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'user_avatar.dart';

class SideMenuDrawer extends StatelessWidget {
  final String userName;
  final String userSubtitle;
  final String? profileImagePath;

  const SideMenuDrawer({
    super.key,
    this.userName = 'Person name',
    this.userSubtitle = 'Verified Player',
    this.profileImagePath,
  });

  String _getInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _goToSignup(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4A4A4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Log out?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              fontSize: 16,
            ),
          ),
          content: Text(
            'Are you sure you want\nto logout of your\naccount?',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _goToSignup(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _openHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute<void>(const MainShell(initialIndex: 0)),
      (route) => false,
    );
  }

  void _openNearbyPlayers(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      _fadeRoute<void>(const NearbyPlayersPage()),
    );
  }

  void _openOpenMatches(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      _fadeRoute<void>(const OpenMatchesPage()),
    );
  }

  void _openCourts(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      _fadeRoute<void>(const CourtsPage()),
    );
  }

  void _openInvites(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      _fadeRoute<void>(const InvitesPage()),
    );
  }

  void _openMyBookings(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      _fadeRoute<void>(const MyBookingsPage()),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      _fadeRoute<void>(const NotificationsPage()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute<void>(const MainShell(initialIndex: 2)),
      (route) => false,
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (context.mounted) {
        _showLogoutDialog(context);
      }
    });
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
            _MenuHeader(
              userName: userName,
              userSubtitle: userSubtitle,
              profileImagePath: profileImagePath,
              initials: _getInitials(userName),
            ),
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
                  _MenuItem(
                    icon: Icons.people_outline_rounded,
                    title: 'Nearby Players',
                    onTap: () => _openNearbyPlayers(context),
                  ),
                  _MenuItem(
                    icon: Icons.sports_tennis_rounded,
                    title: 'Open Matches',
                    onTap: () => _openOpenMatches(context),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Courts',
                    onTap: () => _openCourts(context),
                  ),
                  _MenuItem(
                    icon: Icons.mail_outline_rounded,
                    title: 'Invites',
                    onTap: () => _openInvites(context),
                  ),
                  _MenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'My Bookings',
                    onTap: () => _openMyBookings(context),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => _openNotifications(context),
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => _openSettings(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _MenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDanger: true,
                onTap: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final String userName;
  final String userSubtitle;
  final String? profileImagePath;
  final String initials;

  const _MenuHeader({
    required this.userName,
    required this.userSubtitle,
    required this.profileImagePath,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Row(
        children: [
          UserAvatar(
            size: 52,
            initials: initials,
            imagePath: profileImagePath,
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                userSubtitle,
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