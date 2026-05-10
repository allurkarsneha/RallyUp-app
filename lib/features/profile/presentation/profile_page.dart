import 'package:flutter/material.dart';
import '../../../shared/widgets/rally_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            RallyHeader(title: 'Profile'),
            Expanded(
              child: Center(
                child: Text('Profile screen placeholder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}