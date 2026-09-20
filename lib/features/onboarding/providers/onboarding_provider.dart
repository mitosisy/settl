import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:settl/features/wallet/providers/wallet_provider.dart';

/// Indicates the current state of onboarding.
enum OnboardingStatus {
  /// App just launched, showing splash screen
  loading,
  /// Show the feature carousel
  showCarousel,
  /// Show the wallet setup screen (create/import)
  showWalletSetup,
  /// Wallet is set up, go to home screen
  completed,
}

/// Provider that determines the current onboarding status.
final onboardingStatusProvider = Provider<OnboardingStatus>((ref) {
  final walletState = ref.watch(walletProvider);

  if (walletState.isLoading) {
    return OnboardingStatus.loading;
  }

  if (walletState.hasWallet) {
    return OnboardingStatus.completed;
  }

  // If no wallet exists, we start at the carousel.
  // The UI will navigate to the wallet setup screen after the carousel.
  return OnboardingStatus.showCarousel;
});
