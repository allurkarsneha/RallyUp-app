import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class MatchJoinedSuccessHeader extends StatelessWidget {
  const MatchJoinedSuccessHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: 150,
          height: 128,
          child: Stack(
            alignment: Alignment.center,
            children: const [
              _ConfettiMark(left: 18, top: 18, color: Color(0xFFF59E0B)),
              _ConfettiMark(right: 16, top: 22, color: Color(0xFF3B82F6)),
              _ConfettiMark(left: 30, bottom: 20, color: Color(0xFFEC4899)),
              _ConfettiMark(right: 30, bottom: 16, color: Color(0xFF22C55E)),
              _ConfettiDot(left: 10, top: 72, color: Color(0xFF22C55E)),
              _ConfettiDot(right: 8, top: 70, color: Color(0xFFF97316)),
              _SuccessCircle(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Match Joined!',
          style: AppTextStyles.pageTitle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "You're all set.",
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SuccessCircle extends StatelessWidget {
  const _SuccessCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.brightGreen.withValues(alpha: 0.26),
            blurRadius: 30,
            spreadRadius: 3,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.white, size: 48),
    );
  }
}

class _ConfettiMark extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final Color color;

  const _ConfettiMark({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: 0.65,
        child: Container(
          width: 7,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final Color color;

  const _ConfettiDot({this.left, this.right, this.top, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
