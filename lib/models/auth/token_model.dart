class TokenModel {
  final String accessToken;
  final int expiresIn;
  final String tokenType;
  final DateTime _createdAt;

  TokenModel({
    required this.accessToken,
    required this.expiresIn,
    required this.tokenType,
    DateTime? createdAt,
  }) : _createdAt = createdAt ?? DateTime.now();

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }

  bool get isExpired {
    final expiry = _createdAt.add(Duration(seconds: expiresIn - 30));
    return DateTime.now().isAfter(expiry);
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'expires_in': expiresIn,
        'token_type': tokenType,
        'created_at': _createdAt.toIso8601String(),
      };

  factory TokenModel.fromStoredJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
