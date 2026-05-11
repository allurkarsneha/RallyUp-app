import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class GroupChatAvatar extends StatelessWidget {
  final String initials;
  final String? imagePath;
  final Color backgroundColor;
  final double size;

  const GroupChatAvatar({
    super.key,
    required this.initials,
    this.imagePath,
    this.backgroundColor = AppColors.primary,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: ClipOval(
        child: imagePath == null
            ? Center(
                child: Text(
                  initials,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : Image.asset(imagePath!, fit: BoxFit.cover),
      ),
    );
  }
}
