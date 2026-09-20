import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/features/onboarding/screens/splash_screen.dart';
import 'package:chain_pay/features/onboarding/screens/onboarding_carousel.dart';
import 'package:chain_pay/features/onboarding/screens/wallet_setup_screen.dart';
import 'package:chain_pay/features/wallet/screens/home_screen.dart';
import 'package:chain_pay/features/scan_pay/screens/qr_scanner_screen.dart';
import 'package:chain_pay/features/scan_pay/screens/reputation_screen.dart';
import 'package:chain_pay/features/scan_pay/screens/amount_entry_screen.dart';
import 'package:chain_pay/features/scan_pay/screens/confirm_pay_screen.dart';
import 'package:chain_pay/features/receive/screens/receive_screen.dart';
import 'package:chain_pay/features/transactions/screens/history_screen.dart';
import 'package:chain_pay/features/transactions/screens/transaction_detail_screen.dart';
import 'package:chain_pay/features/settings/screens/settings_screen.dart';
import 'package:chain_pay/models/merchant_model.dart';
import 'package:chain_pay/models/transaction_model.dart';

import 'package:chain_pay/features/navigation/screens/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingCarousel(),
      ),
      GoRoute(
        path: '/wallet_setup',
        builder: (context, state) => const WalletSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/receive',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ReceiveScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/scan',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const QrScannerScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(child: HistoryScreen()),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final tx = state.extra as TransactionModel?;
                  if (tx == null) {
                    return const Scaffold(body: Center(child: Text('Error')));
                  }
                  return TransactionDetailScreen(transaction: tx);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Keep nested scan routes separate if they shouldn't show the nav bar
      // But typically, Scan is a full screen anyway. Wait, QrScannerScreen is already in the ShellRoute.
      // If reputation/amount/confirm shouldn't show the bottom nav, they need to be outside the ShellRoute.
      // Let's put them under a separate top-level route or use parentNavigatorKey.
      GoRoute(
        path: '/scan_flow/reputation',
        builder: (context, state) {
          final merchant = state.extra as MerchantModel;
          return ReputationScreen(merchant: merchant);
        },
      ),
      GoRoute(
        path: '/scan_flow/amount',
        builder: (context, state) {
          final merchant = state.extra as MerchantModel;
          return AmountEntryScreen(merchant: merchant);
        },
      ),
      GoRoute(
        path: '/scan_flow/confirm',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ConfirmPayScreen(
            merchant: data['merchant'] as MerchantModel,
            amountUsdc: data['amountUsdc'] as double,
            memo: data['memo'] as String?,
          );
        },
      ),

    ],
  );
});
