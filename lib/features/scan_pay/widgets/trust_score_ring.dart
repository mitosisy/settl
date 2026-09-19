import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/models/reputation_model.dart';

/// Animated circular progress ring showing the trust score.
class TrustScoreRing extends StatelessWidget {
  const TrustScoreRing({
    super.key,
    required this.score,
    required this.verdict,
    this.size = 120,
    this.strokeWidth = 10,
  });

  final int score;
  final ReputationVerdict verdict;
  final double size;
  final double strokeWidth;

  Color get _ringColor {
    switch (verdict) {
      case ReputationVerdict.trusted:
        return AppColors.brandGreen;
      case ReputationVerdict.unverified:
        return AppColors.brandAmber;
      case ReputationVerdict.flagged:
        return AppColors.brandRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            color: AppColors.bgElevated,
          ),
          
          // Animated progress ring
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                color: _ringColor,
                backgroundColor: Colors.transparent,
                strokeCap: StrokeCap.round,
              );
            },
          ),
          
          // Glow effect
          Container(
            width: size - (strokeWidth * 2),
            height: size - (strokeWidth * 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _ringColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms),
          
          // Score text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toString(),
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              Text(
                'Trust Score',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
        ],
      ),
    );
  }
}
