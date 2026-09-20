import 'package:chain_pay/services/solana_service.dart';

void main() async {
  final service = SolanaService();
  try {
    print('Faucet USDC: ${await service.getUsdcBalance('D67ReZBtmq4AxyDXt1iRzWbKL8XMmvLw1LdGvvLZKdRh')}');
    print('TrustCafe USDC: ${await service.getUsdcBalance('Kq5vWMGmH1T2wXUfHb7soHuXz23A8FZgpye27vpcaFA')}');
    print('QuickMart USDC: ${await service.getUsdcBalance('9VWg7mWaZqgNrsZE6VZ6jEUjrNkHWWWw9eZZJMEzvFEs')}');
  } catch (e) {
    print(e);
  } finally {
    service.dispose();
  }
}
