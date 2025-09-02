import 'package:flutter/foundation.dart';

class User {
  final String email;
  final String name;
  final String phone;
  final String role;
  final bool isVerified;
  final String avatarUrl;

  User({
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json["email"],
      name: json["name"],
      phone: json["phone"],
      role: json["role"],
      isVerified: json["isVerified"],
      avatarUrl: json["avatarUrl"],
    );
  }
}
