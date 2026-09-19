import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/features/settings/providers/settings_provider.dart';
import 'package:chain_pay/features/wallet/providers/wallet_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionHeader(title: 'Network'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              title: Text('Use Solana Devnet', style: AppTypography.bodyLarge),
              subtitle: Text(
                'Turn off to use Mainnet (Demo only)',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              value: settings.isDevnet,
              onChanged: (val) {
                ref.read(settingsProvider.notifier).setNetwork(val);
              },
              activeThumbColor: AppColors.brandSaffron,
            ),
          ),
          
          const SizedBox(height: 32),
          
          _SectionHeader(title: 'Appearance'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text('Dark Mode', style: AppTypography.bodyLarge),
              trailing: Switch(
                value: settings.themeMode == ThemeMode.dark || 
                       (settings.themeMode == ThemeMode.system && isDark),
                onChanged: (_) {
                  ref.read(settingsProvider.notifier).toggleThemeMode();
                },
                activeThumbColor: AppColors.brandSaffron,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          _SectionHeader(title: 'Wallet'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Reveal Seed Phrase',
                    style: AppTypography.bodyLarge,
                  ),
                  trailing: const Icon(Icons.security, color: AppColors.textSecondary),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not available in demo mode')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    'Disconnect Wallet',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.brandRed),
                  ),
                  trailing: const Icon(Icons.logout_rounded, color: AppColors.brandRed),
                  onTap: () async {
                    await ref.read(walletProvider.notifier).removeWallet();
                    if (context.mounted) {
                      context.go('/');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
