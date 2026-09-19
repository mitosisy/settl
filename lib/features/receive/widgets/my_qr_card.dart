import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:chain_pay/core/theme/app_colors.dart';

/// Card displaying the user's Solana Pay QR code.
class MyQrCard extends StatelessWidget {
  const MyQrCard({
    super.key,
    required this.qrData,
    this.size = 250,
  });

  final String qrData;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandSaffron.withOpacity(0.15),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.bgDeep,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.bgDeep,
        ),
      ),
    );
  }
}
