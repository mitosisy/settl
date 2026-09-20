/// Application-wide constants for Settl.
class AppConstants {
  AppConstants._();

  // ─── Solana Network ────────────────────────────────────────────
  /// Solana Devnet JSON-RPC endpoint
  static const String solanaRpcUrl = 'https://api.devnet.solana.com';

  /// USDC SPL token mint address on Solana Devnet
  static const String usdcMintAddress =
      '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU';

  /// Solana Devnet faucet URL
  static const String devnetFaucetUrl = 'https://faucet.solana.com/';

  /// Solscan base URL for viewing transactions on devnet
  static const String solscanBaseUrl =
      'https://solscan.io/tx/{signature}?cluster=devnet';

  // ─── Timeouts & Retries ────────────────────────────────────────
  /// Default network timeout in milliseconds
  static const int networkTimeoutMs = 15000;

  /// Maximum number of retries for RPC calls
  static const int maxRetries = 3;

  /// Base delay for exponential backoff (milliseconds)
  static const int retryBaseDelayMs = 500;

  // ─── Offline Queue ─────────────────────────────────────────────
  /// Blockhash cache validity window (seconds).
  /// Solana blockhashes expire in ~60-90s.
  static const int blockhashValiditySec = 60;

  /// SQLite database name for offline payment queue
  static const String offlineQueueDbName = 'payment_queue.db';

  // ─── Reputation ────────────────────────────────────────────────
  /// Cache duration for reputation scores (minutes)
  static const int reputationCacheMinutes = 10;

  /// Score thresholds
  static const int trustedScoreThreshold = 70;
  static const int unverifiedScoreThreshold = 40;

  // ─── UI ────────────────────────────────────────────────────────
  /// Splash screen display duration (milliseconds)
  static const int splashDurationMs = 2200;

  /// Success screen auto-pop delay (milliseconds)
  static const int successAutoPopMs = 3000;

  /// Default transaction history fetch limit
  static const int defaultTxnHistoryLimit = 20;

  // ─── Hive Boxes ────────────────────────────────────────────────
  /// Hive box for wallet data
  static const String walletBoxName = 'wallet_box';

  /// Hive box for reputation cache
  static const String reputationBoxName = 'reputation_cache';

  /// Hive box for app settings
  static const String settingsBoxName = 'settings_box';

  // ─── Secure Storage Keys ───────────────────────────────────────
  /// Key for storing the private key in secure storage
  static const String privateKeyStorageKey = 'solana_private_key';

  /// Key for storing the mnemonic in secure storage
  static const String mnemonicStorageKey = 'solana_mnemonic';

  // ─── App Info ──────────────────────────────────────────────────
  static const String appName = 'Settl';
  static const String appVersion = '1.0.0';
  static const String networkName = 'Solana Devnet';
}
