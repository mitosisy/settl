import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/models/reputation_model.dart';

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

  Color _ringColor(BuildContext context) {
    switch (verdict) {
      case ReputationVerdict.trusted:
        return Colors.green;
      case ReputationVerdict.unverified:
        return Colors.orange;
      case ReputationVerdict.flagged:
        return context.colors.error;
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
            color: context.colors.surfaceContainerHighest,
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
                color: _ringColor(context),
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
                  color: _ringColor(context).withValues(alpha: 0.2),
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
                style: context.typography.displayMedium?.copyWith(
                  color: context.colors.onSurface,
                  height: 1.1,
                ),
              ),
              Text(
                'Trust Score',
                style: context.typography.labelSmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
        ],
      ),
    );
  }
}
