import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/core/constants/strings.dart';
import 'package:settl/models/merchant_model.dart';
import 'package:settl/models/reputation_model.dart';
import 'package:settl/features/scan_pay/providers/reputation_provider.dart';
import 'package:settl/features/scan_pay/widgets/merchant_card.dart';
import 'package:settl/features/scan_pay/widgets/reputation_badge.dart';
import 'package:settl/features/scan_pay/widgets/trust_score_ring.dart';
import 'package:settl/core/widgets/gradient_scaffold.dart';
import 'package:settl/core/widgets/glass_container.dart';

class ReputationScreen extends ConsumerWidget {
  const ReputationScreen({super.key, required this.merchant});

  final MerchantModel merchant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reputationAsyncValue =
        ref.watch(merchantReputationProvider(merchant.walletAddress));

    return GradientScaffold(
      appBar: AppBar(
        title: Text('Verify Merchant', style: context.typography.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: reputationAsyncValue.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    color: context.colors.error, size: 48),
                const SizedBox(height: 16),
                Text('Failed to load reputation',
                    style: context.typography.titleLarge),
                const SizedBox(height: 8),
                Text(error.toString(),
                    style: context.typography.bodyMedium,
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
            padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 24),
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
                  style: context.typography.bodyLarge?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 32),

                // Detailed metrics as Evidence bullets
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildEvidenceList(context, reputation),
                  ),
                ).animate().fadeIn(delay: 1000.ms).slideY(
                    begin: 0.1, end: 0, duration: 400.ms, delay: 1000.ms),

                const Spacer(),

                // Actions
                if (reputation.verdict == ReputationVerdict.flagged)
                  ElevatedButton(
                    onPressed: () => _navigateToAmountEntry(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.error,
                      foregroundColor: context.colors.onError,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(Strings.riskOverride),
                  ).animate().fadeIn(delay: 1200.ms)
                else
                  ElevatedButton(
                    onPressed: () => _navigateToAmountEntry(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(Strings.continueToPay),
                  ).animate().fadeIn(delay: 1200.ms),

                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.pop(), // Go back to scanner
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
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

  List<Widget> _buildEvidenceList(BuildContext context, ReputationModel rep) {
    final List<Widget> items = [];
    final v = rep.verdict;

    // Txn count / Age evidence
    if (v == ReputationVerdict.trusted) {
      items.add(_EvidenceRow(
        text: '${rep.txnCount} transactions over ${(rep.walletAgeDays / 30).floor()} months',
        color: Colors.green,
      ));
    } else if (v == ReputationVerdict.unverified) {
      items.add(_EvidenceRow(
        text: 'Only ${rep.txnCount} transactions in ${(rep.walletAgeDays / 30).floor()} months',
        color: Colors.orange,
      ));
      items.add(const SizedBox(height: 12));
      items.add(_EvidenceRow(
        text: 'Volume history too thin to verify',
        color: Colors.orange,
      ));
    } else {
      items.add(_EvidenceRow(
        text: 'Wallet created only ${rep.walletAgeDays} days ago',
        color: context.colors.error,
      ));
      items.add(const SizedBox(height: 12));
      items.add(_EvidenceRow(
        text: 'Just ${rep.txnCount} transactions on record',
        color: context.colors.error,
      ));
    }

    // Rug pull flags
    items.add(const SizedBox(height: 12));
    if (rep.rugPullFlags == 0) {
      items.add(_EvidenceRow(
        text: v == ReputationVerdict.trusted 
            ? 'High volume processed, zero rug-pull flags'
            : 'No rug-pull flags detected',
        color: v == ReputationVerdict.trusted ? Colors.green : Colors.orange,
      ));
    } else {
      items.add(_EvidenceRow(
        text: '${rep.rugPullFlags} rug-pull flag(s): >80% of balance moved in one txn',
        color: context.colors.error,
      ));
    }

    return items;
  }

  void _navigateToAmountEntry(BuildContext context) {
    if (merchant.amount != null && merchant.amount! > 0) {
      context.push('/scan_flow/confirm', extra: {
        'merchant': merchant,
        'amountUsdc': merchant.amount!,
        'memo': merchant.name, // Fallback if name was parsed from memo
      });
    } else {
      context.push('/scan_flow/amount', extra: merchant);
    }
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 12),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: context.typography.bodyMedium?.copyWith(
              color: context.colors.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
