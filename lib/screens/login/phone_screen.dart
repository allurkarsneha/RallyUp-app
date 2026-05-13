import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/login_text_field.dart';
import '../../widgets/primary_button.dart';
import 'name_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final phoneController = TextEditingController();
  String? phoneError;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void continueToPhoto() {
    setState(() {
      phoneError = phoneController.text.trim().isEmpty
          ? 'Mobile number is required'
          : null;
    });

    if (phoneError != null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NameScreen()),
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
                "What’s your phone number?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
              ),

              const SizedBox(height: 28),

              LoginTextField(
                label: 'Mobile Number *',
                controller: phoneController,
              ),

              if (phoneError != null) ...[
                const SizedBox(height: 6),
                Text(
                  phoneError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const Spacer(),

              Center(
                child: PrimaryButton(
                  text: 'Continue',
                  width: 180,
                  height: 48,
                  backgroundColor: AppColors.darkGreen.withValues(alpha: 0.75),
                  onPressed: continueToPhoto,
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
