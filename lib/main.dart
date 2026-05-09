import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RallyUpApp());
}

class RallyUpApp extends StatelessWidget {
  const RallyUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RallyUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
