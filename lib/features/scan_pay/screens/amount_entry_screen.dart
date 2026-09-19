import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/core/utils/validators.dart';
import 'package:chain_pay/features/scan_pay/widgets/merchant_card.dart';
import 'package:chain_pay/models/merchant_model.dart';

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
      '/scan/confirm',
      extra: {
        'merchant': widget.merchant,
        'amountUsdc': amountUsdc,
        'memo': memo,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text(Strings.paying),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTypography.displayLarge,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: AppTypography.displayLarge.copyWith(
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                        cursorColor: AppColors.brandSaffron,
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
                    color: AppColors.brandGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'USDC on Solana',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.brandGreen,
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
                  prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.textSecondary),
                ),
                style: AppTypography.bodyLarge,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _proceed(),
              ),
              
              const SizedBox(height: 24),
              
              // Proceed Button
              ElevatedButton(
                onPressed: _isValid ? _proceed : null,
                child: const Text(Strings.proceed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
