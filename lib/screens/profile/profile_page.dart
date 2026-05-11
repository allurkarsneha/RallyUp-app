import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'profile_settings_screen.dart';
import 'subscription_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile & Preferences',
                    textAlign: TextAlign.left,
                    style: AppTextStyles.pageTitle,
                  ),
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

              Expanded(
                child: ListView(
                  children: [
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
                    ),
                    _settingsItem(
                      context: context,
                      title: 'Notifications',
                      subtitle: 'Manage notifications',
                    ),
                    _settingsItem(
                      context: context,
                      title: 'Feedback & Suggestions',
                      subtitle: 'Help and support',
                    ),
                    _settingsItem(
                      context: context,
                      title: 'Legal',
                      subtitle: 'Privacy policy, Terms of Service',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
