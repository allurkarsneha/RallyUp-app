import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  Widget buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(value, style: AppTextStyles.body.copyWith(fontSize: 16)),
        ),
      ],
    );
  }

  Widget buildArrowRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body.copyWith(fontSize: 17)),

          const Icon(Icons.chevron_right, color: AppColors.primary, size: 28),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 52),

                  Text('Profile Settings', style: AppTextStyles.pageTitle),
                ],
              ),

              const SizedBox(height: 30),

              Center(
                child: Container(
                  width: 100,
                  height: 100,
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
                      fontSize: 40,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              buildField('First Name', 'User'),

              const SizedBox(height: 18),

              buildField('Last Name', 'Profile'),

              const SizedBox(height: 18),

              buildField('Age', '22'),

              const SizedBox(height: 18),

              buildField('Postal Code', '95050'),

              const SizedBox(height: 28),

              buildArrowRow('Sports'),

              buildArrowRow('Availability'),
            ],
          ),
        ),
      ),
    );
  }
}
