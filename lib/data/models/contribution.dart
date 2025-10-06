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
      userId: json['userId'],
      pullId: json['pullId'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'XOF',
      status: json['status'] ?? 'pending',
      contributorName: json['contributorName'],
      contributorEmail: json['contributorEmail'],
      message: json['message'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
}
