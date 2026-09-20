import 'package:flutter/material.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/utils/formatters.dart';
import 'package:chain_pay/models/merchant_model.dart';
import 'package:chain_pay/core/widgets/glass_container.dart';

/// Card displaying merchant details (name and truncated wallet address).
class MerchantCard extends StatelessWidget {
  const MerchantCard({
    super.key,
    required this.merchant,
  });

  final MerchantModel merchant;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.onSurface.withValues(alpha: 0.1)),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.displayName,
                  style: context.typography.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (merchant.settlId != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    merchant.settlId!,
                    style: context.typography.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  Formatters.truncateAddress(merchant.walletAddress),
                  style: AppTypography.monoMedium.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
