import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/notification_cubit.dart';
import 'package:kotiz_app/data/models/notification.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _filter = 'all'; // 'all', 'unread', 'read'

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    context.read<NotificationCubit>().fetchNotifications();
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
    switch (_filter) {
      case 'unread':
        return notifications.where((notif) => !notif.isRead).toList();
      case 'read':
        return notifications.where((notif) => notif.isRead).toList();
      default:
        return notifications;
    }
  }

  void _markAsRead(String notificationId) {
    context.read<NotificationCubit>().markAsRead(notificationId);
  }

  void _markAllAsRead() {
    context.read<NotificationCubit>().markAllAsRead();
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: const Text('Toutes les notifications ont été marquées comme lues'),
      backgroundColor: Colors.green.shade200,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  String _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'contribution':
      case 'newcontribution':
        return '💰';
      case 'kyc':
      case 'kycapproved':
      case 'kycrejected':
        return '🛡️';
      case 'payment':
      case 'paymentresult':
        return '💳';
      case 'cagnotte':
      case 'cagnotteclosed':
        return '🎯';
      default:
        return '🔔';
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
      case 'kycapproved':
        return Colors.green;
      case 'error':
      case 'kycrejected':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return ColorConstant.colorBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: ColorConstant.colorWhite,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded) {
                final hasUnread = state.notifications.any((notif) => !notif.isRead);
                if (hasUnread) {
                  return TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text('Tout lire'),
                  );
                }
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Connectez-vous pour voir vos notifications',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filtres
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: BlocBuilder<NotificationCubit, NotificationState>(
                        builder: (context, state) {
                          final notifications = state is NotificationLoaded ? state.notifications : <NotificationModel>[];
                          final allCount = notifications.length;
                          final unreadCount = notifications.where((n) => !n.isRead).length;
                          final readCount = notifications.where((n) => n.isRead).length;

                          return Row(
                            children: [
                              _buildFilterButton('all', 'Toutes ($allCount)'),
                              const SizedBox(width: 8),
                              _buildFilterButton('unread', 'Non lues ($unreadCount)'),
                              const SizedBox(width: 8),
                              _buildFilterButton('read', 'Lues ($readCount)'),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des notifications
              Expanded(
                child: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is NotificationError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadNotifications,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is NotificationLoaded) {
                      final filteredNotifications = _filterNotifications(state.notifications);

                      if (filteredNotifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.bell, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _getEmptyMessage(),
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _loadNotifications(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _buildNotificationItem(notification);
                          },
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(String filterValue, String label) {
    final isSelected = _filter == filterValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = filterValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? ColorConstant.colorGreen : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: !notification.isRead
            ? Border.all(color: ColorConstant.colorGreen, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône de notification
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _getNotificationIcon(notification.type),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Contenu de la notification
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatDate(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          notification.type,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bouton marquer comme lu
            if (!notification.isRead)
              GestureDetector(
                onTap: () => _markAsRead(notification.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConstant.colorGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              )
            else
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }

  String _getEmptyMessage() {
    switch (_filter) {
      case 'unread':
        return 'Aucune notification non lue';
      case 'read':
        return 'Aucune notification lue';
      default:
        return 'Aucune notification pour le moment';
    }
  }
}