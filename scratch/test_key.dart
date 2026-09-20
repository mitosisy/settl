import 'package:solana/solana.dart';
import 'package:bip39/bip39.dart' as bip39;

void main() async {
  final mnemonic = "test test test test test test test test test test test junk"; 
  
  final k1 = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
  print('HD: ' + k1.address);
  
  final seed = bip39.mnemonicToSeed(mnemonic);
  final k2 = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: seed.sublist(0, 32));
  print('Raw: ' + k2.address);
}
