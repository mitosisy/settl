import 'dart:io';

void main() async {
  final path = r'C:\Users\ashish\AppData\Local\Pub\Cache\hosted\pub.dev\solana-0.31.2+1\lib\src\crypto\ed25519_hd_keypair.dart';
  final content = File(path).readAsStringSync();
  print(content);
}
