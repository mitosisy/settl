import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/constants/app_constants.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/onboarding/providers/onboarding_provider.dart';
import 'package:chain_pay/core/widgets/gradient_scaffold.dart';

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
    return GradientScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo / Icon (mock)
            Image.asset(
              'assets/splash/onboard_logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
            
            const SizedBox(height: 32),
            
            // App Name
            Text(
              Strings.appName,
              style: context.typography.displayLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w900,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
            
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              Strings.tagline,
              style: context.typography.titleMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
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
