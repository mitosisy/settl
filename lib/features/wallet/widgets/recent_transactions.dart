import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/utils/formatters.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/models/transaction_model.dart';

/// Displays a list of recent transactions with staggered animation.
///
/// Shows an empty state illustration when no transactions exist.
class RecentTransactions extends StatelessWidget {
  const RecentTransactions({
    super.key,
    required this.transactions,
    this.onViewAll,
    this.onTap,
  });

  final List<TransactionModel> transactions;
  final VoidCallback? onViewAll;
  final void Function(TransactionModel)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Strings.recent, style: AppTypography.headlineMedium),
            if (transactions.isNotEmpty)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  Strings.viewAll,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.brandSaffron,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Transaction list or empty state
        if (transactions.isEmpty)
          _buildEmptyState()
        else
          ...transactions.asMap().entries.map((entry) {
            return _TransactionTile(
              transaction: entry.value,
              onTap: () => onTap?.call(entry.value),
            )
                .animate()
                .fadeIn(
                  duration: 200.ms,
                  delay: (entry.key * 80).ms,
                )
                .slideX(begin: 0.05, end: 0, duration: 200.ms);
          }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            Strings.emptyTransactions,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single transaction row in the recent transactions list.
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    this.onTap,
  });

  final TransactionModel transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSent = transaction.type == TransactionType.sent;
    final amountColor = isSent ? AppColors.brandRed : AppColors.brandGreen;
    final amountPrefix = isSent ? '- ' : '+ ';
    final directionIcon = isSent
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.textMuted.withAlpha(25),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Direction icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: amountColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(directionIcon, color: amountColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Name and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.truncateAddress(
                      isSent ? transaction.toAddress : transaction.fromAddress,
                    ),
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.relativeTime(transaction.timestamp),
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),

            // Amount and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${amountPrefix}USDC ${Formatters.usdcAmount(transaction.amountUsdc)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                _StatusChip(status: transaction.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small colored chip showing transaction status.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TransactionStatus status;

  Color get _color {
    return switch (status) {
      TransactionStatus.confirmed => AppColors.brandGreen,
      TransactionStatus.pending => AppColors.brandAmber,
      TransactionStatus.queued => AppColors.solanaPurple,
      TransactionStatus.failed => AppColors.brandRed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status.displayName,
          style: AppTypography.labelSmall.copyWith(color: _color),
        ),
      ],
    );
  }
}
