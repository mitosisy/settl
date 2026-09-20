import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solana/solana.dart';
import 'package:solana/encoder.dart';

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

      // Read private key to reconstruct keypair
      final privateKeyHex = await const FlutterSecureStorage().read(key: AppConstants.privateKeyStorageKey);
      if (privateKeyHex == null) {
        throw const TransactionException('Wallet not found. Please log in again.');
      }
      
      // Convert hex string back to byte array
      final List<int> privateKeyBytes = [];
      for (var i = 0; i < privateKeyHex.length; i += 2) {
        privateKeyBytes.add(int.parse(privateKeyHex.substring(i, i + 2), radix: 16));
      }
      
      final senderKeypair = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: privateKeyBytes);
      
      final senderPubkey = Ed25519HDPublicKey(senderKeypair.publicKey.bytes);
      final recipientPubkey = Ed25519HDPublicKey.fromBase58(recipientAddress);
      final mintPubkey = Ed25519HDPublicKey.fromBase58(AppConstants.usdcMintAddress);
      
      final senderAta = await findAssociatedTokenAddress(
        owner: senderPubkey,
        mint: mintPubkey,
      );
      final recipientAta = await findAssociatedTokenAddress(
        owner: recipientPubkey,
        mint: mintPubkey,
      );
      
      final instructions = <Instruction>[];
      
      // If we are online, check if recipient ATA exists, if not, create it
      if (isOnline) {
        final recipientAtaInfo = await solanaService.getAccountInfo(recipientAta.toBase58());
        if (recipientAtaInfo == null) {
          instructions.add(
            AssociatedTokenAccountInstruction.createAccount(
              funder: senderPubkey,
              address: Ed25519HDPublicKey.fromBase58(recipientAta.toBase58()),
              owner: recipientPubkey,
              mint: mintPubkey,
            ),
          );
        }
      } else {
        // Offline: we must assume the recipient ATA exists, or always try to create it?
        // Creating an existing ATA throws an error on-chain, but we can't check offline.
        // For hackathon, if offline, we assume ATA exists. 
      }
      
      // Add memo if present
      if (memo != null && memo.isNotEmpty) {
        instructions.add(MemoInstruction(signers: [senderPubkey], memo: memo));
      }
      
      // Add transfer instruction
      instructions.add(
        TokenInstruction.transfer(
          amount: (amountUsdc * 1e6).toInt(),
          source: Ed25519HDPublicKey.fromBase58(senderAta.toBase58()),
          destination: Ed25519HDPublicKey.fromBase58(recipientAta.toBase58()),
          owner: senderPubkey,
        ),
      );

      final message = Message(instructions: instructions);
      
      final signedTx = await senderKeypair.signMessage(
        message: message,
        recentBlockhash: blockhash,
      );
      
      final signedBytes = Uint8List.fromList(signedTx.toByteArray().toList());

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
