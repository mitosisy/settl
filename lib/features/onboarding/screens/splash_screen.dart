import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/app_constants.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/onboarding/providers/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Wait for the splash animation duration
    await Future.delayed(
      const Duration(milliseconds: AppConstants.splashDurationMs),
    );

    if (!mounted) return;

    final status = ref.read(onboardingStatusProvider);

    switch (status) {
      case OnboardingStatus.completed:
        context.go('/home');
        break;
      case OnboardingStatus.showWalletSetup:
        context.go('/wallet_setup');
        break;
      case OnboardingStatus.showCarousel:
      case OnboardingStatus.loading:
        context.go('/onboarding');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo / Icon (mock)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandSaffron.withOpacity(0.3),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Icon(
                Icons.currency_bitcoin_rounded, // Temporary icon
                size: 64,
                color: AppColors.brandSaffron,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
            
            const SizedBox(height: 32),
            
            // App Name
            Text(
              Strings.appName,
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.brandSaffron,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
            
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              Strings.tagline,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
