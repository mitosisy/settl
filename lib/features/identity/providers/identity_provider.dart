import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chain_pay/services/identity_service.dart';

final identityServiceProvider = Provider<IdentityService>((ref) {
  return IdentityService();
});

/// A future provider that initializes the directory JSON.
final identityInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(identityServiceProvider);
  await service.loadDirectory();
});
