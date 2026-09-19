/// Trust verdict based on the reputation score.
enum ReputationVerdict {
  /// Score ≥ 70 — merchant appears trustworthy
  trusted,

  /// Score 40–69 — limited history, proceed cautiously
  unverified,

  /// Score < 40 — suspicious activity detected
  flagged;

  String get emoji {
    return switch (this) {
      ReputationVerdict.trusted => '✅',
      ReputationVerdict.unverified => '⚠️',
      ReputationVerdict.flagged => '🚨',
    };
  }

  String get label {
    return switch (this) {
      ReputationVerdict.trusted => 'Trusted',
      ReputationVerdict.unverified => 'Unverified',
      ReputationVerdict.flagged => 'Flagged',
    };
  }
}

/// On-chain reputation score for a merchant wallet.
class ReputationModel {
  const ReputationModel({
    required this.score,
    required this.txnCount,
    required this.walletAgeDays,
    required this.volumeUsdc,
    required this.rugPullFlags,
    required this.verdict,
    this.avgSettlementTimeSec,
    this.cachedAt,
  });

  /// Weighted reputation score (0–100).
  final int score;

  /// Total number of transactions on this wallet.
  final int txnCount;

  /// Age of the wallet in days (since first transaction).
  final int walletAgeDays;

  /// Total USDC volume processed.
  final double volumeUsdc;

  /// Number of rug-pull flags detected.
  final int rugPullFlags;

  /// Computed verdict based on score thresholds.
  final ReputationVerdict verdict;

  /// Average settlement time in seconds (if available).
  final double? avgSettlementTimeSec;

  /// When this score was cached (for TTL checks).
  final DateTime? cachedAt;

  Map<String, dynamic> toJson() => {
        'score': score,
        'txnCount': txnCount,
        'walletAgeDays': walletAgeDays,
        'volumeUsdc': volumeUsdc,
        'rugPullFlags': rugPullFlags,
        'verdict': verdict.name,
        'avgSettlementTimeSec': avgSettlementTimeSec,
        'cachedAt': cachedAt?.toIso8601String(),
      };

  factory ReputationModel.fromJson(Map<String, dynamic> json) =>
      ReputationModel(
        score: json['score'] as int,
        txnCount: json['txnCount'] as int,
        walletAgeDays: json['walletAgeDays'] as int,
        volumeUsdc: (json['volumeUsdc'] as num).toDouble(),
        rugPullFlags: json['rugPullFlags'] as int,
        verdict: ReputationVerdict.values.byName(json['verdict'] as String),
        avgSettlementTimeSec:
            (json['avgSettlementTimeSec'] as num?)?.toDouble(),
        cachedAt: json['cachedAt'] != null
            ? DateTime.parse(json['cachedAt'] as String)
            : null,
      );
}
