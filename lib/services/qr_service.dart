import 'package:chain_pay/core/errors/app_exception.dart';

/// Result of parsing a Solana Pay QR code URI.
class ParsedQR {
  const ParsedQR({
    required this.recipientAddress,
    this.amount,
    this.splTokenMint,
    this.label,
    this.memo,
    this.reference,
  });

  /// Recipient Solana wallet address.
  final String recipientAddress;

  /// Requested payment amount (if specified).
  final double? amount;

  /// SPL token mint address (e.g., USDC mint).
  final String? splTokenMint;

  /// Merchant label/name.
  final String? label;

  /// Payment memo.
  final String? memo;

  /// Reference key for tracking.
  final String? reference;
}

/// Encodes and decodes Solana Pay URIs for QR code generation and scanning.
///
/// Solana Pay URI format:
/// `solana:<recipient>?amount=<amount>&spl-token=<token-mint>&label=<label>&memo=<memo>&reference=<reference>`
class QrService {
  /// USDC mint address on Solana Devnet.
  static const String _usdcMint =
      'Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr';

  /// Encodes a Solana Pay URI for QR code generation.
  ///
  /// The [address] is the recipient's Solana wallet address.
  /// Optional parameters populate the URI query string.
  String encodePaymentQR(
    String address, {
    double? amount,
    String? reference,
    String? label,
    String? memo,
  }) {
    final params = <String, String>{};
    params['spl-token'] = _usdcMint;

    if (amount != null) params['amount'] = amount.toString();
    if (reference != null) params['reference'] = reference;
    if (label != null) params['label'] = label;
    if (memo != null) params['memo'] = memo;

    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'solana:$address?$queryString';
  }

  /// Decodes a Solana Pay URI from a scanned QR code.
  ///
  /// Returns `null` if the URI format is invalid.
  /// Throws [QrParseException] if the URI is malformed.
  ParsedQR? decodePaymentQR(String rawQRContent) {
    if (!rawQRContent.startsWith('solana:')) return null;

    try {
      final withoutScheme = rawQRContent.substring(7); // remove 'solana:'
      final parts = withoutScheme.split('?');
      final recipientAddress = parts[0];

      if (recipientAddress.isEmpty) return null;

      String? amountStr;
      String? splTokenMint;
      String? label;
      String? memo;
      String? reference;

      if (parts.length > 1) {
        final queryParams = Uri.splitQueryString(parts[1]);
        amountStr = queryParams['amount'];
        splTokenMint = queryParams['spl-token'];
        label = queryParams['label'];
        memo = queryParams['memo'];
        reference = queryParams['reference'];
      }

      return ParsedQR(
        recipientAddress: recipientAddress,
        amount: amountStr != null ? double.tryParse(amountStr) : null,
        splTokenMint: splTokenMint,
        label: label,
        memo: memo,
        reference: reference,
      );
    } catch (e) {
      throw QrParseException('Failed to parse Solana Pay URI', cause: e);
    }
  }
}
