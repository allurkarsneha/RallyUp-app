import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/login_text_field.dart';
import '../../widgets/primary_button.dart';
import 'phone_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? formError;
  bool _busy = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(value);
  }

  Future<void> _login() async {
    setState(() {
      emailError = null;
      passwordError = null;
      formError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() => emailError = 'Enter a valid email');
      return;
    }
    if (password.isEmpty) {
      setState(() => passwordError = 'Password cannot be empty');
      return;
    }

    setState(() => _busy = true);
    try {
      await context.read<AuthService>().signInWithEmail(
            email: email,
            password: password,
          );
      if (!mounted) return;
      // AuthProvider's listener will detect the auth user and the gate
      // will route to MainShell (or onboarding if no profile yet).
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      setState(() => formError = _readable(e));
    } catch (_) {
      setState(() => formError = 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _readable(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return e.message ?? 'Login failed.';
    }
  }

  void _goToPhoneLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhoneScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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

                LoginTextField(
                  label: 'Email',
                  controller: emailController,
                ),

                if (emailError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    emailError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],

                const SizedBox(height: 28),

                LoginTextField(
                  label: 'Password',
                  controller: passwordController,
                  obscureText: true,
                ),

                if (passwordError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    passwordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],

                if (formError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    formError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],

                const SizedBox(height: 60),

                Center(
                  child: PrimaryButton(
                    text: _busy ? 'Logging in…' : 'Login',
                    width: 230,
                    height: 56,
                    backgroundColor: AppColors.darkGreen.withValues(alpha: 0.75),
                    onPressed: _busy ? () {} : _login,
                  ),
                ),

                const SizedBox(height: 60),

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

                const SizedBox(height: 40),

                PrimaryButton(
                  text: 'Continue with Phone',
                  backgroundColor: AppColors.brightGreen,
                  onPressed: _goToPhoneLogin,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
