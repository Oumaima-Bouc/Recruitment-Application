import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notification_model.dart';
import 'notification_state.dart';
import '../../data/dao/notification_dao.dart';
// import '../../data/dummy_data.dart'; // Removed dummy data import

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  final NotificationDao _notificationDao = NotificationDao();
  List<NotificationModel> _notifications = [];

  /// Fetch all notifications
  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      // Fetch from DB
      _notifications = await _notificationDao.getAllNotifications();

      final unreadCount = _notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: List.from(_notifications),
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationDao.markAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        
        final unreadCount = _notifications.where((n) => !n.isRead).length;
        
        emit(NotificationLoaded(
          notifications: List.from(_notifications),
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationDao.markAllAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      
      emit(NotificationLoaded(
        notifications: List.from(_notifications),
        unreadCount: 0,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationDao.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      
      final unreadCount = _notifications.where((n) => !n.isRead).length;
      
      emit(NotificationLoaded(
        notifications: List.from(_notifications),
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      await _notificationDao.deleteAllNotifications();
      _notifications.clear();
      
      emit(const NotificationLoaded(
        notifications: [],
        unreadCount: 0,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Get unread count
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Generate dummy notifications (DISABLED)
  List<NotificationModel> _generateDummyNotifications() {
    return [];
  }
}