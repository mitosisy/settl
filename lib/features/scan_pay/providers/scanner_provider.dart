import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:chain_pay/models/merchant_model.dart';
import 'package:chain_pay/services/qr_service.dart';

/// State of the QR Scanner.
class ScannerState {
  const ScannerState({
    this.isScanning = true,
    this.merchant,
    this.error,
  });

  final bool isScanning;
  final MerchantModel? merchant;
  final String? error;

  ScannerState copyWith({
    bool? isScanning,
    MerchantModel? merchant,
    String? error,
    bool clearError = false,
  }) {
    return ScannerState(
      isScanning: isScanning ?? this.isScanning,
      merchant: merchant ?? this.merchant,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Manages the QR scanning process and Solana Pay URI parsing.
class ScannerNotifier extends Notifier<ScannerState> {
  final QrService _qrService = QrService();

  @override
  ScannerState build() => const ScannerState();

  void startScanning() {
    state = const ScannerState(isScanning: true);
  }

  void pauseScanning() {
    state = state.copyWith(isScanning: false);
  }

  /// Processes a scanned barcode.
  /// 
  /// Stops scanning if a valid Solana Pay URI or address is found.
  void processBarcode(BarcodeCapture capture) {
    if (!state.isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _parseRawValue(rawValue);
  }

  void processManualEntry(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return;

    // Check for UPI-like ID (e.g., alice@settl)
    if (trimmed.contains('@')) {
      final resolvedAddress = _resolveMockUpiId(trimmed);
      if (resolvedAddress != null) {
        state = ScannerState(
          isScanning: false,
          merchant: MerchantModel(
            walletAddress: resolvedAddress,
            name: trimmed,
            label: 'Settl User',
          ),
        );
      } else {
        state = state.copyWith(error: 'UPI ID not found. Try alice@settl');
      }
      return;
    }

    // Otherwise, treat as raw address or Solana Pay URI
    _parseRawValue(trimmed);
  }

  String? _resolveMockUpiId(String upiId) {
    // Mock Address Book for Hackathon Demo
    final mockRegistry = {
      'alice@settl': '5ZWj7a1f8tWkjBESHKgrLmXshuXxqeY9sy5qN2Yj4c8z',
      'bob@settl': '2K9gJb6fQ8y4dD7zT5cLx9G4w9R4L5n2R3f8w1Y3w8f9',
      'merchant@settl': '8A4E9qY3w8f9D2z4n7Qx2F4A5v8G4w9R4L5n2R3f8w1',
    };
    return mockRegistry[upiId.toLowerCase()];
  }

  void _parseRawValue(String rawValue) {
    try {
      // 1. Check if it's a Solana Pay URI
      if (rawValue.startsWith('solana:')) {
        final parsed = _qrService.decodePaymentQR(rawValue);
        if (parsed != null) {
          state = ScannerState(
            isScanning: false,
            merchant: MerchantModel(
              walletAddress: parsed.recipientAddress,
              label: parsed.label,
              name: parsed.memo,
              amount: parsed.amount,
            ),
          );
          return;
        }
      } 
      
      // 2. Check if it's just a raw Solana address (fallback)
      if (rawValue.length >= 32 && rawValue.length <= 44 && !rawValue.contains(' ')) {
        state = ScannerState(
          isScanning: false,
          merchant: MerchantModel(walletAddress: rawValue),
        );
        return;
      }

      // Invalid format
      state = state.copyWith(
        error: 'Invalid format. Enter a valid address or UPI ID.',
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to process input.',
      );
    }
  }

  void reset() {
    state = const ScannerState();
  }
}

final scannerProvider =
    NotifierProvider<ScannerNotifier, ScannerState>(ScannerNotifier.new);
