import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/constants/app_constants.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/core/utils/formatters.dart';
import 'package:chain_pay/models/transaction_model.dart';
import 'package:chain_pay/core/widgets/gradient_scaffold.dart';
import 'package:chain_pay/core/widgets/glass_container.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isSent = transaction.type == TransactionType.sent;
    final amountColor = isSent ? context.colors.error : Colors.green;
    final amountPrefix = isSent ? '- ' : '+ ';

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 24),
        child: Column(
          children: [
            // Status Icon
            _StatusIcon(status: transaction.status)
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(),
            const SizedBox(height: 16),
            
            // Status Text
            Text(
              transaction.status.displayName,
              style: context.typography.titleLarge,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            
            // Amount
            Text(
              '${amountPrefix}USDC ${Formatters.usdcAmount(transaction.amountUsdc)}',
              style: context.typography.displayLarge?.copyWith(color: amountColor),
            ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 300.ms).fadeIn(delay: 300.ms),
            
            const SizedBox(height: 48),
            
            // Details Card
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Date',
                    value: Formatters.fullDateTime(transaction.timestamp),
                  ),
                  const Divider(height: 32),
                  _DetailRow(
                    label: isSent ? 'To' : 'From',
                    value: isSent ? transaction.toAddress : transaction.fromAddress,
                    copyable: true,
                  ),
                  if (transaction.networkFeeSol != null) ...[
                    const Divider(height: 32),
                    _DetailRow(
                      label: 'Network Fee',
                      value: Formatters.networkFee(transaction.networkFeeSol!),
                    ),
                  ],
                  if (transaction.memo != null) ...[
                    const Divider(height: 32),
                    _DetailRow(
                      label: 'Note',
                      value: transaction.memo!,
                    ),
                  ],
                  const Divider(height: 32),
                  _DetailRow(
                    label: 'Signature',
                    value: Formatters.truncateAddress(transaction.signature, prefixLen: 8, suffixLen: 8),
                    copyable: true,
                    fullValue: transaction.signature,
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 500.ms).fadeIn(delay: 500.ms),
            
            const SizedBox(height: 32),
            
            // View on Explorer
            if (transaction.status != TransactionStatus.queued)
              TextButton.icon(
                onPressed: () {
                  final url = AppConstants.solscanBaseUrl.replaceFirst('{signature}', transaction.signature);
                  launchUrlString(url);
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text(Strings.viewOnSolscan),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.primary,
                ),
              ).animate().fadeIn(delay: 700.ms),
              
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case TransactionStatus.confirmed:
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case TransactionStatus.pending:
      case TransactionStatus.queued:
        icon = Icons.schedule_rounded;
        color = context.colors.secondary;
        break;
      case TransactionStatus.failed:
        icon = Icons.cancel_rounded;
        color = context.colors.error;
        break;
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.fullValue,
  });

  final String label;
  final String value;
  final bool copyable;
  final String? fullValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: context.typography.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: copyable
                ? () {
                    Clipboard.setData(ClipboardData(text: fullValue ?? value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: context.typography.bodyMedium?.copyWith(
                      color: context.colors.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: context.colors.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
