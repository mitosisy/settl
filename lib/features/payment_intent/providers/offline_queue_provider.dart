import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/features/payment_intent/models/payment_intent_model.dart';
import 'package:chain_pay/features/payment_intent/services/intent_broadcaster.dart';
import 'package:chain_pay/services/solana_service.dart';

/// Provider for the [IntentBroadcaster] singleton.
final intentBroadcasterProvider = Provider<IntentBroadcaster>((ref) {
  final solanaService = ref.watch(solanaServiceProvider);
  return IntentBroadcaster(solanaService: solanaService);
});

/// Provider for the [SolanaService] singleton.
final solanaServiceProvider = Provider<SolanaService>((ref) {
  final service = SolanaService();
  ref.onDispose(service.dispose);
  return service;
});

/// StreamProvider that emits the current list of queued payment intents.
///
/// Polls the SQLite database every 2 seconds for queued intents.
/// The home screen uses this to show/hide the offline queue banner.
final offlineQueueProvider =
    StreamProvider<List<PaymentIntentModel>>((ref) async* {
  final broadcaster = ref.watch(intentBroadcasterProvider);

  // Initial emit
  yield await broadcaster.getQueuedIntents();

  // Poll every 2 seconds for changes
  await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
    yield await broadcaster.getQueuedIntents();
  }
});

/// Provider for the count of queued intents (used by the home screen banner).
final queuedIntentCountProvider = Provider<int>((ref) {
  final queueAsync = ref.watch(offlineQueueProvider);
  return queueAsync.value?.length ?? 0;
});
