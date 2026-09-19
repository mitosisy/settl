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
    
    // Convert to mock TransactionModels for the demo since parsing raw 
    // solana devnet transactions for token transfers is complex.
    // In production, use Helius or Solscan APIs for this.
    final List<TransactionModel> txs = [];
    
    for (var i = 0; i < signatures.length; i++) {
      final sig = signatures[i];
      final timestamp = sig['blockTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((sig['blockTime'] as int) * 1000)
          : DateTime.now();
      
      final isErr = sig['err'] != null;
      
      // Generate some mock details based on the signature index
      txs.add(TransactionModel(
        signature: sig['signature'] as String,
        fromAddress: i % 2 == 0 ? address : 'Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr',
        toAddress: i % 2 == 0 ? 'Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr' : address,
        amountUsdc: 10.0 + (i * 2.5),
        networkFeeSol: 0.000005,
        timestamp: timestamp,
        status: isErr ? TransactionStatus.failed : TransactionStatus.confirmed,
        type: i % 2 == 0 ? TransactionType.sent : TransactionType.received,
        memo: i % 3 == 0 ? 'Payment' : null,
      ));
    }
    
    return txs;
  } catch (e) {
    return [];
  }
});
