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
        state = state.copyWith(error: 'UPI ID not found. Try trustcafe@settl');
      }
      return;
    }

    // Otherwise, treat as raw address or Solana Pay URI
    _parseRawValue(trimmed);
  }

  String? _resolveMockUpiId(String upiId) {
    // Mock Address Book for Hackathon Demo
    final mockRegistry = {
      'faucet@settl': 'D67ReZBtmq4AxyDXt1iRzWbKL8XMmvLw1LdGvvLZKdRh',
      'trustcafe@settl': 'Kq5vWMGmH1T2wXUfHb7soHuXz23A8FZgpye27vpcaFA',
      'quickmart@settl': '9VWg7mWaZqgNrsZE6VZ6jEUjrNkHWWWw9eZZJMEzvFEs',
      'sketchyvendor@settl': '9HeT589vj2EmvcSYyorBg19j4myTj1kNqVtuT5syfWL7',
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
