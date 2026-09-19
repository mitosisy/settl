import 'package:flutter/material.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/models/reputation_model.dart';

/// A small inline badge showing the trust verdict and emoji.
class ReputationBadge extends StatelessWidget {
  const ReputationBadge({
    super.key,
    required this.verdict,
  });

  final ReputationVerdict verdict;

  Color get _color {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(verdict.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            verdict.label,
            style: AppTypography.labelMedium.copyWith(color: _color),
          ),
        ],
      ),
    );
  }
}
