class User {
  final int? id;
  final String email;
  final String name;
  final String phone;
  // final bool isVerified;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    // required this.isVerified,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id']),
      email: json["email"],
      name: json["name"] ?? "Utilisateur",
      phone: json["phone"] ?? "",
      // isVerified: json["isVerified"],
      avatarUrl: json["avatarUrl"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'phone': phone,
    // 'isVerified': isVerified,
    "avatarUrl": avatarUrl,
  };
}
