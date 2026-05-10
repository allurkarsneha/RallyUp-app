import 'package:flutter/material.dart';
import '../../shared/widgets/rally_header.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            RallyHeader(title: 'Messages'),
            Expanded(
              child: Center(
                child: Text('Messages screen placeholder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}