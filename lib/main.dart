import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login/signup_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_page.dart';
import 'screens/messages/messages_page.dart';
import 'screens/profile/profile_page.dart';
import 'widgets/main_bottom_nav.dart';

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

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [HomePage(), MessagesPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
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
