import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/models/merchant_model.dart';
import 'package:chain_pay/models/reputation_model.dart';
import 'package:chain_pay/features/scan_pay/providers/reputation_provider.dart';
import 'package:chain_pay/features/scan_pay/widgets/merchant_card.dart';
import 'package:chain_pay/features/scan_pay/widgets/reputation_badge.dart';
import 'package:chain_pay/features/scan_pay/widgets/trust_score_ring.dart';

class ReputationScreen extends ConsumerWidget {
  const ReputationScreen({super.key, required this.merchant});

  final MerchantModel merchant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reputationAsyncValue =
        ref.watch(merchantReputationProvider(merchant.walletAddress));

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text('Verify Merchant'),
        centerTitle: true,
      ),
      body: reputationAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandSaffron),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.brandRed, size: 48),
                const SizedBox(height: 16),
                Text('Failed to load reputation',
                    style: AppTypography.titleLarge),
                const SizedBox(height: 8),
                Text(error.toString(),
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(
                      merchantReputationProvider(merchant.walletAddress)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (reputation) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MerchantCard(merchant: merchant)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0, duration: 400.ms),
                const SizedBox(height: 48),

                // Trust Score Ring
                Center(
                  child: TrustScoreRing(
                    score: reputation.score,
                    verdict: reputation.verdict,
                  ),
                ),
                const SizedBox(height: 24),

                // Verdict Badge & Description
                Center(
                  child: ReputationBadge(verdict: reputation.verdict)
                      .animate()
                      .fadeIn(delay: 600.ms),
                ),
                const SizedBox(height: 16),
                Text(
                  _getVerdictDescription(reputation.verdict),
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 32),

                // Detailed metrics
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _MetricRow(
                        label: Strings.transactionCount,
                        value: reputation.txnCount.toString(),
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: Strings.walletAge,
                        value: '${reputation.walletAgeDays} days',
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: Strings.rugPullFlags,
                        value: reputation.rugPullFlags == 0
                            ? Strings.noneDetected
                            : reputation.rugPullFlags.toString(),
                        valueColor: reputation.rugPullFlags == 0
                            ? AppColors.brandGreen
                            : AppColors.brandRed,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1000.ms).slideY(
                    begin: 0.1, end: 0, duration: 400.ms, delay: 1000.ms),

                const Spacer(),

                // Actions
                if (reputation.verdict == ReputationVerdict.flagged)
                  TextButton(
                    onPressed: () => _navigateToAmountEntry(context),
                    child: Text(
                      Strings.riskOverride,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.brandRed,
                      ),
                    ),
                  ).animate().fadeIn(delay: 1200.ms)
                else
                  ElevatedButton(
                    onPressed: () => _navigateToAmountEntry(context),
                    child: const Text(Strings.continueToPay),
                  ).animate().fadeIn(delay: 1200.ms),

                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.pop(), // Go back to scanner
                  child: const Text(Strings.cancel),
                ).animate().fadeIn(delay: 1200.ms),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getVerdictDescription(ReputationVerdict verdict) {
    switch (verdict) {
      case ReputationVerdict.trusted:
        return Strings.verdictTrusted;
      case ReputationVerdict.unverified:
        return Strings.verdictCaution;
      case ReputationVerdict.flagged:
        return Strings.verdictDanger;
    }
  }

  void _navigateToAmountEntry(BuildContext context) {
    context.push('/scan/amount', extra: merchant);
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
