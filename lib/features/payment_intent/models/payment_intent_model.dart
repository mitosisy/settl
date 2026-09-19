import 'dart:typed_data';

/// Status of an offline payment intent.
enum IntentStatus {
  /// Signed and stored locally, waiting for connectivity.
  queued,

  /// Currently being broadcast to the Solana network.
  broadcasting,

  /// Successfully confirmed on-chain.
  confirmed,

  /// Failed to broadcast or confirm.
  failed;

  String get displayName {
    return switch (this) {
      IntentStatus.queued => 'Queued',
      IntentStatus.broadcasting => 'Broadcasting',
      IntentStatus.confirmed => 'Confirmed',
      IntentStatus.failed => 'Failed',
    };
  }
}

/// A locally-signed payment intent stored in the offline queue.
///
/// Contains a fully serialized and signed Solana transaction
/// ready to broadcast when connectivity returns.
class PaymentIntentModel {
  PaymentIntentModel({
    required this.id,
    required this.recipientAddress,
    required this.amountUsdc,
    this.memo,
    required this.signedTransactionBytes,
    required this.createdAt,
    this.status = IntentStatus.queued,
    this.recipientName,
  });

  /// Unique identifier (UUID).
  final String id;

  /// Recipient Solana wallet address.
  final String recipientAddress;

  /// Amount in USDC.
  final double amountUsdc;

  /// Optional payment memo/note.
  final String? memo;

  /// Fully serialized and signed Solana transaction bytes.
  final Uint8List signedTransactionBytes;

  /// When this intent was created.
  final DateTime createdAt;

  /// Current status of this intent.
  IntentStatus status;

  /// Merchant/recipient display name (if known).
  final String? recipientName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipientAddress': recipientAddress,
        'amountUsdc': amountUsdc,
        'memo': memo,
        'signedTransactionBytes': signedTransactionBytes.toList(),
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'recipientName': recipientName,
      };

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) =>
      PaymentIntentModel(
        id: json['id'] as String,
        recipientAddress: json['recipientAddress'] as String,
        amountUsdc: (json['amountUsdc'] as num).toDouble(),
        memo: json['memo'] as String?,
        signedTransactionBytes:
            Uint8List.fromList((json['signedTransactionBytes'] as List).cast<int>()),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: IntentStatus.values.byName(json['status'] as String),
        recipientName: json['recipientName'] as String?,
      );
}
