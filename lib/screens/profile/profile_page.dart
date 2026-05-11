import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'profile_settings_screen.dart';
import 'subscription_screen.dart';
import 'account_settings_page.dart';
import 'block_list_page.dart';
import 'legal_page.dart';
import 'notifications_settings_page.dart';
import 'feedback_suggestions_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _goToSignup(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4A4A4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Delete Account?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              fontSize: 16,
            ),
          ),
          content: Text(
            'This action is permanent\nand cannot be undone.\nAll data will be lost.',
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
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _settingsItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodyMedium.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFBFC5CC), height: 1),
          ],
        ),
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 28),
            Text(
              text,
              style: AppTextStyles.sectionTitle.copyWith(
                color: color,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile & Preferences', style: AppTextStyles.pageTitle),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              Row(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF006A31), Color(0xFF003EA8)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'UP',
                      style: AppTextStyles.pageTitle.copyWith(
                        color: AppColors.white,
                        fontSize: 34,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Profile', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 4),
                      Text(
                        '22, Other',
                        style: AppTextStyles.body.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 22,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Santa Clara, CA',
                            style: AppTextStyles.body.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 42),

              _settingsItem(
                context: context,
                title: 'Player profile settings',
                subtitle: 'Player Details, Sports, Availability',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSettingsScreen(),
                    ),
                  );
                },
              ),

              _settingsItem(
                context: context,
                title: 'Account settings',
                subtitle: 'ID Verification, Profile visibility',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccountSettingsPage(),
                    ),
                  );
                },
              ),

              _settingsItem(
                context: context,
                title: 'Subscription',
                subtitle: 'Manage Plans',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen(),
                    ),
                  );
                },
              ),

              _settingsItem(
                context: context,
                title: 'Block List',
                subtitle: 'People you have blocked',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlockListPage()),
                  );
                },
              ),

              _settingsItem(
                context: context,
                title: 'Notifications',
                subtitle: 'Manage notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
              ),

              _settingsItem(
                context: context,
                title: 'Feedback & Suggestions',
                subtitle: 'Help and support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FeedbackSuggestionsPage(),
                    ),
                  );
                },
              ),

              _settingsItem(
                context: context,
                title: 'Legal',
                subtitle: 'Privacy policy, Terms of Service',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LegalPage()),
                  );
                },
              ),

              const SizedBox(height: 32),

              _actionRow(
                icon: Icons.logout_rounded,
                text: 'Logout',
                color: const Color(0xFFFF4B2B),
                onTap: () => _showLogoutDialog(context),
              ),

              _actionRow(
                icon: Icons.delete_outline_rounded,
                text: 'Delete Account',
                color: AppColors.textSecondary,
                onTap: () => _showDeleteDialog(context),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
