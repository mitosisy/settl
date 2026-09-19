import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:chain_pay/core/constants/app_constants.dart';
import 'package:chain_pay/core/errors/app_exception.dart';

/// Low-level Solana Devnet JSON-RPC client.
///
/// Wraps Dio for all RPC calls with retry logic, timeouts,
/// and structured error handling.
class SolanaService {
  SolanaService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.solanaRpcUrl,
                connectTimeout:
                    const Duration(milliseconds: AppConstants.networkTimeoutMs),
                receiveTimeout:
                    const Duration(milliseconds: AppConstants.networkTimeoutMs),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  final Dio _dio;

  // ─── RPC call helper ───────────────────────────────────────────

  /// Sends a JSON-RPC request with automatic retries and exponential backoff.
  Future<dynamic> _rpcCall(String method, [List<dynamic>? params]) async {
    final body = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': method,
      'params': params ?? [],
    };

    for (var attempt = 0; attempt <= AppConstants.maxRetries; attempt++) {
      try {
        final response = await _dio.post<Map<String, dynamic>>('', data: body);
        final data = response.data!;

        if (data.containsKey('error')) {
          final error = data['error'] as Map<String, dynamic>;
          throw RpcException(
            error['message'] as String? ?? 'Unknown RPC error',
            code: error['code'] as int?,
          );
        }

        return data['result'];
      } on DioException catch (e) {
        if (attempt == AppConstants.maxRetries) {
          throw NetworkException(
            'Network request failed after ${AppConstants.maxRetries} retries',
            cause: e,
          );
        }
        // Exponential backoff
        final delay = AppConstants.retryBaseDelayMs * pow(2, attempt);
        await Future<void>.delayed(Duration(milliseconds: delay.toInt()));
      }
    }

    throw const NetworkException('Unexpected retry exhaustion');
  }

  // ─── Public API ────────────────────────────────────────────────

  /// Returns the native SOL balance for [address] in SOL.
  Future<double> getSolBalance(String address) async {
    final result = await _rpcCall('getBalance', [address]);
    final lamports = result['value'] as int;
    return lamports / 1e9; // lamports → SOL
  }

  /// Returns the USDC SPL token balance for [address].
  ///
  /// Queries the token accounts owned by [address] for the USDC mint.
  Future<double> getUsdcBalance(String address) async {
    final result = await _rpcCall('getTokenAccountsByOwner', [
      address,
      {'mint': AppConstants.usdcMintAddress},
      {'encoding': 'jsonParsed'},
    ]);

    final accounts = result['value'] as List;
    if (accounts.isEmpty) return 0.0;

    final tokenData = accounts[0]['account']['data']['parsed']['info']
        ['tokenAmount'] as Map<String, dynamic>;
    final uiAmount = tokenData['uiAmount'];
    return (uiAmount as num?)?.toDouble() ?? 0.0;
  }

  /// Fetches the most recent blockhash from the network.
  ///
  /// Used for transaction signing. The blockhash is valid for ~60-90 seconds.
  Future<String> getRecentBlockhash() async {
    final result = await _rpcCall('getLatestBlockhash');
    return result['value']['blockhash'] as String;
  }

  /// Fetches transaction signatures for [address].
  ///
  /// Returns up to [limit] most recent signatures.
  Future<List<Map<String, dynamic>>> getTransactionHistory(
    String address, {
    int limit = AppConstants.defaultTxnHistoryLimit,
  }) async {
    final result = await _rpcCall('getSignaturesForAddress', [
      address,
      {'limit': limit},
    ]);
    return (result as List).cast<Map<String, dynamic>>();
  }

  /// Sends a signed transaction to the network.
  ///
  /// [signedTxBase64] is the base64-encoded signed transaction.
  /// Returns the transaction signature on success.
  Future<String> sendTransaction(String signedTxBase64) async {
    final result = await _rpcCall('sendTransaction', [
      signedTxBase64,
      {'encoding': 'base64'},
    ]);
    return result as String;
  }

  /// Fetches account info for [address].
  ///
  /// Used to check if an account exists and get account data.
  Future<Map<String, dynamic>?> getAccountInfo(String address) async {
    final result = await _rpcCall('getAccountInfo', [
      address,
      {'encoding': 'jsonParsed'},
    ]);
    return result['value'] as Map<String, dynamic>?;
  }

  /// Sends a raw signed transaction (bytes) to the network.
  ///
  /// Encodes the bytes to base64 and calls [sendTransaction].
  Future<String> sendRawTransaction(List<int> signedTxBytes) async {
    final base64Tx = base64Encode(signedTxBytes);
    return sendTransaction(base64Tx);
  }

  /// Requests an airdrop of SOL to [address] on devnet.
  ///
  /// [amountSol] is the amount in SOL (max 2 per request on devnet).
  Future<String> requestAirdrop(String address,
      {double amountSol = 1.0}) async {
    final lamports = (amountSol * 1e9).toInt();
    final result = await _rpcCall('requestAirdrop', [address, lamports]);
    return result as String;
  }

  /// Disposes of the Dio client.
  void dispose() {
    _dio.close();
  }
}
