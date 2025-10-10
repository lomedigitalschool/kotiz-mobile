class Contribution {
  final int id;
  final int? userId;
  final int pullId;
  final double amount;
  final String currency;
  final String status;
  final String? contributorName;
  final String? contributorEmail;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;
  Contribution({
    required this.id,
    this.userId,
    required this.pullId,
    required this.amount,
    required this.currency,
    required this.status,
    this.contributorName,
    this.contributorEmail,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });
  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? json['user_id'],
      pullId: json['pullId'] ?? json['pull_id'] ?? 0,
      amount: json['amount'] is String
          ? double.tryParse(json['amount']) ?? 0.0
          : (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'XOF',
      status: json['status'] ?? 'pending',
      contributorName: json['contributorName'] ?? json['contributor_name'],
      contributorEmail: json['contributorEmail'] ?? json['contributor_email'],
      message: json['message'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
