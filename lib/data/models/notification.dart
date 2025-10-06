class NotificationModel {
  final String id;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? json['status'] == 'read' ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
    };
  }
}