import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:settl/core/constants/strings.dart';
import 'package:settl/features/wallet/providers/wallet_provider.dart';
import 'package:settl/features/wallet/widgets/balance_card.dart';
import 'package:settl/features/wallet/widgets/recent_transactions.dart';
import 'package:settl/features/payment_intent/providers/offline_queue_provider.dart';
import 'package:settl/features/scan_pay/providers/scanner_provider.dart';
import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/core/widgets/gradient_scaffold.dart';
import 'package:settl/core/widgets/top_nav_bar.dart';
import 'package:settl/features/transactions/providers/transactions_provider.dart';

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
    final transactionsAsync = ref.watch(transactionsProvider);

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

    return GradientScaffold(
      isHome: true,
      appBar: const TopNavBar(isHome: true),
      body: RefreshIndicator(
        color: context.colors.primary,
        backgroundColor: Colors.transparent,
        elevation: 0,
        onRefresh: () async {
          ref.invalidate(transactionsProvider);
          await ref.read(walletProvider.notifier).refreshBalances();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.only(top: 135, left: 24, right: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Welcome Back!',
                style: context.typography.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s your account overview',
                style: context.typography.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

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

              // Card Actions (Manage / Add Cash)
              Container(
                decoration: BoxDecoration(
                  color: context.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.add, size: 18, color: context.colors.onSurface),
                        label: Text(
                          'Add Cash',
                          style: context.typography.labelLarge?.copyWith(
                            color: context.colors.onSurface,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton.icon(
                          onPressed: () async {
                            final input = await _showManualEntryDialog(context);
                            if (input != null && input.trim().isNotEmpty) {
                              ref.read(scannerProvider.notifier).processManualEntry(input);
                            }
                          },
                          icon: Icon(Icons.send_rounded, size: 18, color: context.isDarkMode ? Colors.black : Colors.white),
                          label: Text(
                            'Send Money',
                            style: context.typography.labelLarge?.copyWith(
                              color: context.isDarkMode ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Recent transactions
              RecentTransactions(
                transactions: transactionsAsync.value?.take(3).toList() ?? [],
                onViewAll: () => context.push('/history'),
                onTap: (tx) => context.push('/history/${tx.signature}', extra: tx),
              ),
              const SizedBox(height: 120), // Bottom padding for floating nav
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.1)),
          ),
          backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
          title: Text('Send money', style: context.typography.headlineMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter a Solana address or UPI ID (e.g., alice@settl)', 
                   style: context.typography.bodyMedium),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: context.typography.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Address or @settl ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.08)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: context.typography.labelLarge?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.6))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Continue'),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );
      },
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
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count ${Strings.queuedBanner}',
              style: context.typography.bodyMedium?.copyWith(
                color: Colors.orange,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}
