import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> showTaskComplete(String taskTitle) async {
    const androidDetails = AndroidNotificationDetails(
      'task_complete',
      'Task Complete',
      channelDescription: 'Shown when a focus session finishes',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: false,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: taskTitle.hashCode.abs() % 2147483647,
      title: 'Task complete',
      body: taskTitle,
      notificationDetails: details,
    );
  }
}
