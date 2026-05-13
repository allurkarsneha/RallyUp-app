import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/login_text_field.dart';
import '../../widgets/primary_button.dart';
import 'photo_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  String? firstNameError;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void continueToPhone() {
    setState(() {
      firstNameError = firstNameController.text.trim().isEmpty
          ? 'First name is required'
          : null;
    });

    if (firstNameError != null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhotoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 54),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.darkGreen,
                  size: 28,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "What's your name?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
              ),

              const SizedBox(height: 28),

              LoginTextField(
                label: 'First Name *',
                controller: firstNameController,
              ),

              if (firstNameError != null) ...[
                const SizedBox(height: 6),
                Text(
                  firstNameError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 20),

              LoginTextField(
                label: 'Last Name',
                controller: lastNameController,
              ),

              const Spacer(),

              Center(
                child: PrimaryButton(
                  text: 'Continue',
                  width: 180,
                  height: 48,
                  backgroundColor: AppColors.darkGreen.withValues(alpha: 0.75),
                  onPressed: continueToPhone,
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}
