
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chain_pay/core/utils/formatters.dart';
import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/widgets/glass_container.dart';

/// Glassmorphism balance card showing USDC and SOL balances.
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
    final isDark = context.isDarkMode;
    final innerCardColor = isDark ? Colors.white : Colors.black;
    final innerTextColor = isDark ? Colors.black : Colors.white;
    final innerMutedColor = isDark ? Colors.black54 : Colors.white54;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: GlassContainer(
        borderRadius: 32,
        padding: const EdgeInsets.all(8),
        borderOpacity: 0.2,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top layer (Glassy with address)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.resolveSettlId(walletAddress) ?? 'anon@settl',
                  style: context.typography.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Formatters.truncateAddress(walletAddress),
                  style: context.typography.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // Inner card
          Container(
            decoration: BoxDecoration(
              color: innerCardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Gold glowing Solana badge
                Positioned(
                  right: 24,
                  top: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'Solana',
                      style: context.typography.labelMedium?.copyWith(
                        color: isDark ? const Color(0xFF996515) : Colors.amber.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Credit',
                        style: context.typography.bodyMedium?.copyWith(
                          color: innerMutedColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      isLoading
                          ? _buildShimmer(innerCardColor)
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.usdcAmount(usdcBalance),
                                  style: context.typography.displayLarge?.copyWith(
                                    color: innerTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    'USDC',
                                    style: context.typography.titleMedium?.copyWith(
                                      color: innerMutedColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: innerTextColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/sol.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(innerMutedColor, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SOL Balance: ${solBalance.toStringAsFixed(4)}',
                              style: context.typography.labelMedium?.copyWith(
                                color: innerMutedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildShimmer(Color innerCardColor) {
    return Container(
      width: 180,
      height: 48,
      decoration: BoxDecoration(
        color: innerCardColor == Colors.black ? Colors.white24 : Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
