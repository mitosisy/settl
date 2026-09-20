import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:chain_pay/core/theme/theme_extension.dart';
import 'package:chain_pay/core/constants/strings.dart';
import 'package:chain_pay/features/scan_pay/providers/scanner_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If scanning was successful and merchant is found, navigate to reputation screen
    ref.listen(scannerProvider, (previous, next) {
      if (next.merchant != null && !next.isScanning) {
        // Go router allows passing extra object
        context.push('/scan_flow/reputation', extra: next.merchant);
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              ref.read(scannerProvider.notifier).processBarcode(capture);
            },
          ),
          
          // Overlay mask with clear center
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Scanner corners and UI
          SafeArea(
            child: Column(
              children: [
                // Top app bar elements
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () {
                          ref.read(scannerProvider.notifier).reset();
                          context.go('/home');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                        onPressed: () => _scannerController.toggleTorch(),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Instructions
                Text(
                  Strings.scannerOverlay,
                  style: context.typography.bodyLarge?.copyWith(color: Colors.white),
                ),
                
                const SizedBox(height: 32),
                
                // Scanner focus frame (4 corners)
                Center(
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Bottom manual entry button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: TextButton(
                    onPressed: () async {
                      final input = await _showManualEntryDialog(context);
                      if (input != null && input.trim().isNotEmpty) {
                        ref.read(scannerProvider.notifier).processManualEntry(input);
                      }
                    },
                    child: Text(
                      Strings.enterManually,
                      style: context.typography.labelLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: context.colors.onSurface.withValues(alpha: 0.1)),
        ),
        backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
        title: Text('Manual Entry', style: context.typography.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter a Solana address or UPI ID (e.g., alice@settl)', 
                 style: context.typography.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: context.typography.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Address or @settl ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: context.typography.labelLarge?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
