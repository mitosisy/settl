/// All user-facing strings for ChainPay.
///
/// Centralised here to avoid hardcoded strings in UI widgets.
class Strings {
  Strings._();

  // ─── App ───────────────────────────────────────────────────────
  static const String appName = 'Settl';
  static const String tagline = 'Pay freely. Trust verifiably.';
  static const String networkBadge = 'Solana Devnet';

  // ─── Onboarding ────────────────────────────────────────────────
  static const String onboardingTitle1 = 'Scan. Verify. Pay.';
  static const String onboardingBody1 =
      'Check merchant trust before every payment';
  static const String onboardingTitle2 = 'No internet? No problem.';
  static const String onboardingBody2 =
      'Sign payments offline, broadcast when connected';
  static const String onboardingTitle3 = 'Your keys. Your money.';
  static const String onboardingBody3 =
      'Self-custody — no bank, no middleman';
  static const String getStarted = 'Get started';

  // ─── Wallet Setup ──────────────────────────────────────────────
  static const String createNewWallet = 'Create new wallet';
  static const String createWalletSubtitle =
      'Generate a new Solana wallet with a seed phrase';
  static const String importWallet = 'Import wallet';
  static const String importWalletSubtitle =
      'Restore an existing wallet using your 12-word seed phrase';
  static const String seedPhraseTitle = 'Your seed phrase';
  static const String seedPhraseWarning =
      'Write these words down and store them safely. '
      'Anyone with your seed phrase can access your funds.';
  static const String iveSavedThese = "I've saved these";
  static const String verifySeedPhrase = 'Verify your seed phrase';
  static const String selectWord = 'Select word #';
  static const String devnetSolPrompt =
      'First transaction? Get some devnet SOL';

  // ─── Home ──────────────────────────────────────────────────────
  static const String recent = 'Recent';
  static const String viewAll = 'View all';
  static const String emptyTransactions = 'Your payments will appear here';
  static const String scanAndPay = 'Scan & Pay';
  static const String receive = 'Receive';
  static const String history = 'History';
  static const String topUp = 'Top Up';
  static const String queuedBanner = 'payments queued — tap to review';

  // ─── Scanner ───────────────────────────────────────────────────
  static const String scannerOverlay = 'Point at a Settl or Solana Pay QR';
  static const String enterManually = 'Or enter address manually';
  static const String invalidQr = 'Invalid payment QR';

  // ─── Reputation ────────────────────────────────────────────────
  static const String merchantVerified = 'Merchant verified?';
  static const String continueToPay = 'Continue to pay';
  static const String cancel = 'Cancel';
  static const String transactionCount = 'Transaction count';
  static const String walletAge = 'Wallet age';
  static const String volumeProcessed = 'Volume processed';
  static const String send = 'Send';
  static const String rugPullFlags = 'Rug pull flags';
  static const String avgSettlementTime = 'Avg settlement time';
  static const String noneDetected = 'None detected';
  static const String verdictTrusted =
      'This merchant appears trustworthy. Safe to proceed.';
  static const String verdictCaution =
      'Limited history. Proceed with a small amount first.';
  static const String verdictDanger =
      'Suspicious activity detected. We recommend not paying.';
  static const String riskOverride = 'I understand the risk, pay anyway';

  // ─── Amount Entry ──────────────────────────────────────────────
  static const String paying = 'Paying';
  static const String addNote = 'Add a note (optional)';
  static const String proceed = 'Proceed';

  // ─── Confirm ───────────────────────────────────────────────────
  static const String confirmPayment = 'Confirm payment';
  static const String to = 'To';
  static const String amount = 'Amount';
  static const String networkFee = 'Network fee';
  static const String note = 'Note';
  static const String slideToPay = 'Slide to pay';
  static const String broadcasting = 'Broadcasting to Solana...';
  static const String offlineSigned =
      '⚡ Payment signed offline — will broadcast when connected';

  // ─── Success / Failure ─────────────────────────────────────────
  static const String paymentSuccessful = 'Payment successful';
  static const String paymentFailed = 'Payment failed';
  static const String viewOnSolscan = 'View on Solscan';
  static const String retry = 'Retry';
  static const String transactionHash = 'Transaction hash';

  // ─── Receive ───────────────────────────────────────────────────
  static const String receivePayment = 'Receive payment';
  static const String requestAmount = 'Request specific amount';
  static const String shareQr = 'Share QR';
  static const String copyAddress = 'Copy address';
  static const String addressCopied = 'Address copied to clipboard';

  // ─── History ───────────────────────────────────────────────────
  static const String all = 'All';
  static const String sent = 'Sent';
  static const String received = 'Received';
  static const String queued = 'Queued';
  static const String confirmed = 'Confirmed';
  static const String pending = 'Pending';
  static const String failed = 'Failed';

  // ─── Settings ──────────────────────────────────────────────────
  static const String settings = 'Settings';
  static const String displayName = 'Display name';
  static const String network = 'Network';
  static const String demoMode = 'Demo mode';
  static const String demoModeEnabled = 'Demo mode enabled';
  static const String demoModeDisabled = 'Demo mode disabled';
  static const String version = 'Version';

  // ─── Errors ────────────────────────────────────────────────────
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'Network error. Check your connection and try again.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String insufficientBalance =
      'Insufficient balance for this transaction.';
}
