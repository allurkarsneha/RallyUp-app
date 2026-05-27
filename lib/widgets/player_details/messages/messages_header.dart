import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

/// Top bar used on every Messages-tab variant.
///
/// Right-side action:
///   * Callers that need a different right-side widget (e.g. the
///     primary Messages tab now wants a NotificationBellButton) pass
///     [trailing]. That widget is rendered as-is inside the same
///     52×52 circular slot the compose icon used to occupy, keeping
///     the header rhythm identical.
///   * If [trailing] is null we fall back to the legacy compose icon
///     wired through [onComposeTap]. The Unread and Group variants
///     still rely on this fallback, so removing the compose icon
///     wholesale would change layouts we haven't reviewed.
class MessagesHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool showMenuButton;
  final VoidCallback? onMenuTap;
  final VoidCallback? onComposeTap;
  final Widget? trailing;

  const MessagesHeader({
    super.key,
    this.title = 'Messages',
    this.showBackButton = false,
    this.showMenuButton = false,
    this.onMenuTap,
    this.onComposeTap,
    this.trailing,
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
          if (trailing != null)
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              child: trailing,
            )
          else
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
