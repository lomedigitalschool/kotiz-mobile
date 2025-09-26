class Pool {
  final int id;
  final String title;
  final String description;
  final int goalAmount;
  final int currentAmount;
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
    return Pool(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      goalAmount: json["goalAmount"] ?? 0,
      currentAmount: json["currentAmount"] ?? 0,
      currency: json["currency"] ?? "XOF",
      deadline: json["deadline"] != null
          ? DateTime.parse(json["deadline"])
          : DateTime.now(),
      type: json["type"] ?? "public",
      imageUrl: json["imageUrl"] ?? "",
      status: json["status"] ?? "active",
      contributionCount: json["contributionCount"] ?? 0,
      progressPercentage: json["progressPercentage"] ?? 0,
      owner: Map<String, dynamic>.from(json["owner"] ?? {}),
      recentContributions:
          (json['recentContributions'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
    );
  }
}
