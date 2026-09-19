/// Represents a merchant parsed from a QR code or address lookup.
class MerchantModel {
  const MerchantModel({
    required this.walletAddress,
    this.name,
    this.label,
  });

  /// Merchant's Solana wallet address.
  final String walletAddress;

  /// Merchant name (from QR label or on-chain lookup).
  final String? name;

  /// QR label field.
  final String? label;

  /// Returns the best display name available.
  String get displayName => name ?? label ?? walletAddress;

  Map<String, dynamic> toJson() => {
        'walletAddress': walletAddress,
        'name': name,
        'label': label,
      };

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
        walletAddress: json['walletAddress'] as String,
        name: json['name'] as String?,
        label: json['label'] as String?,
      );
}
