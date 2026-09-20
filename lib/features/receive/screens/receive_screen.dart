import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/wallet/providers/wallet_provider.dart';
import 'package:chain_pay/features/receive/widgets/my_qr_card.dart';
import 'package:chain_pay/services/qr_service.dart';
import 'package:chain_pay/core/widgets/gradient_scaffold.dart';

class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  final QrService _qrService = QrService();
  double? _requestedAmount;

  void _showAmountDialog() {
    final controller = TextEditingController(
      text: _requestedAmount?.toString() ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.1)),
        ),
        backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
        title: Text('Request Amount', style: context.typography.titleLarge),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: context.typography.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter USDC amount',
            prefixText: '\$ ',
            prefixStyle: context.typography.bodyLarge?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.08)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _requestedAmount = null);
              Navigator.pop(context);
            },
            child: Text('Clear', style: TextStyle(color: context.colors.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() => _requestedAmount = val);
              }
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final address = wallet.address ?? '';
    
    final qrData = _qrService.encodePaymentQR(
      address,
      amount: _requestedAmount,
    );

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          Strings.receivePayment,
          style: context.typography.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // QR Card
              Center(
                child: MyQrCard(qrData: qrData)
                    .animate()
                    .fadeIn(duration: 100.ms)
                    .scaleXY(begin: 0.8, end: 1.0, duration: 100.ms, curve: Curves.easeOut)
                    .then(delay: 50.ms)
                    .scaleXY(begin: 1.0, end: 1.04, duration: 100.ms, curve: Curves.easeOut)
                    .then()
                    .scaleXY(begin: 1.04, end: 1.0, duration: 100.ms, curve: Curves.easeIn),
              ),
              
              const SizedBox(height: 32),
              
              // Warning text
              Text(
                'Only send USDC (Solana Devnet) to this address.',
                style: context.typography.labelMedium?.copyWith(
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Request Amount Button
              OutlinedButton.icon(
                onPressed: _showAmountDialog,
                icon: const Icon(Icons.edit_rounded),
                label: Text(
                  _requestedAmount != null 
                      ? 'Requesting \$${_requestedAmount!.toStringAsFixed(2)}' 
                      : Strings.requestAmount,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.08)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Actions (Share & Copy)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(Strings.addressCopied)),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text(Strings.copyAddress),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.08)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Share.share(
                          'Pay me via ChainPay (Solana): $qrData',
                          subject: 'ChainPay Payment Request',
                        );
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: const Text(Strings.shareQr),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 120),
            ],
          ),
        ),
    );
  }
}
