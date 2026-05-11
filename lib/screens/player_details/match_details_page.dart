import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/screens/player_details/group_chat_page.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/rally_header.dart';
import '../../widgets/player_details/player_details_components.dart';

class MatchDetailsPage extends StatelessWidget {
  final String title;
  final String sport;
  final String sportEmoji;
  final String when;
  final String location;
  final String address;
  final String players;
  final String level;
  final String host;
  final String imagePath;
  final String hostAvatarPath;
  final String about;
  final String spotsLeftLabel;

  const MatchDetailsPage({
    super.key,
    required this.title,
    required this.sport,
    required this.sportEmoji,
    required this.when,
    required this.location,
    required this.address,
    required this.players,
    required this.level,
    required this.host,
    required this.imagePath,
    required this.hostAvatarPath,
    required this.about,
    required this.spotsLeftLabel,
  });

  void _onBottomNavTap(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MainShell(initialIndex: index),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  void _openGroupChat(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const GroupChatPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'You will join the group chat and other players will be notified.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _openGroupChat(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Yes, Join',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Join this match?',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerSlot({required Widget avatar, required String label}) {
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          SizedBox(width: 60, height: 60, child: Center(child: avatar)),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: MainBottomNav(
        currentIndex: null,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            RallyHeader(
              title: 'Match Details',
              showBackButton: true,
              showNotificationButton: false,
              onBackTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  130,
                ),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePath,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(title, style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$sportEmoji  $sport',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PlayerDetailsInfoRow(
                    icon: Icons.calendar_today_outlined,
                    title: when,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PlayerDetailsInfoRow(
                    icon: Icons.location_on_outlined,
                    title: location,
                    subtitle: address,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PlayerDetailsInfoRow(
                    icon: Icons.groups_2_outlined,
                    title: '$players players joined',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PlayerDetailsInfoRow(
                    icon: Icons.bar_chart_rounded,
                    title: '$level Level',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          hostAvatarPath,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hosted by $host',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('About this match', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    about,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Players ($players)', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlayerSlot(
                        avatar: ClipOval(
                          child: Image.asset(
                            hostAvatarPath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        label: '$host\n(Host)',
                      ),
                      const SizedBox(width: 8),
                      _buildPlayerSlot(
                        avatar: const PlayerDetailsAvatar(
                          initials: 'YO',
                          size: 60,
                        ),
                        label: 'You',
                      ),
                      const SizedBox(width: 8),
                      _buildPlayerSlot(
                        avatar: const PlayerDetailsAvatar(
                          initials: 'PS',
                          size: 60,
                        ),
                        label: 'Priya',
                      ),
                      const SizedBox(width: 8),
                      _buildPlayerSlot(
                        avatar: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.primary,
                            size: 36,
                          ),
                        ),
                        label: '1 spot left',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _showJoinDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Join Match',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Message Host',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
