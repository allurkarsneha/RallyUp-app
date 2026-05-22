import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/signup_form_provider.dart';
import 'screens/auth_gate.dart';
import 'screens/home/home_page.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/signup_screen.dart';
import 'screens/messages/messages_page.dart';
import 'screens/profile/profile_page.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'theme/app_theme.dart';
import 'widgets/main_bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RallyUpApp());
}

class RallyUpApp extends StatelessWidget {
  const RallyUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserService>(create: (_) => UserService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(
            authService: ctx.read<AuthService>(),
            userService: ctx.read<UserService>(),
          ),
        ),
        ChangeNotifierProvider<SignupFormProvider>(
          create: (_) => SignupFormProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'RallyUp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final int initialIndex;

  /// A single app-wide key so any widget can switch the bottom-nav tab
  /// without destroying and recreating the shell (which previously also
  /// destroyed the AuthGate route, breaking sign-out gating).
  static final GlobalKey<MainShellState> globalKey =
      GlobalKey<MainShellState>();

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    MessagesPage(),
    ProfilePage(),
  ];

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

  /// Public entry point for switching the active bottom-nav tab from
  /// outside MainShell (e.g. the home avatar overlay's "Profile" option,
  /// or the side drawer's "Home"/"Settings" items).
  void switchTo(int index) {
    if (index < 0 || index >= _pages.length) return;
    if (_currentIndex == index) return;
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
    // When currentUser drops to null (during the brief window between
    // signOut/deleteAccount clearing the provider and AuthGate's rebuild
    // landing on the next frame), don't render the shell at all. Without
    // this guard the bottom-nav strip and the Scaffold's white body stay
    // on screen for that frame — which is exactly the "blank page" the
    // user sees after logout/delete.
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
