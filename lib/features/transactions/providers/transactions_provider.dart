import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chain_pay/models/transaction_model.dart';
import 'package:chain_pay/features/payment_intent/providers/offline_queue_provider.dart';
import 'package:chain_pay/features/wallet/providers/wallet_provider.dart';

/// Provider to fetch and cache transaction history for the current wallet.
///
/// In a real app, this would query Solscan API or a dedicated indexing backend
/// to get parsed USDC transactions, rather than just raw signatures.
/// For the demo, we return an empty list or mock data if we can't parse it.
final transactionsProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final walletState = ref.watch(walletProvider);
  final address = walletState.address;
  
  if (address == null) return [];
  
  final solanaService = ref.watch(solanaServiceProvider);
  
  try {
    final signatures = await solanaService.getTransactionHistory(address, limit: 30);
    
    // Fetch details for up to 10 transactions in parallel to avoid slow load times
    final txSignatures = signatures.take(10).toList();
    final txDetailsFutures = txSignatures.map((sig) => solanaService.getTransactionDetails(sig['signature'] as String));
    final txDetailsList = await Future.wait(txDetailsFutures);
    
    final List<TransactionModel> txs = [];
    
    for (var i = 0; i < txSignatures.length; i++) {
      final sig = txSignatures[i];
      final tx = txDetailsList[i];
      if (tx == null) continue;
      
      final timestamp = sig['blockTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((sig['blockTime'] as int) * 1000)
          : DateTime.now();
      
      final isErr = sig['err'] != null || (tx['meta'] != null && tx['meta']['err'] != null);
      
      // Parse token balances
      double preBalance = 0.0;
      double postBalance = 0.0;
      
      final preBalances = (tx['meta']?['preTokenBalances'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final postBalances = (tx['meta']?['postTokenBalances'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      
      // Keep track of all changes to identify counterparty
      final changes = <String, double>{};
      
      for (final b in preBalances) {
        if (b['mint'] == '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU') {
          final owner = b['owner'] as String;
          final amount = (b['uiTokenAmount']['uiAmount'] as num).toDouble();
          changes[owner] = -(amount);
          if (owner == address) preBalance = amount;
        }
      }
      
      for (final b in postBalances) {
        if (b['mint'] == '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU') {
          final owner = b['owner'] as String;
          final amount = (b['uiTokenAmount']['uiAmount'] as num).toDouble();
          changes[owner] = (changes[owner] ?? 0.0) + amount;
          if (owner == address) postBalance = amount;
        }
      }
      
      final delta = postBalance - preBalance;
      
      // Skip if it wasn't a USDC transfer involving this wallet
      if (delta.abs() < 0.000001 && !isErr) continue; 
      
      String fromAddress = address;
      String toAddress = address;
      
      if (delta < 0) {
        // We sent it. Find who received it (who has a positive delta)
        fromAddress = address;
        for (final entry in changes.entries) {
          if (entry.value > 0.000001 && entry.key != address) {
            toAddress = entry.key;
            break;
          }
        }
      } else {
        // We received it. Find who sent it (who has a negative delta)
        toAddress = address;
        for (final entry in changes.entries) {
          if (entry.value < -0.000001 && entry.key != address) {
            fromAddress = entry.key;
            break;
          }
        }
      }
      
      // Extract memo if available in logMessages
      String? memo;
      final logs = (tx['meta']?['logMessages'] as List?)?.cast<String>() ?? [];
      for (final log in logs) {
        if (log.contains('Program log: Memo')) {
          final parts = log.split('"');
          if (parts.length >= 3) {
            memo = parts[1];
          }
        }
      }
      
      txs.add(TransactionModel(
        signature: sig['signature'] as String,
        fromAddress: fromAddress,
        toAddress: toAddress,
        amountUsdc: delta.abs() > 0 ? delta.abs() : 0.0, // Failed tx might have 0 delta
        networkFeeSol: ((tx['meta']?['fee'] as num?) ?? 5000).toDouble() / 1e9,
        timestamp: timestamp,
        status: isErr ? TransactionStatus.failed : TransactionStatus.confirmed,
        type: delta < 0 ? TransactionType.sent : TransactionType.received,
        memo: memo,
      ));
    }
    
    return txs;
  } catch (e) {
    return [];
  }
});
