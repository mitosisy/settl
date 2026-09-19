import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/utils/formatters.dart';
import 'package:chain_pay/core/constants/strings.dart';

/// Glassmorphism balance card showing USDC and SOL balances.
///
/// Features frosted glass effect, saffron glow when balance > 0,
/// truncated address with tap-to-copy, and entrance animation.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.usdcBalance,
    required this.solBalance,
    required this.walletAddress,
    this.isLoading = false,
  });

  final double usdcBalance;
  final double solBalance;
  final String walletAddress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withAlpha(153),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: usdcBalance > 0
                  ? AppColors.brandSaffron.withAlpha(102)
                  : AppColors.textMuted.withAlpha(38),
            ),
            boxShadow: usdcBalance > 0
                ? [
                    BoxShadow(
                      color: AppColors.brandSaffron.withAlpha(51),
                      blurRadius: 24,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // USDC label
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.brandGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '\$',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('USDC', style: AppTypography.labelMedium),
                ],
              ),
              const SizedBox(height: 8),

              // USDC balance
              isLoading
                  ? _buildShimmer()
                  : Text(
                      Formatters.usdcAmount(usdcBalance),
                      style: AppTypography.displayLarge,
                    ),
              const SizedBox(height: 12),

              // SOL balance
              Text(
                'SOL: ${Formatters.solAmount(solBalance)}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 12),

              // Wallet address (tap to copy)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: walletAddress));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(Strings.addressCopied),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.truncateAddress(walletAddress),
                      style: AppTypography.monoMedium,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 200.ms, curve: Curves.easeOut);
  }

  Widget _buildShimmer() {
    return Container(
      width: 180,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
