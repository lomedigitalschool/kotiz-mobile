import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/notification_service.dart';
import 'package:kotiz_app/data/models/notification.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  
  NotificationLoaded(this.notifications);
  
  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;
  
  NotificationError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _service;
  
  NotificationCubit(this._service) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await _service.fetchNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Erreur lors du chargement des notifications'));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      try {
        await _service.markAsRead(notificationId);
        
        // Mettre à jour l'état local
        final updatedNotifications = currentState.notifications.map((notif) {
          if (notif.id == notificationId) {
            return NotificationModel(
              id: notif.id,
              message: notif.message,
              type: notif.type,
              isRead: true,
              createdAt: notif.createdAt,
              data: notif.data,
            );
          }
          return notif;
        }).toList();
        
        emit(NotificationLoaded(updatedNotifications));
      } catch (e) {
        emit(NotificationError('Erreur lors du marquage comme lu'));
      }
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      try {
        final unreadIds = currentState.notifications
            .where((notif) => !notif.isRead)
            .map((notif) => notif.id)
            .toList();
            
        await _service.markAllAsRead(unreadIds);
        
        // Mettre à jour l'état local
        final updatedNotifications = currentState.notifications.map((notif) {
          return NotificationModel(
            id: notif.id,
            message: notif.message,
            type: notif.type,
            isRead: true,
            createdAt: notif.createdAt,
            data: notif.data,
          );
        }).toList();
        
        emit(NotificationLoaded(updatedNotifications));
      } catch (e) {
        emit(NotificationError('Erreur lors du marquage de toutes les notifications'));
      }
    }
  }

  int get unreadCount {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      return currentState.notifications.where((notif) => !notif.isRead).length;
    }
    return 0;
  }
}