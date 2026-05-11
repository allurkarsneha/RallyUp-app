import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'message_avatar.dart';
import 'sent_message_status.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final String avatarImagePath;
  final bool isMine;
  final bool showTicks;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.avatarImagePath,
    this.isMine = false,
    this.showTicks = false,
  });

  @override
  Widget build(BuildContext context) {
    final double maxBubbleWidth = MediaQuery.of(context).size.width * 0.54;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            MessageAvatar(imagePath: avatarImagePath, size: 24),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMine ? const Color(0xFFE8F5EA) : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMine ? 16 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 16),
                    ),
                    boxShadow: isMine
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.07),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SentMessageStatus(time: time, showTicks: isMine && showTicks),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
