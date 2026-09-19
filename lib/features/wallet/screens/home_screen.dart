import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/wallet/providers/wallet_provider.dart';
import 'package:chain_pay/features/wallet/widgets/balance_card.dart';
import 'package:chain_pay/features/wallet/widgets/quick_action_row.dart';
import 'package:chain_pay/features/wallet/widgets/recent_transactions.dart';
import 'package:chain_pay/features/payment_intent/providers/offline_queue_provider.dart';
import 'package:chain_pay/features/scan_pay/providers/scanner_provider.dart';

/// Main home screen showing balance, actions, and recent transactions.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load wallet and refresh balances on screen entry
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final queuedCount = ref.watch(queuedIntentCountProvider);

    // Listen for manual entry / search bar resolution
    ref.listen(scannerProvider, (previous, next) {
      if (next.merchant != null && !next.isScanning) {
        context.push('/scan/reputation', extra: next.merchant);
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: AppColors.brandSaffron,
        backgroundColor: AppColors.bgCard,
        onRefresh: () async {
          await ref.read(walletProvider.notifier).refreshBalances();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search address or @settl ID',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: AppTypography.bodyMedium,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref.read(scannerProvider.notifier).processManualEntry(value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Balance card
              BalanceCard(
                usdcBalance: wallet.usdcBalance,
                solBalance: wallet.solBalance,
                walletAddress: wallet.address ?? '',
                isLoading: wallet.isLoading,
              ),
              const SizedBox(height: 24),

              // Offline queue banner
              if (queuedCount > 0) ...[
                _OfflineQueueBanner(count: queuedCount),
                const SizedBox(height: 16),
              ],

              // Quick actions
              QuickActionRow(
                onScanPay: () => context.push('/scan'),
                onReceive: () => context.push('/receive'),
                onHistory: () => context.push('/history'),
                onTopUp: () async {
                  final input = await _showManualEntryDialog(context);
                  if (input != null && input.trim().isNotEmpty) {
                    ref.read(scannerProvider.notifier).processManualEntry(input);
                  }
                },
              ),
              const SizedBox(height: 32),

              // Recent transactions
              RecentTransactions(
                transactions: const [], // TODO: Connect to real data
                onViewAll: () => context.push('/history'),
                onTap: (tx) => context.push('/history/${tx.signature}'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgDeep,
      title: Row(
        children: [
          Text(
            Strings.appName,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.brandSaffron,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.solanaPurple.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              Strings.networkBadge,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.solanaPurple,
              ),
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => context.push('/settings'),
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text('Manual Entry', style: AppTypography.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter a Solana address or UPI ID (e.g., alice@settl)', 
                 style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: AppTypography.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Address or @settl ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

/// Amber banner shown when payments are queued offline.
class _OfflineQueueBanner extends StatelessWidget {
  const _OfflineQueueBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.brandAmber.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandAmber.withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: AppColors.brandAmber,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count ${Strings.queuedBanner}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.brandAmber,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.brandAmber,
          ),
        ],
      ),
    );
  }
}
