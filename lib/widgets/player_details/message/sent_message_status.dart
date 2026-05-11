import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class SentMessageStatus extends StatelessWidget {
  final String time;
  final bool showTicks;

  const SentMessageStatus({
    super.key,
    required this.time,
    this.showTicks = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTicks) ...[
          const Icon(
            Icons.done_all_rounded,
            size: 15,
            color: AppColors.brightGreen,
          ),
          const SizedBox(width: 3),
        ],
        Text(
          time,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
