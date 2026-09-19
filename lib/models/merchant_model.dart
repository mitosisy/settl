/// Represents a merchant parsed from a QR code or address lookup.
class MerchantModel {
  const MerchantModel({
    required this.walletAddress,
    this.name,
    this.label,
    this.amount,
  });

  /// Merchant's Solana wallet address.
  final String walletAddress;

  /// Merchant name (from QR label or on-chain lookup).
  final String? name;

  /// QR label field.
  final String? label;

  /// Requested amount from the QR code (if any).
  final double? amount;

  /// Returns the best display name available.
  String get displayName => name ?? label ?? walletAddress;

  Map<String, dynamic> toJson() => {
        'walletAddress': walletAddress,
        'name': name,
        'label': label,
        'amount': amount,
      };

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
        walletAddress: json['walletAddress'] as String,
        name: json['name'] as String?,
        label: json['label'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
      );
}
