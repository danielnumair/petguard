import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);

    // 🚩 Solicita permissões no Android (a partir do Android 13)
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    // Pede permissão de notificação
    final notificationStatus = await Permission.notification.request();
    if (notificationStatus.isDenied) {
      print('Permissão de notificação negada.');
    }

    // Pede permissão para alarmes exatos (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isDenied) {
        print('Permissão para alarmes exatos negada.');
      }
    }
  }

  /// Notificação imediata
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceAt8AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_guard_channel',
          'PetGuard Notificações',
          channelDescription: 'Notificações de lembretes de pets',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Diariamente às 8h
    );
  }

  static tz.TZDateTime _nextInstanceAt8AM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 8, 0); // 8h da manhã
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> showNotificationAgendada({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_guard_channel',
          'PetGuard Notificações',
          channelDescription: 'Notificações de lembretes de pets',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
