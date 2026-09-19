import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/core/utils/formatters.dart';
import 'package:chain_pay/features/payment_intent/providers/offline_queue_provider.dart';
import 'package:chain_pay/features/payment_intent/services/intent_signer.dart';
import 'package:chain_pay/models/merchant_model.dart';
import 'package:chain_pay/features/scan_pay/widgets/slide_to_pay_button.dart';

// Provides an IntentSigner instance for the confirm screen
final intentSignerProvider = Provider<IntentSigner>((ref) {
  final solanaService = ref.watch(solanaServiceProvider);
  return IntentSigner(solanaService: solanaService);
});

class ConfirmPayScreen extends ConsumerStatefulWidget {
  const ConfirmPayScreen({
    super.key,
    required this.merchant,
    required this.amountUsdc,
    this.memo,
  });

  final MerchantModel merchant;
  final double amountUsdc;
  final String? memo;

  @override
  ConsumerState<ConfirmPayScreen> createState() => _ConfirmPayScreenState();
}

class _ConfirmPayScreenState extends ConsumerState<ConfirmPayScreen> {
  bool _isProcessing = false;
  final double _estimatedNetworkFee = 0.000005; // Mock fixed fee

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    try {
      final signer = ref.read(intentSignerProvider);
      final broadcaster = ref.read(intentBroadcasterProvider);

      // Check real connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

      // Sign the intent locally
      final intent = await signer.signIntent(
        recipientAddress: widget.merchant.walletAddress,
        amountUsdc: widget.amountUsdc,
        memo: widget.memo,
        recipientName: widget.merchant.displayName,
        isOnline: isOnline,
      );

      // Enqueue the signed intent
      await broadcaster.enqueueIntent(intent);

      if (isOnline) {
        // Trigger a manual flush to try broadcasting immediately
        await broadcaster.manualFlush();
      }

      if (mounted) {
        // Show success indicator (Green if online, Amber if offline)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isOnline ? Icons.check_circle_rounded : Icons.offline_bolt_rounded,
                  color: isOnline ? AppColors.brandGreen : AppColors.brandAmber,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isOnline ? Strings.paymentSuccessful : Strings.offlineSigned,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.bgElevated,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Wait briefly so user sees the success state, then navigate home
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.brandRed),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text(Strings.confirmPayment),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Display
              Center(
                child: Column(
                  children: [
                    Text(
                      Strings.paying,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$ ',
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          Formatters.usdcAmount(widget.amountUsdc),
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, duration: 400.ms),

              const SizedBox(height: 48),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: Strings.to,
                      value: widget.merchant.displayName,
                      valueStyle: AppTypography.titleMedium,
                    ),
                    const Divider(height: 32),
                    _SummaryRow(
                      label: Strings.networkFee,
                      value: Formatters.networkFee(_estimatedNetworkFee),
                      valueStyle: AppTypography.bodyMedium,
                    ),
                    if (widget.memo != null) ...[
                      const Divider(height: 32),
                      _SummaryRow(
                        label: Strings.note,
                        value: widget.memo!,
                        valueStyle: AppTypography.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 200.ms),

              const Spacer(),

              // Warning / Info
              Text(
                'This transaction is secured on the Solana blockchain.',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // Slide to Pay
              SlideToPayButton(
                onConfirmed: _handlePayment,
                isLoading: _isProcessing,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
