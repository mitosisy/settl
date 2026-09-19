/// Status of a transaction on the Solana network.
enum TransactionStatus {
  confirmed,
  pending,
  queued,
  failed;

  String get displayName {
    return switch (this) {
      TransactionStatus.confirmed => 'Confirmed',
      TransactionStatus.pending => 'Pending',
      TransactionStatus.queued => 'Queued',
      TransactionStatus.failed => 'Failed',
    };
  }
}

/// Direction of a transaction relative to the user.
enum TransactionType {
  sent,
  received;
}

/// Represents a single transaction (on-chain or queued).
class TransactionModel {
  const TransactionModel({
    required this.signature,
    required this.fromAddress,
    required this.toAddress,
    required this.amountUsdc,
    this.networkFeeSol,
    this.memo,
    required this.timestamp,
    required this.status,
    required this.type,
  });

  /// Solana transaction signature (hash).
  final String signature;

  /// Sender wallet address.
  final String fromAddress;

  /// Recipient wallet address.
  final String toAddress;

  /// Amount in USDC.
  final double amountUsdc;

  /// Network fee in SOL (if known).
  final double? networkFeeSol;

  /// Optional payment memo/note.
  final String? memo;

  /// Transaction timestamp.
  final DateTime timestamp;

  /// Current status of the transaction.
  final TransactionStatus status;

  /// Whether this was sent or received by the user.
  final TransactionType type;

  TransactionModel copyWith({
    String? signature,
    String? fromAddress,
    String? toAddress,
    double? amountUsdc,
    double? networkFeeSol,
    String? memo,
    DateTime? timestamp,
    TransactionStatus? status,
    TransactionType? type,
  }) {
    return TransactionModel(
      signature: signature ?? this.signature,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      amountUsdc: amountUsdc ?? this.amountUsdc,
      networkFeeSol: networkFeeSol ?? this.networkFeeSol,
      memo: memo ?? this.memo,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
        'signature': signature,
        'fromAddress': fromAddress,
        'toAddress': toAddress,
        'amountUsdc': amountUsdc,
        'networkFeeSol': networkFeeSol,
        'memo': memo,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'type': type.name,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        signature: json['signature'] as String,
        fromAddress: json['fromAddress'] as String,
        toAddress: json['toAddress'] as String,
        amountUsdc: (json['amountUsdc'] as num).toDouble(),
        networkFeeSol: (json['networkFeeSol'] as num?)?.toDouble(),
        memo: json['memo'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: TransactionStatus.values.byName(json['status'] as String),
        type: TransactionType.values.byName(json['type'] as String),
      );
}
