import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login/signup_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_page.dart';
import 'screens/messages/messages_page.dart';
import 'screens/profile/profile_page.dart';
import 'shared/widgets/main_bottom_nav.dart';

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
        '/main': (context) => const MainShell(),
      },
    );
  }
}

// This keeps the 3 main tabs in one place once the user enters the app.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomePage(), MessagesPage(), ProfilePage()];

  // Updates the selected bottom nav tab.
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
