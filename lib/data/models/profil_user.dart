class ProfilUser {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final bool isVerified;
  final bool isBlocked;
  final DateTime? lastLogin;
  final String? resetToken;
  final DateTime? resetTokenExpiry;

  final String? firebaseUid;
  final bool isPhoneVerified;
  final DateTime? phoneVerifiedAt;
  final DateTime? passwordResetAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  ProfilUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    required this.isVerified,
    required this.isBlocked,
    this.lastLogin,
    this.resetToken,
    this.resetTokenExpiry,
    this.firebaseUid,
    required this.isPhoneVerified,
    this.phoneVerifiedAt,
    this.passwordResetAt,
    required this.createdAt,
    required this.updatedAt,
  });
  factory ProfilUser.fromJson(Map<String, dynamic> json) {
    return ProfilUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatarUrl: json['avatarUrl'],
      isVerified: json['isVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      resetToken: json['resetToken'],
      resetTokenExpiry: json['resetTokenExpiry'] != null
          ? DateTime.parse(json['resetTokenExpiry'])
          : null,
      firebaseUid: json['firebaseUid'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      phoneVerifiedAt: json['phoneVerifiedAt'] != null
          ? DateTime.parse(json['phoneVerifiedAt'])
          : null,
      passwordResetAt: json['passwordResetAt'] != null
          ? DateTime.parse(json['passwordResetAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
