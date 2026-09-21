import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:settl/core/theme/app_theme.dart';
import 'package:settl/core/constants/app_constants.dart';
import 'package:settl/core/constants/strings.dart';
import 'package:settl/core/router/app_router.dart';
import 'package:settl/features/settings/providers/settings_provider.dart';

import 'package:settl/services/solana_service.dart';
import 'package:settl/features/payment_intent/services/intent_broadcaster.dart';
import 'package:settl/features/payment_intent/providers/offline_queue_provider.dart';
import 'package:settl/services/identity_service.dart';
import 'package:settl/features/identity/providers/identity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Enable edge-to-edge system UI for Android 14+
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open necessary boxes
  await Hive.openBox<String>(AppConstants.walletBoxName);

  // Initialize Core Services
  final solanaService = SolanaService();
  final intentBroadcaster = IntentBroadcaster(solanaService: solanaService);
  await intentBroadcaster.init();
  intentBroadcaster.startListening();

  final identityService = IdentityService();
  await identityService.loadDirectory();

  runApp(
    ProviderScope(
      overrides: [
        solanaServiceProvider.overrideWithValue(solanaService),
        intentBroadcasterProvider.overrideWithValue(intentBroadcaster),
        identityServiceProvider.overrideWithValue(identityService),
      ],
      child: const SettlApp(),
    ),
  );
}

class SettlApp extends ConsumerWidget {
  const SettlApp({super.key});

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
