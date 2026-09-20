import 'package:solana/solana.dart';
import 'package:solana/encoder.dart';

void main() async {
  final senderPubkey = Ed25519HDPublicKey.fromBase58('D67ReZBtmq4AxyDXt1iRzWbKL8XMmvLw1LdGvvLZKdRh');
  final recipientPubkey = Ed25519HDPublicKey.fromBase58('Kq5vWMGmH1T2wXUfHb7soHuXz23A8FZgpye27vpcaFA');
  final mintPubkey = Ed25519HDPublicKey.fromBase58('4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU');
  
  final senderAta = await findAssociatedTokenAddress(owner: senderPubkey, mint: mintPubkey);
  final recipientAta = await findAssociatedTokenAddress(owner: recipientPubkey, mint: mintPubkey);
  
  final instructions = <Instruction>[];
  
  instructions.add(
    AssociatedTokenAccountInstruction.createAccount(
      funder: senderPubkey,
      address: Ed25519HDPublicKey.fromBase58(recipientAta.toBase58()),
      owner: recipientPubkey,
      mint: mintPubkey,
    ),
  );
  
  instructions.add(
    TokenInstruction.transfer(
      amount: 1000000,
      source: Ed25519HDPublicKey.fromBase58(senderAta.toBase58()),
      destination: Ed25519HDPublicKey.fromBase58(recipientAta.toBase58()),
      owner: senderPubkey,
    ),
  );
  
  final message = Message(instructions: instructions);
  final compiled = message.compile(recentBlockhash: '4VszgXzG2Dxy15mU24J7FqA8qH8xR8Bv12a', feePayer: senderPubkey);
  
  print('Compiled successfully!');
  for (var k in compiled.accountKeys) {
    print('Key: ${k.toBase58()}');
  }
}
