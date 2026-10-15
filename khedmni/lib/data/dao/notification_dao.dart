import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/notification_model.dart';

class NotificationDao {
  final dbHelper = DatabaseHelper.instance;

  /// Insert a new notification
  Future<int> insertNotification(NotificationModel notification) async {
    final db = await dbHelper.database;
    
    final notificationMap = {
      'id': notification.id,
      'title': notification.title,
      'message': notification.message,
      'timestamp': notification.timestamp.toIso8601String(),
      'isRead': notification.isRead ? 1 : 0,
      'type': notification.type.toString(),
      'relatedId': notification.relatedId,
    };
    
    return await db.insert(
      'notifications',
      notificationMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await dbHelper.database;
    final maps = await db.query('notifications', orderBy: 'timestamp DESC');
    
    return List.generate(maps.length, (i) {
      return NotificationModel(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        message: maps[i]['message'] as String,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        isRead: (maps[i]['isRead'] as int) == 1,
        type: NotificationType.values.firstWhere(
          (e) => e.toString() == maps[i]['type'],
          orElse: () => NotificationType.general,
        ),
        relatedId: maps[i]['relatedId'] as String?,
      );
    });
  }

  /// Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'notifications',
      where: 'isRead = ?',
      whereArgs: [0],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return NotificationModel(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        message: maps[i]['message'] as String,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        isRead: false,
        type: NotificationType.values.firstWhere(
          (e) => e.toString() == maps[i]['type'],
          orElse: () => NotificationType.general,
        ),
        relatedId: maps[i]['relatedId'] as String?,
      );
    });
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return NotificationModel(
        id: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        isRead: (map['isRead'] as int) == 1,
        type: NotificationType.values.firstWhere(
          (e) => e.toString() == map['type'],
          orElse: () => NotificationType.general,
        ),
        relatedId: map['relatedId'] as String?,
      );
    }
    return null;
  }

  /// Mark notification as read
  Future<int> markAsRead(String id) async {
    final db = await dbHelper.database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark all notifications as read
  Future<int> markAllAsRead() async {
    final db = await dbHelper.database;
    return await db.update(
      'notifications',
      {'isRead': 1},
    );
  }

  /// Delete notification
  Future<int> deleteNotification(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all notifications
  Future<int> deleteAllNotifications() async {
    final db = await dbHelper.database;
    return await db.delete('notifications');
  }

  /// Seed notifications (insert multiple notifications at once)
  Future<void> seedNotifications(List<NotificationModel> notifications) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    
    for (var notification in notifications) {
      final notificationMap = {
        'id': notification.id,
        'title': notification.title,
        'message': notification.message,
        'timestamp': notification.timestamp.toIso8601String(),
        'isRead': notification.isRead ? 1 : 0,
        'type': notification.type.toString(),
        'relatedId': notification.relatedId,
      };
      batch.insert('notifications', notificationMap, 
        conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }
}
