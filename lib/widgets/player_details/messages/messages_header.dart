import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class MessagesHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool showMenuButton;
  final VoidCallback? onMenuTap;
  final VoidCallback? onComposeTap;

  const MessagesHeader({
    super.key,
    this.title = 'Messages',
    this.showBackButton = false,
    this.showMenuButton = false,
    this.onMenuTap,
    this.onComposeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        18,
        AppSpacing.pageHorizontal,
        8,
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 30,
                color: AppColors.textPrimary,
              ),
            )
          else if (showMenuButton)
            IconButton(
              onPressed: onMenuTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.menu_rounded,
                size: 34,
                color: AppColors.textPrimary,
              ),
            )
          else
            const SizedBox(width: 34),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.pageTitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: onComposeTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}