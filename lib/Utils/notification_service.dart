import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static Future<void> showImmediateNotification() async {
    await _notificationsPlugin.show(
      1,
      'Test Notification',
      'This is an immediate test notification.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Channel for test notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();

    // Request notification permission for Android 13+
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    // Only needed for Android 13+
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    // No need to handle the result here, just request.
  }

  static Future<void> scheduleDailyReminder(int hour, int minute, {BuildContext? context}) async {
    if (Platform.isAndroid) {
      // Check and request SCHEDULE_EXACT_ALARM permission
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        final result = await Permission.scheduleExactAlarm.request();
        if (!result.isGranted && context != null) {
          // Show dialog to guide user to settings
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text('To receive daily reminders, please allow "Schedule exact alarms" permission in system settings.'),
              actions: [
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
          return;
        }
      }
    }
    await _notificationsPlugin.zonedSchedule(
      0,
      'Daily Check-in Reminder',
      'Don\'t forget to check in today!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Channel for daily check-in reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
