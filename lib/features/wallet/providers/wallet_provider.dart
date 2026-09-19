import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import 'package:chain_pay/core/constants/app_constants.dart';
import 'package:chain_pay/features/payment_intent/providers/offline_queue_provider.dart';
import 'package:chain_pay/models/wallet_model.dart';

/// State representing the user's wallet.
class WalletState {
  const WalletState({
    this.wallet,
    this.usdcBalance = 0.0,
    this.solBalance = 0.0,
    this.isLoading = false,
    this.error,
  });

  final WalletModel? wallet;
  final double usdcBalance;
  final double solBalance;
  final bool isLoading;
  final String? error;

  bool get hasWallet => wallet != null;
  String? get address => wallet?.publicKey;

  WalletState copyWith({
    WalletModel? wallet,
    double? usdcBalance,
    double? solBalance,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      usdcBalance: usdcBalance ?? this.usdcBalance,
      solBalance: solBalance ?? this.solBalance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Manages wallet lifecycle: creation, loading, balance refresh.
class WalletNotifier extends Notifier<WalletState> {
  final _secureStorage = const FlutterSecureStorage();

  @override
  WalletState build() => const WalletState();

  /// Checks if a wallet already exists in local storage.
  Future<bool> hasExistingWallet() async {
    try {
      final box = Hive.box<String>(AppConstants.walletBoxName);
      final walletJson = box.get('wallet');
      return walletJson != null;
    } catch (_) {
      return false;
    }
  }

  /// Loads the wallet from local storage.
  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true);

    try {
      final box = Hive.box<String>(AppConstants.walletBoxName);
      final walletJson = box.get('wallet');

      if (walletJson != null) {
        final wallet = WalletModel.fromJson(
          jsonDecode(walletJson) as Map<String, dynamic>,
        );
        state = state.copyWith(wallet: wallet, isLoading: false);
        await refreshBalances();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load wallet',
      );
    }
  }

  /// Creates a new wallet from a mnemonic phrase.
  ///
  /// Stores the private key in secure storage and the public key in Hive.
  Future<void> createWallet({
    required String publicKey,
    required String privateKey,
    required String mnemonic,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      // Store private key securely
      await _secureStorage.write(
        key: AppConstants.privateKeyStorageKey,
        value: privateKey,
      );
      await _secureStorage.write(
        key: AppConstants.mnemonicStorageKey,
        value: mnemonic,
      );

      // Store wallet model in Hive
      final wallet = WalletModel(
        publicKey: publicKey,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      final box = Hive.box<String>(AppConstants.walletBoxName);
      await box.put('wallet', jsonEncode(wallet.toJson()));

      state = state.copyWith(wallet: wallet, isLoading: false);
      await refreshBalances();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create wallet',
      );
    }
  }

  /// Refreshes USDC and SOL balances from the network.
  Future<void> refreshBalances() async {
    final address = state.address;
    if (address == null) return;

    try {
      final solanaService = ref.read(solanaServiceProvider);
      final results = await Future.wait([
        solanaService.getUsdcBalance(address),
        solanaService.getSolBalance(address),
      ]);

      state = state.copyWith(
        usdcBalance: results[0],
        solBalance: results[1],
        error: null,
      );
    } catch (e) {
      // Silently fail — balances will show last known values
    }
  }

  /// Updates the display name.
  Future<void> updateDisplayName(String name) async {
    final wallet = state.wallet;
    if (wallet == null) return;

    final updated = wallet.copyWith(displayName: name);
    final box = Hive.box<String>(AppConstants.walletBoxName);
    await box.put('wallet', jsonEncode(updated.toJson()));
    state = state.copyWith(wallet: updated);
  }
}

/// The wallet provider — central state for the user's wallet.
final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
