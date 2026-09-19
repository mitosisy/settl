import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/models/reputation_model.dart';
import 'package:chain_pay/services/reputation_service.dart';
import 'package:chain_pay/features/payment_intent/providers/offline_queue_provider.dart';

// Provide the ReputationService
final reputationServiceProvider = Provider<ReputationService>((ref) {
  final solanaService = ref.watch(solanaServiceProvider);
  return ReputationService(solanaService: solanaService);
});

/// Fetches the reputation score for a given merchant wallet address.
final merchantReputationProvider =
    FutureProvider.family<ReputationModel, String>((ref, walletAddress) async {
  final reputationService = ref.watch(reputationServiceProvider);
  return await reputationService.getReputation(walletAddress);
});
