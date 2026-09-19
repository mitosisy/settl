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
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/receive',
        builder: (context, state) => const ReceiveScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final tx = state.extra as TransactionModel?;
              if (tx == null) {
                // Fallback, though we shouldn't hit this normally
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
      GoRoute(
        path: '/scan',
        builder: (context, state) => const QrScannerScreen(),
        routes: [
          GoRoute(
            path: 'reputation',
            builder: (context, state) {
              final merchant = state.extra as MerchantModel;
              return ReputationScreen(merchant: merchant);
            },
          ),
          GoRoute(
            path: 'amount',
            builder: (context, state) {
              final merchant = state.extra as MerchantModel;
              return AmountEntryScreen(merchant: merchant);
            },
          ),
          GoRoute(
            path: 'confirm',
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
      ),
    ],
  );
});
