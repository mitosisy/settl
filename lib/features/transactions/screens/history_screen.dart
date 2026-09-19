import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/transactions/providers/transactions_provider.dart';
import 'package:chain_pay/features/wallet/widgets/recent_transactions.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text(Strings.history),
        centerTitle: true,
      ),
      body: transactionsAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandSaffron),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Failed to load history',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.brandRed),
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
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Strings.emptyTransactions,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
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
            color: AppColors.brandSaffron,
            backgroundColor: AppColors.bgCard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: RecentTransactions(
                transactions: transactions,
                onTap: (tx) => context.push('/history/${tx.signature}', extra: tx),
              ),
            ),
          );
        },
      ),
    );
  }
}
