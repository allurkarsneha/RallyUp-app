import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool profileVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            children: [
              const SizedBox(height: 32),

              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  Text('Account Settings', style: AppTextStyles.pageTitle),
                ],
              ),

              const SizedBox(height: 58),

              Container(
                width: 96,
                height: 96,
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
                    fontSize: 38,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile Verification',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 18),
                ),
              ),

              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Verify your profile by uploading a photo of\nyour ID!',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: 205,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFA7E1B1),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Upload Photo',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 104),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Visibility',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Have your profile visible to\nother members of the\ncommunity',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Switch(
                    value: profileVisible,
                    activeThumbColor: AppColors.white,
                    activeTrackColor: AppColors.brightGreen,
                    inactiveThumbColor: AppColors.white,
                    inactiveTrackColor: AppColors.textSecondary,
                    onChanged: (value) {
                      setState(() {
                        profileVisible = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
