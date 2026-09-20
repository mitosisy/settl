import 'package:chain_pay/services/solana_service.dart';

void main() async {
  final service = SolanaService();
  try {
    final history = await service.getTransactionHistory('D67ReZBtmq4AxyDXt1iRzWbKL8XMmvLw1LdGvvLZKdRh');
    for (var tx in history.take(5)) {
      print(tx);
    }
  } catch (e) {
    print(e);
  } finally {
    service.dispose();
  }
}
