// ignore_for_file: avoid_print
import 'package:solana/solana.dart'; void main() async { try { final kp = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: List.filled(32, 0)); print(kp.address); } catch(e) { print(e); } }
