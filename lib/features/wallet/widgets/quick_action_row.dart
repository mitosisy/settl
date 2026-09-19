import 'package:flutter/material.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';

/// Row of 4 quick action buttons: Scan & Pay, Receive, History, Top Up.
///
/// Scan & Pay is highlighted with saffron background to signal primary action.
class QuickActionRow extends StatelessWidget {
  const QuickActionRow({
    super.key,
    required this.onScanPay,
    required this.onReceive,
    required this.onHistory,
    required this.onTopUp,
  });

  final VoidCallback onScanPay;
  final VoidCallback onReceive;
  final VoidCallback onHistory;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickActionItem(
          icon: Icons.qr_code_scanner_rounded,
          label: Strings.scanAndPay,
          onTap: onScanPay,
          isPrimary: true,
        ),
        _QuickActionItem(
          icon: Icons.arrow_downward_rounded,
          label: Strings.receive,
          onTap: onReceive,
        ),
        _QuickActionItem(
          icon: Icons.receipt_long_rounded,
          label: Strings.history,
          onTap: onHistory,
        ),
        _QuickActionItem(
          icon: Icons.send_rounded,
          label: Strings.send,
          onTap: onTopUp, // We will rename the parameter later or just use it as is
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.brandSaffron : AppColors.bgElevated,
              shape: BoxShape.circle,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.brandSaffron.withAlpha(77),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isPrimary ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
