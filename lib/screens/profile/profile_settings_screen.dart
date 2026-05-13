import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController ageController;
  late TextEditingController postalCodeController;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(text: 'User');
    lastNameController = TextEditingController(text: 'Profile');
    ageController = TextEditingController(text: '22');
    postalCodeController = TextEditingController(text: '95050');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
  }) {
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

        TextField(
          controller: controller,
          style: AppTextStyles.body.copyWith(fontSize: 16),

          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEDEDED),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
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
        child: SingleChildScrollView(
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

              buildField(label: 'First Name', controller: firstNameController),

              const SizedBox(height: 18),

              buildField(label: 'Last Name', controller: lastNameController),

              const SizedBox(height: 18),

              buildField(label: 'Age', controller: ageController),

              const SizedBox(height: 18),

              buildField(
                label: 'Postal Code',
                controller: postalCodeController,
              ),

              const SizedBox(height: 28),

              buildArrowRow('Sports'),

              buildArrowRow('Availability'),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
