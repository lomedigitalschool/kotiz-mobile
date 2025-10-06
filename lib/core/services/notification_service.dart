import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/data/models/notification.dart';

class NotificationService {
  final ApiConfig _apiConfig;
  
  NotificationService(this._apiConfig);

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _apiConfig.get<Map<String, dynamic>>('/notifications');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiConfig.put('/notifications/$notificationId/read');
    } catch (e) {
      throw Exception('Erreur lors du marquage comme lu: $e');
    }
  }

  Future<void> markAllAsRead(List<String> notificationIds) async {
    try {
      for (String id in notificationIds) {
        await markAsRead(id);
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage de toutes les notifications: $e');
    }
  }
}