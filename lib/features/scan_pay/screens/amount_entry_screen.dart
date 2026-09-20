import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/core/utils/validators.dart';
import 'package:chain_pay/features/scan_pay/widgets/merchant_card.dart';
import 'package:chain_pay/models/merchant_model.dart';
import 'package:chain_pay/core/widgets/gradient_scaffold.dart';

class AmountEntryScreen extends StatefulWidget {
  const AmountEntryScreen({super.key, required this.merchant});

  final MerchantModel merchant;

  @override
  State<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends State<AmountEntryScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _isValid = Validators.isValidAmount(_amountController.text);
    });
  }

  void _proceed() {
    if (!_isValid) return;

    final amountUsdc = double.parse(_amountController.text);
    final memo = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    // Pass data to confirm screen
    context.push(
      '/scan_flow/confirm',
      extra: {
        'merchant': widget.merchant,
        'amountUsdc': amountUsdc,
        'memo': memo,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(Strings.paying, style: context.typography.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MerchantCard(merchant: widget.merchant),
              
              const Spacer(),
              
              // Amount Input
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$ ',
                      style: context.typography.displayLarge?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: context.typography.displayLarge,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: context.typography.displayLarge?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.3),
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                        cursorColor: context.colors.primary,
                        autofocus: true,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // USDC Label
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'USDC on Solana',
                    style: context.typography.labelMedium?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Note Input
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: Strings.addNote,
                  prefixIcon: Icon(Icons.edit_note_rounded, color: context.colors.onSurface.withValues(alpha: 0.6)),
                ),
                style: context.typography.bodyLarge,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _proceed(),
              ),
              
              const SizedBox(height: 24),
              
              // Proceed Button
              ElevatedButton(
                onPressed: _isValid ? _proceed : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(Strings.proceed),
              ),
            ],
          ),
        ),
    );
  }
}
