import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/payment_intent/providers/offline_queue_provider.dart';
import 'package:chain_pay/features/wallet/providers/wallet_provider.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:solana/solana.dart';

class WalletSetupScreen extends ConsumerStatefulWidget {
  const WalletSetupScreen({super.key});

  @override
  ConsumerState<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends ConsumerState<WalletSetupScreen> {
  bool _isLoading = false;

  Future<void> _createNewWallet() async {
    setState(() => _isLoading = true);

    try {
      final mnemonic = bip39.generateMnemonic();
      final keypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      final extracted = await keypair.extract();
      final privateKeyHex = extracted.bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
      final publicKey = keypair.address;

      if (mounted) {
        setState(() => _isLoading = false);
        // Show seed phrase dialog
        final proceed = await _showSeedPhraseDialog(context, mnemonic);
        if (proceed == true) {
          setState(() => _isLoading = true);
          await ref.read(walletProvider.notifier).createWallet(
            publicKey: publicKey,
            privateKey: privateKeyHex,
            mnemonic: mnemonic,
            displayName: 'My Wallet',
          );
          
          if (mounted) {
            await _requestAirdrop(publicKey);
            context.go('/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Strings.genericError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestAirdrop(String address) async {
    try {
      final solanaService = ref.read(solanaServiceProvider);
      await solanaService.requestAirdrop(address, amountSol: 1.0);
    } catch (_) {
      // Ignore airdrop failures for now
    }
  }

  Future<void> _importWallet() async {
    final mnemonic = await _showImportDialog(context);
    if (mnemonic != null && mnemonic.trim().isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final phrase = mnemonic.trim();
        final keypair = await Ed25519HDKeyPair.fromMnemonic(phrase);
        final extracted = await keypair.extract();
        final privateKeyHex = extracted.bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
        final publicKey = keypair.address;

        await ref.read(walletProvider.notifier).createWallet(
          publicKey: publicKey,
          privateKey: privateKeyHex,
          mnemonic: phrase,
          displayName: 'Imported Wallet',
        );

        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid seed phrase')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<String?> _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text('Import Wallet', style: AppTypography.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your 12-word seed phrase separated by spaces.', 
                 style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              style: AppTypography.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'apple banana cherry...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showSeedPhraseDialog(BuildContext context, String mnemonic) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text('Secret Recovery Phrase', style: AppTypography.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Write down these 12 words and keep them safe. Anyone with these words can access your funds.', 
                 style: AppTypography.bodyMedium.copyWith(color: AppColors.brandRed)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textMuted),
              ),
              child: Text(mnemonic, style: AppTypography.bodyLarge.copyWith(height: 1.5)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('I have saved these words'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 64,
                    color: AppColors.brandSaffron,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                'Wallet Setup',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Create a new wallet or import an existing one to get started.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

              const Spacer(flex: 2),

              // Create Wallet Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createNewWallet,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.bgDeep,
                        ),
                      )
                    : const Text(Strings.createNewWallet),
              ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 600.ms).fadeIn(delay: 600.ms),

              const SizedBox(height: 16),

              // Import Wallet Button
              OutlinedButton(
                onPressed: _isLoading ? null : _importWallet,
                child: const Text(Strings.importWallet),
              ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 800.ms).fadeIn(delay: 800.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
