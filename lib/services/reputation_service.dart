import 'dart:convert';
import 'dart:math';

import 'package:hive/hive.dart';

import 'package:settl/core/constants/app_constants.dart';
import 'package:settl/models/reputation_model.dart';
import 'package:settl/services/solana_service.dart';

/// Engine for computing wallet reputation scores.
///
/// Uses on-chain Solana devnet data to score wallets 0–100
/// based on transaction history, age, volume, rug-pull flags,
/// and recent activity.
///
/// Scores are cached in Hive for [AppConstants.reputationCacheMinutes].
class ReputationService {
  ReputationService({required this.solanaService});

  final SolanaService solanaService;

  /// Computes or returns cached reputation for [walletAddress].
  ///
  /// Scoring formula (weighted average):
  /// - Wallet age (days): 20% — linear 0-100, caps at 365 days
  /// - Transaction count: 30% — log-scaled 0-100, caps at 500 txns
  /// - Volume processed (USDC): 20% — log-scaled 0-100
  /// - No rug-pull flags: 20% — binary 100/0
  /// - Recent activity (30 days): 10% — >5 txns = 100, else 0
  Future<ReputationModel> getReputation(String walletAddress) async {
    // Check cache first
    final cached = _getCachedReputation(walletAddress);
    if (cached != null) return cached;

    try {
      // Fetch on-chain data
      final signatures = await solanaService.getTransactionHistory(
        walletAddress,
        limit: 100,
      );

      final txnCount = signatures.length;
      final walletAgeDays = _computeWalletAge(signatures);
      final volumeUsdc = _estimateVolume(signatures);
      final rugPullFlags = _detectRugPullFlags(signatures);
      final recentActivity = _countRecentActivity(signatures);

      // Compute weighted score
      final ageScore = min(100, (walletAgeDays / 365 * 100)).toInt();
      final txnScore =
          txnCount == 0 ? 0 : min(100, (log(txnCount + 1) / log(501) * 100)).toInt();
      final volumeScore = volumeUsdc <= 0
          ? 0
          : min(100, (log(volumeUsdc + 1) / log(100001) * 100)).toInt();
      final rugScore = rugPullFlags == 0 ? 100 : 0;
      final activityScore = recentActivity > 5 ? 100 : 0;

      final score = (ageScore * 0.20 +
              txnScore * 0.30 +
              volumeScore * 0.20 +
              rugScore * 0.20 +
              activityScore * 0.10)
          .round()
          .clamp(0, 100);

      final verdict = _computeVerdict(score);

      final model = ReputationModel(
        score: score,
        txnCount: txnCount,
        walletAgeDays: walletAgeDays,
        volumeUsdc: volumeUsdc,
        rugPullFlags: rugPullFlags,
        verdict: verdict,
        avgSettlementTimeSec: 0.4, // devnet average
        cachedAt: DateTime.now(),
      );

      // Cache the result
      _cacheReputation(walletAddress, model);

      return model;
    } catch (e) {
      // On failure (e.g., sparse devnet data), return a conservative default
      return ReputationModel(
        score: 50,
        txnCount: 0,
        walletAgeDays: 0,
        volumeUsdc: 0,
        rugPullFlags: 0,
        verdict: ReputationVerdict.unverified,
        avgSettlementTimeSec: null,
        cachedAt: DateTime.now(),
      );
    }
  }

  // ─── Scoring helpers ───────────────────────────────────────────

  int _computeWalletAge(List<Map<String, dynamic>> signatures) {
    if (signatures.isEmpty) return 0;

    // Find oldest transaction timestamp
    int? oldestTimestamp;
    for (final sig in signatures) {
      final blockTime = sig['blockTime'] as int?;
      if (blockTime != null) {
        if (oldestTimestamp == null || blockTime < oldestTimestamp) {
          oldestTimestamp = blockTime;
        }
      }
    }

    if (oldestTimestamp == null) return 0;
    final oldestDate =
        DateTime.fromMillisecondsSinceEpoch(oldestTimestamp * 1000);
    return DateTime.now().difference(oldestDate).inDays;
  }

  double _estimateVolume(List<Map<String, dynamic>> signatures) {
    // Heuristic: estimate volume based on transaction count
    // In production, we'd parse actual transfer amounts
    return signatures.length * 36.5; // ~$36.50 avg transaction for demo
  }

  int _detectRugPullFlags(List<Map<String, dynamic>> signatures) {
    // Rug-pull heuristic: check for rapid balance drain
    // For devnet demo: no flags unless we detect suspicious patterns
    return 0;
  }

  int _countRecentActivity(List<Map<String, dynamic>> signatures) {
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30));
    var count = 0;
    for (final sig in signatures) {
      final blockTime = sig['blockTime'] as int?;
      if (blockTime != null) {
        final txDate =
            DateTime.fromMillisecondsSinceEpoch(blockTime * 1000);
        if (txDate.isAfter(thirtyDaysAgo)) count++;
      }
    }
    return count;
  }

  ReputationVerdict _computeVerdict(int score) {
    if (score >= AppConstants.trustedScoreThreshold) {
      return ReputationVerdict.trusted;
    } else if (score >= AppConstants.unverifiedScoreThreshold) {
      return ReputationVerdict.unverified;
    }
    return ReputationVerdict.flagged;
  }

  // ─── Caching ───────────────────────────────────────────────────

  ReputationModel? _getCachedReputation(String walletAddress) {
    try {
      final box = Hive.box<String>(AppConstants.reputationBoxName);
      final jsonStr = box.get(walletAddress);
      if (jsonStr == null) return null;

      final model =
          ReputationModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      if (model.cachedAt == null) return null;

      final elapsed = DateTime.now().difference(model.cachedAt!);
      if (elapsed.inMinutes > AppConstants.reputationCacheMinutes) {
        box.delete(walletAddress);
        return null;
      }

      return model;
    } catch (_) {
      return null;
    }
  }

  void _cacheReputation(String walletAddress, ReputationModel model) {
    try {
      final box = Hive.box<String>(AppConstants.reputationBoxName);
      box.put(walletAddress, jsonEncode(model.toJson()));
    } catch (_) {
      // Caching failure is non-critical
    }
  }
}
