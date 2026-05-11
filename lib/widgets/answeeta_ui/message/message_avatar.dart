import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class MessageAvatar extends StatelessWidget {
  final String imagePath;
  final double size;
  final bool showOnline;

  const MessageAvatar({
    super.key,
    required this.imagePath,
    this.size = 24,
    this.showOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        if (showOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: size <= 24 ? 7 : 12,
              height: size <= 24 ? 7 : 12,
              decoration: BoxDecoration(
                color: AppColors.brightGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
