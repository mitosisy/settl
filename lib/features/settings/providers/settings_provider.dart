import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:chain_pay/core/constants/app_constants.dart';

/// App settings like dark mode, devnet vs mainnet, etc.
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.isDevnet = true,
  });

  final ThemeMode themeMode;
  final bool isDevnet;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? isDevnet,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isDevnet: isDevnet ?? this.isDevnet,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  void _loadSettings() {
    try {
      final box = Hive.box<String>(AppConstants.walletBoxName);
      final isDevnetStr = box.get('isDevnet');
      final themeStr = box.get('themeMode');
      
      final isDevnet = isDevnetStr != 'false';
      ThemeMode mode = ThemeMode.system;
      
      if (themeStr == 'light') mode = ThemeMode.light;
      if (themeStr == 'dark') mode = ThemeMode.dark;
      
      state = SettingsState(themeMode: mode, isDevnet: isDevnet);
    } catch (_) {
      // Use defaults
    }
  }

  Future<void> toggleThemeMode() async {
    final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(themeMode: newMode);
    
    final box = Hive.box<String>(AppConstants.walletBoxName);
    await box.put('themeMode', newMode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setNetwork(bool isDevnet) async {
    state = state.copyWith(isDevnet: isDevnet);
    
    final box = Hive.box<String>(AppConstants.walletBoxName);
    await box.put('isDevnet', isDevnet.toString());
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
