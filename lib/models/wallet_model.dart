/// Represents the user's Solana wallet.
class WalletModel {
  const WalletModel({
    required this.publicKey,
    this.displayName,
    required this.createdAt,
  });

  /// Base58-encoded Solana public key (address).
  final String publicKey;

  /// User-set display name.
  final String? displayName;

  /// Wallet creation timestamp.
  final DateTime createdAt;

  WalletModel copyWith({
    String? publicKey,
    String? displayName,
    DateTime? createdAt,
  }) {
    return WalletModel(
      publicKey: publicKey ?? this.publicKey,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'publicKey': publicKey,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        publicKey: json['publicKey'] as String,
        displayName: json['displayName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
