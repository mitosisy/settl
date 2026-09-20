import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/transactions/providers/transactions_provider.dart';
import 'package:chain_pay/features/wallet/widgets/recent_transactions.dart';
import 'package:chain_pay/core/widgets/gradient_scaffold.dart';
import 'package:chain_pay/core/widgets/top_nav_bar.dart';
import 'package:chain_pay/features/wallet/providers/wallet_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return GradientScaffold(
      appBar: const TopNavBar(isHome: false),
      body: Builder(
        builder: (context) {
          final transactions = transactionsAsyncValue.value;
          
          if (transactions != null) {
            if (transactions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(transactionsProvider);
                  await ref.read(walletProvider.notifier).refreshBalances();
                },
                color: context.colors.primary,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
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
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(transactionsProvider);
                await ref.read(walletProvider.notifier).refreshBalances();
              },
              color: context.colors.primary,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 135, left: 24, right: 24, bottom: 24),
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
          } else if (transactionsAsyncValue.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          } else {
            return Center(
              child: Text(
                'Failed to load history',
                style: context.typography.bodyMedium?.copyWith(color: context.colors.error),
              ),
            );
          }
        },
      ),
    );
  }
}
