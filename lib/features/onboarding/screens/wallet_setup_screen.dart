import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/core/constants/strings.dart';
import 'package:settl/features/payment_intent/providers/offline_queue_provider.dart';
import 'package:settl/features/wallet/providers/wallet_provider.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:solana/solana.dart';
import 'package:settl/core/widgets/gradient_scaffold.dart';

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
            if (mounted) {
              context.go('/home');
            }
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
    final result = await _showImportDialog(context);
    if (result != null) {
      final phraseOrKey = result.$1;
      final useRawSeed = result.$2;

      if (phraseOrKey.isEmpty) return;
      setState(() => _isLoading = true);
      try {
        String publicKey;
        String privateKeyHex;
        String storedMnemonic = '';

        String cleanedKey = phraseOrKey.trim();
        bool isJsonArray = cleanedKey.startsWith('[') && cleanedKey.endsWith(']');
        bool isCommaSeparatedNumbers = RegExp(r'^\d+(\s*,\s*\d+)+$').hasMatch(cleanedKey);

        if (isJsonArray || isCommaSeparatedNumbers) {
          // Solana CLI format (JSON array of 64 bytes)
          if (!isJsonArray) {
            cleanedKey = '[$cleanedKey]';
          }
          final List<dynamic> jsonList = jsonDecode(cleanedKey);
          final List<int> bytes = jsonList.cast<int>();
          // Ed25519HDKeyPair.fromPrivateKeyBytes expects exactly 32 bytes for the private key
          final keypair = await Ed25519HDKeyPair.fromPrivateKeyBytes(
            privateKey: bytes.sublist(0, 32),
          );
          final extracted = await keypair.extract();
          privateKeyHex = extracted.bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
          publicKey = keypair.address;
          storedMnemonic = 'Imported via Private Key';
        } else {
          // Mnemonic phrase
          Ed25519HDKeyPair keypair;
          if (useRawSeed) {
            final seed = bip39.mnemonicToSeed(phraseOrKey);
            keypair = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: seed.sublist(0, 32));
          } else {
            keypair = await Ed25519HDKeyPair.fromMnemonic(phraseOrKey);
          }
          final extracted = await keypair.extract();
          privateKeyHex = extracted.bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
          publicKey = keypair.address;
          storedMnemonic = phraseOrKey;
        }

        await ref.read(walletProvider.notifier).createWallet(
          publicKey: publicKey,
          privateKey: privateKeyHex,
          mnemonic: storedMnemonic,
          displayName: 'Imported Wallet',
        );

        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid seed phrase or private key format')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<(String, bool)?> _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    bool useRawSeed = false;

    return showGeneralDialog<(String, bool)>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.1)),
            ),
            backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
            title: Text('Import Wallet', style: context.typography.headlineMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter your 12-word seed phrase or a Solana CLI private key array (e.g. [12, 34...]).', 
                     style: context.typography.bodyMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  style: context.typography.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'apple banana cherry... OR [1, 2, 3...]',
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: useRawSeed,
                  onChanged: (val) {
                    setState(() => useRawSeed = val ?? false);
                  },
                  title: Text('Use Solana CLI Derivation (Raw Seed)', style: context.typography.bodySmall),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: context.typography.labelLarge?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.6))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop((controller.text.trim(), useRawSeed)),
                child: const Text('Import'),
              ),
            ],
          );
        }
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Future<bool?> _showSeedPhraseDialog(BuildContext context, String mnemonic) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.1)),
        ),
        backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
        title: Text('Secret Recovery Phrase', style: context.typography.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Write down these 12 words and keep them safe. Anyone with these words can access your funds.', 
                 style: context.typography.bodyMedium?.copyWith(color: context.colors.error)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.onSurface.withValues(alpha: 0.3)),
              ),
              child: Text(mnemonic, style: context.typography.bodyLarge?.copyWith(height: 1.5)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: context.typography.labelLarge?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('I have saved these words'),
          ),
        ],
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 64,
                    color: context.isDarkMode ? Colors.black : Colors.white,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                'Wallet Setup',
                style: context.typography.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Create a new wallet or import an existing one to get started.',
                style: context.typography.bodyLarge?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

              const Spacer(flex: 2),

              // Create Wallet Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: _isLoading ? null : _createNewWallet,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(Strings.createNewWallet),
              ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 600.ms).fadeIn(delay: 600.ms),

              const SizedBox(height: 16),

              // Import Wallet Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.08)),
                ),
                onPressed: _isLoading ? null : _importWallet,
                child: const Text(Strings.importWallet),
              ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 800.ms).fadeIn(delay: 800.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
    );
  }
}
