import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:chain_pay/core/theme/app_theme.dart';
import 'package:chain_pay/core/constants/app_constants.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/core/router/app_router.dart';
import 'package:chain_pay/features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open necessary boxes
  await Hive.openBox<String>(AppConstants.walletBoxName);

  runApp(
    const ProviderScope(
      child: ChainPayApp(),
    ),
  );
}

class ChainPayApp extends ConsumerWidget {
  const ChainPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: Strings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
