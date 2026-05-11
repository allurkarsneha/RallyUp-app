import 'package:flutter/material.dart';

import '../../shared/widgets/main_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/answeeta_ui/answeeta_ui_components.dart';

class InvitesPage extends StatelessWidget {
  const InvitesPage({super.key});

  static const String _alexAvatarPath =
      'assets/images/answeeta_ui/message_chat/alex_johnson.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      bottomNavigationBar: MainBottomNav(currentIndex: 0, onTap: (_) {}),
      body: SafeArea(
        child: Column(
          children: [
            const InvitesHeader(),
            const InvitesTabBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxl,
                ),
                children: [
                  Text(
                    'Sent Invites (1)',
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SentInviteCard(avatarImagePath: _alexAvatarPath),
                  const SizedBox(height: AppSpacing.xl),
                  const InviteMorePlayersCard(),
                  const SizedBox(height: AppSpacing.xl),
                  const InviteInfoCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
