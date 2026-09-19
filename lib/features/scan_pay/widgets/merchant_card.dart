import 'package:flutter/material.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/utils/formatters.dart';
import 'package:chain_pay/models/merchant_model.dart';

/// Card displaying merchant details (name and truncated wallet address).
class MerchantCard extends StatelessWidget {
  const MerchantCard({
    super.key,
    required this.merchant,
  });

  final MerchantModel merchant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.textSecondary,
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
                  style: AppTypography.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.truncateAddress(merchant.walletAddress),
                  style: AppTypography.monoMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
