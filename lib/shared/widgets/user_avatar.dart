import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final String initials;
  final String? imagePath;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.size,
    required this.initials,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: imagePath == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B38F5),
                  Color(0xFF39B54A),
                ],
              )
            : null,
        image: imagePath != null
            ? DecorationImage(
                image: AssetImage(imagePath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imagePath == null
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColors.surface,
                  fontSize: size * 0.34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}