import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/transactions/providers/transactions_provider.dart';
import 'package:chain_pay/features/wallet/widgets/recent_transactions.dart';
import 'package:chain_pay/core/widgets/gradient_scaffold.dart';
import 'package:chain_pay/core/widgets/top_nav_bar.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return GradientScaffold(
      appBar: const TopNavBar(isHome: false),
      body: transactionsAsyncValue.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Failed to load history',
            style: context.typography.bodyMedium?.copyWith(color: context.colors.error),
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 64,
                    color: context.colors.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Strings.emptyTransactions,
                    style: context.typography.bodyLarge?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.refresh(transactionsProvider);
            },
            color: context.colors.primary,
            backgroundColor: context.colors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 150, left: 24, right: 24, bottom: 24),
              child: Column(
                children: [
                  RecentTransactions(
                    transactions: transactions,
                    onTap: (tx) => context.push('/history/${tx.signature}', extra: tx),
                  ),
                  const SizedBox(height: 120), // Padding for floating nav
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
