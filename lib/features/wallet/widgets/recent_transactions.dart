import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
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
            Text(Strings.recent, style: context.typography.headlineMedium),
            if (transactions.isNotEmpty)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  Strings.viewAll,
                  style: context.typography.labelLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Transaction list or empty state
        if (transactions.isEmpty)
          _buildEmptyState(context)
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

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: context.colors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            Strings.emptyTransactions,
            style: context.typography.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
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
    final amountColor = isSent ? context.colors.error : Colors.green;
    final amountPrefix = isSent ? '- ' : '+ ';
    final directionIcon = isSent
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.colors.onSurface.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Direction icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(directionIcon, color: amountColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Name and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.truncateAddress(
                      isSent ? transaction.toAddress : transaction.fromAddress,
                    ),
                    style: context.typography.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.relativeTime(transaction.timestamp),
                    style: context.typography.labelSmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6)
                    ),
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
                  style: context.typography.bodyLarge?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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

  Color _getColor(BuildContext context) {
    return switch (status) {
      TransactionStatus.confirmed => Colors.green,
      TransactionStatus.pending => Colors.orange,
      TransactionStatus.queued => context.colors.secondary,
      TransactionStatus.failed => context.colors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status.displayName,
          style: context.typography.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
