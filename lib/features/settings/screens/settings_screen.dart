import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/features/settings/providers/settings_provider.dart';
import 'package:settl/features/wallet/providers/wallet_provider.dart';
import 'package:settl/core/widgets/gradient_scaffold.dart';
import 'package:settl/core/widgets/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      appBar: AppBar(
        title: Text('Settings', style: context.typography.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Center(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 24,
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 24),
        children: [
          _SectionHeader(title: 'Network'),
          GlassContainer(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              title: Text(
                'Use Solana Devnet', 
                style: context.typography.bodyLarge?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.5)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turn off to use Mainnet (Real money)',
                    style: context.typography.labelSmall?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mainnet feature not yet implemented',
                    style: context.typography.labelSmall?.copyWith(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              value: true, // Force to true (devnet)
              onChanged: null, // Disables the switch
            ),
          ),
          
          const SizedBox(height: 32),
          
          _SectionHeader(title: 'Appearance'),
          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Follow System Theme', style: context.typography.bodyLarge),
                  value: settings.themeMode == ThemeMode.system,
                  onChanged: (val) {
                    if (val) {
                      ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.system);
                    } else {
                      ref.read(settingsProvider.notifier).setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
                    }
                  },
                ),
                Divider(height: 1, color: context.colors.onSurface.withValues(alpha: 0.1)),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Light Mode', 
                    style: context.typography.bodyLarge?.copyWith(
                      color: settings.themeMode == ThemeMode.system ? context.colors.onSurface.withValues(alpha: 0.4) : null,
                    ),
                  ),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: settings.themeMode == ThemeMode.system ? null : (val) {
                    if (val != null) ref.read(settingsProvider.notifier).setThemeMode(val);
                  },
                  activeColor: context.colors.primary,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Dark Mode', 
                    style: context.typography.bodyLarge?.copyWith(
                      color: settings.themeMode == ThemeMode.system ? context.colors.onSurface.withValues(alpha: 0.4) : null,
                    ),
                  ),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: settings.themeMode == ThemeMode.system ? null : (val) {
                    if (val != null) ref.read(settingsProvider.notifier).setThemeMode(val);
                  },
                  activeColor: context.colors.primary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          _SectionHeader(title: 'Wallet'),
          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Reveal Seed Phrase',
                    style: context.typography.bodyLarge,
                  ),
                  trailing: Icon(Icons.security, color: context.colors.onSurface.withValues(alpha: 0.6)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not available in demo mode')),
                    );
                  },
                ),
                Divider(height: 1, color: context.colors.onSurface.withValues(alpha: 0.1)),
                ListTile(
                  title: Text(
                    'Disconnect Wallet',
                    style: context.typography.bodyLarge?.copyWith(color: context.colors.error),
                  ),
                  trailing: Icon(Icons.logout_rounded, color: context.colors.error),
                  onTap: () async {
                    final shouldDisconnect = await showGeneralDialog<bool>(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Dismiss',
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.1)),
                          ),
                          backgroundColor: isDark ? Colors.black : Colors.white,
                          title: Text('Disconnect Wallet?', style: context.typography.titleLarge),
                          content: Text(
                            'Are you sure you want to disconnect? Your secret key will be removed from this device.',
                            style: context.typography.bodyMedium,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel', style: context.typography.labelLarge?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.6))),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Disconnect'),
                            ),
                          ],
                        );
                      },
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

                    if (shouldDisconnect == true) {
                      await ref.read(walletProvider.notifier).removeWallet();
                      if (context.mounted) {
                        context.go('/');
                      }
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
        style: context.typography.labelMedium?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.3),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
