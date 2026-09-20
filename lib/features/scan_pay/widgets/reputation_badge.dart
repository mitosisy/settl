import 'package:flutter/material.dart';

import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/models/reputation_model.dart';

/// A small inline badge showing the trust verdict and emoji.
class ReputationBadge extends StatelessWidget {
  const ReputationBadge({
    super.key,
    required this.verdict,
  });

  final ReputationVerdict verdict;

  Color _color(BuildContext context) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color(context).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(verdict.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            verdict.label,
            style: context.typography.labelMedium?.copyWith(color: _color(context)),
          ),
        ],
      ),
    );
  }
}
