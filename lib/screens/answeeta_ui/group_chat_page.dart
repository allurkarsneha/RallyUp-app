import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/answeeta_ui/group_chat/group_chat_widgets.dart';
import '../../widgets/answeeta_ui/message/message_input_bar.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({super.key});

  static const String _courtImagePath =
      'assets/images/answeeta_ui/open_matches/tennis_court.png';
  static const String _alexAvatarPath =
      'assets/images/answeeta_ui/message_chat/alex_johnson.png';
  static const String _priyaAvatarPath =
      'assets/images/answeeta_ui/open_matches/priya_avatar.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(currentIndex: 1, onTap: (_) {}),
      body: const SafeArea(
        child: Column(
          children: [
            GroupChatHeader(),
            Expanded(
              child: GroupChatMessageList(
                courtImagePath: _courtImagePath,
                alexAvatarPath: _alexAvatarPath,
                priyaAvatarPath: _priyaAvatarPath,
              ),
            ),
            MessageInputBar(),
            SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
