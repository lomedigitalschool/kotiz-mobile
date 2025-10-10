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
    final email = json["email"] ?? "";
    final name = json["name"];

    // Utiliser une valeur par défaut plus appropriée
    final defaultName = name?.isNotEmpty == true && name != "Utilisateur"
        ? name
        : (email.isNotEmpty ? email.split('@')[0] : "Utilisateur");

    return User(
      id: (json['id']),
      email: email,
      name: defaultName,
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
