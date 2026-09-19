import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/wallet/providers/wallet_provider.dart';
import 'package:chain_pay/features/receive/widgets/my_qr_card.dart';
import 'package:chain_pay/services/qr_service.dart';

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
        backgroundColor: AppColors.bgElevated,
        title: Text('Request Amount', style: AppTypography.titleLarge),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter USDC amount',
            prefixText: '\$ ',
            prefixStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _requestedAmount = null);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
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

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text(Strings.receivePayment),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // QR Card
              Center(
                child: MyQrCard(qrData: qrData)
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.easeOutBack)
                    .fadeIn(),
              ),
              
              const SizedBox(height: 32),
              
              // Warning text
              Text(
                'Only send USDC (Solana Devnet) to this address.',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.brandAmber,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              
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
              ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 400.ms).fadeIn(delay: 400.ms),
              
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
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 600.ms).fadeIn(delay: 600.ms),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
