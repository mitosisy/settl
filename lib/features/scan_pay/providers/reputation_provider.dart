import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:settl/models/reputation_model.dart';
import 'package:settl/services/reputation_service.dart';
import 'package:settl/features/payment_intent/providers/offline_queue_provider.dart';

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
