class IdentityModel {
  final String settlId;
  final String pubKey;

  const IdentityModel({
    required this.settlId,
    required this.pubKey,
  });

  factory IdentityModel.fromJson(Map<String, dynamic> json) {
    return IdentityModel(
      settlId: json['settlId'] as String,
      pubKey: json['pubKey'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settlId': settlId,
      'pubKey': pubKey,
    };
  }
}
