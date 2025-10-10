class Pool {
  final int id;
  final String title;
  final String description;
  final double goalAmount;
  final double currentAmount;
  final String currency;
  final DateTime deadline;
  final String type;
  final String imageUrl;
  final String status;
  final int contributionCount;
  final int progressPercentage;
  final Map<String, dynamic> owner;
  final List<Map<String, dynamic>> recentContributions;

  Pool({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.currentAmount,
    required this.currency,
    required this.deadline,
    required this.type,
    required this.imageUrl,
    required this.status,
    required this.contributionCount,
    required this.progressPercentage,
    required this.owner,
    required this.recentContributions,
  });

  factory Pool.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour convertir en double de manière robuste
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Fonction helper pour convertir en int de manière robuste
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Fonction helper pour convertir en String de manière robuste
    String toString(dynamic value) {
      if (value == null) return "";
      return value.toString();
    }

    return Pool(
      id: toInt(json["id"]),
      title: toString(json["title"] ?? json["title"]),
      description: toString(json["description"] ?? json["description"]),
      goalAmount: toDouble(json["goal_amount"] ?? json["goalAmount"]),
      currentAmount: toDouble(json["current_amount"] ?? json["currentAmount"]),
      currency: toString(json["currency"] ?? json["currency"]).isNotEmpty
          ? toString(json["currency"] ?? json["currency"])
          : "XOF",
      deadline: json["deadline"] != null
          ? DateTime.tryParse(toString(json["deadline"])) ??
                DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      type: toString(json["type"] ?? json["type"]).isNotEmpty
          ? toString(json["type"] ?? json["type"])
          : "public",
      imageUrl: toString(json["image_url"] ?? json["imageUrl"]),
      status: toString(json["status"] ?? json["status"]).isNotEmpty
          ? toString(json["status"] ?? json["status"])
          : "active",
      contributionCount: toInt(
        json["contribution_count"] ?? json["contributionCount"],
      ),
      progressPercentage: toInt(
        json["progress_percentage"] ?? json["progressPercentage"],
      ),
      owner: json["owner"] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json["owner"])
          : {"name": "Utilisateur anonyme", "id": "0"},
      recentContributions: json['recent_contributions'] is List
          ? (json['recent_contributions'] as List<dynamic>)
                .map<Map<String, dynamic>>(
                  (e) => e is Map<String, dynamic>
                      ? Map<String, dynamic>.from(e)
                      : <String, dynamic>{},
                )
                .toList()
          : json['recentContributions'] is List
          ? (json['recentContributions'] as List<dynamic>)
                .map<Map<String, dynamic>>(
                  (e) => e is Map<String, dynamic>
                      ? Map<String, dynamic>.from(e)
                      : <String, dynamic>{},
                )
                .toList()
          : <Map<String, dynamic>>[],
    );
  }
}
