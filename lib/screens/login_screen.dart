import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/login_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    debugPrint('Username: ${usernameController.text}');
    debugPrint('Password: ${passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 58),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.darkGreen,
                  size: 30,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
              ),

              const SizedBox(height: 34),

              LoginTextField(label: 'Username', controller: usernameController),

              const SizedBox(height: 28),

              LoginTextField(
                label: 'Password',
                controller: passwordController,
                obscureText: true,
              ),

              const SizedBox(height: 60),

              Center(
                child: PrimaryButton(
                  text: 'Login',
                  width: 230,
                  height: 56,
                  backgroundColor: AppColors.darkGreen.withOpacity(0.75),
                  onPressed: login,
                ),
              ),

              const SizedBox(height: 78),

              Row(
                children: const [
                  Expanded(
                    child: Divider(color: AppColors.mediumGray, thickness: 2),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: AppColors.grayText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.mediumGray, thickness: 2),
                  ),
                ],
              ),

              const SizedBox(height: 88),

              PrimaryButton(
                text: 'Continue with Email',
                backgroundColor: AppColors.brightGreen,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
