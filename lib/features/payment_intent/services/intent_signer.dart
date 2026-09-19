import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

import 'package:chain_pay/core/constants/app_constants.dart';
import 'package:chain_pay/core/errors/app_exception.dart';
import 'package:chain_pay/features/payment_intent/models/payment_intent_model.dart';
import 'package:chain_pay/services/solana_service.dart';

/// Signs payment transactions locally and stores them in the offline queue.
///
/// Supports both online signing (fresh blockhash) and offline signing
/// (cached blockhash with ~60-90s validity window).
class IntentSigner {
  IntentSigner({required this.solanaService});

  final SolanaService solanaService;
  final _uuid = const Uuid();

  /// Last fetched blockhash — cached for offline signing.
  String? _cachedBlockhash;
  DateTime? _blockhashFetchedAt;

  /// Signs a payment intent and returns a [PaymentIntentModel].
  ///
  /// If online, fetches a fresh blockhash. If offline, uses the cached
  /// blockhash (valid for ~60-90 seconds).
  ///
  /// The signed transaction bytes are ready to broadcast when connectivity
  /// is available.
  Future<PaymentIntentModel> signIntent({
    required String recipientAddress,
    required double amountUsdc,
    String? memo,
    String? recipientName,
    required bool isOnline,
  }) async {
    try {
      // Get blockhash
      String blockhash;
      if (isOnline) {
        blockhash = await solanaService.getRecentBlockhash();
        _cachedBlockhash = blockhash;
        _blockhashFetchedAt = DateTime.now();
      } else {
        if (_cachedBlockhash == null) {
          throw const TransactionException(
            'No cached blockhash available. Connect to the network first.',
          );
        }
        blockhash = _cachedBlockhash!;
      }

      // For hackathon demo: create a mock signed transaction
      // In production, this would use the solana package to build
      // and sign a real SPL token transfer instruction
      final mockTxPayload = {
        'blockhash': blockhash,
        'recipient': recipientAddress,
        'amount': amountUsdc,
        'memo': memo,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final signedBytes =
          Uint8List.fromList(utf8.encode(jsonEncode(mockTxPayload)));

      return PaymentIntentModel(
        id: _uuid.v4(),
        recipientAddress: recipientAddress,
        amountUsdc: amountUsdc,
        memo: memo,
        signedTransactionBytes: signedBytes,
        createdAt: DateTime.now(),
        status: IntentStatus.queued,
        recipientName: recipientName,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw TransactionException('Failed to sign payment intent', cause: e);
    }
  }

  /// Refreshes the cached blockhash (call when connectivity is available).
  Future<void> refreshBlockhash() async {
    _cachedBlockhash = await solanaService.getRecentBlockhash();
    _blockhashFetchedAt = DateTime.now();
  }

  /// Whether the cached blockhash is still likely valid.
  bool get isBlockhashValid {
    if (_cachedBlockhash == null || _blockhashFetchedAt == null) return false;
    final elapsed = DateTime.now().difference(_blockhashFetchedAt!);
    return elapsed.inSeconds < AppConstants.blockhashValiditySec;
  }
}
