import 'package:chain_pay/services/solana_service.dart';

void main() async {
  final solanaService = SolanaService();
  try {
    // Get signatures for Faucet
    final signatures = await solanaService.getTransactionHistory('D67ReZBtmq4AxyDXt1iRzWbKL8XMmvLw1LdGvvLZKdRh', limit: 2);
    for (var sig in signatures) {
      final tx = await solanaService.getTransactionDetails(sig['signature'] as String);
      print('Tx ${sig['signature']}:');
      final meta = tx?['meta'];
      if (meta != null) {
        print('Pre Token Balances: ${meta['preTokenBalances']}');
        print('Post Token Balances: ${meta['postTokenBalances']}');
      }
    }
  } catch (e) {
    print(e);
  } finally {
    solanaService.dispose();
  }
}
