// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class NotificationService {
//   static Future<void> showImmediateNotification() async {
//     try {
//       await _notificationsPlugin.show(
//         1,
//         'Test Notification',
//         'This is an immediate test notification.',
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'test_channel',
//             'Test Notifications',
//             channelDescription: 'Channel for test notifications',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//           iOS: DarwinNotificationDetails(
//             sound: 'default',
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//       );
//       print('Immediate notification triggered successfully');
//     } catch (e) {
//       print('Error showing immediate notification: $e');
//     }
//   }
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     // Initialize timezone data first
//     tz.initializeTimeZones();
//
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//     await _notificationsPlugin.initialize(initializationSettings);
//
//     // Create notification channels for Android
//     await _createNotificationChannels();
//
//     // Request notification permission for Android 13+
//     await _requestPermissions();
//   }
//
//   static Future<void> _createNotificationChannels() async {
//     if (Platform.isAndroid) {
//       final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//
//       // Create daily reminder channel
//       const dailyReminderChannel = AndroidNotificationChannel(
//         'daily_reminder_channel',
//         'Daily Reminders',
//         description: 'Channel for daily check-in reminders',
//         importance: Importance.max,
//         enableVibration: true,
//         playSound: true,
//       );
//
//       // Create test channel
//       const testChannel = AndroidNotificationChannel(
//         'test_channel',
//         'Test Notifications',
//         description: 'Channel for test notifications',
//         importance: Importance.max,
//         enableVibration: true,
//         playSound: true,
//       );
//
//       await androidImplementation?.createNotificationChannel(dailyReminderChannel);
//       await androidImplementation?.createNotificationChannel(testChannel);
//     }
//   }
//
//   static Future<void> _requestPermissions() async {
//     // Only needed for Android 13+
//     final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//     await androidImplementation?.requestNotificationsPermission();
//     // No need to handle the result here, just request.
//   }
//
//   static Future<void> scheduleDailyReminder(int hour, int minute, {BuildContext? context}) async {
//     if (Platform.isAndroid) {
//       // Check and request SCHEDULE_EXACT_ALARM permission (critical for Android 12+/15)
//       final status = await Permission.scheduleExactAlarm.status;
//       print('Schedule exact alarm permission status: $status');
//
//       if (!status.isGranted) {
//         if (context != null) {
//           // Show detailed dialog for Android 15
//           showDialog(
//             context: context,
//             builder: (ctx) => AlertDialog(
//               title: const Text('⚠️ Permission Required for Android 15'),
//               content: const Text(
//                 'Android 15 requires "Schedule exact alarms" permission for daily reminders.\n\n'
//                 'Steps:\n'
//                 '1. Tap "Open Settings" below\n'
//                 '2. Find "Alarms & reminders" or "Schedule exact alarms"\n'
//                 '3. Enable the permission\n'
//                 '4. Return to app and try again'
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     openAppSettings();
//                     Navigator.of(ctx).pop();
//                   },
//                   child: const Text('Open Settings'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.of(ctx).pop(),
//                   child: const Text('Cancel'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         // Try to request permission anyway
//         final result = await Permission.scheduleExactAlarm.request();
//         if (!result.isGranted) {
//           print('Schedule exact alarm permission denied. Daily reminders will not work properly.');
//           return;
//         }
//       }
//     }
//     try {
//       // Cancel existing reminder first
//       await _notificationsPlugin.cancel(0);
//
//       final scheduledDate = _nextInstanceOfTime(hour, minute);
//       print('Scheduling daily reminder for: $scheduledDate');
//
//       await _notificationsPlugin.zonedSchedule(
//       0,
//       'Daily Check-in Reminder',
//       'Don\'t forget to check in today! Time for your daily pact check-in.',
//       scheduledDate,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_reminder_channel',
//           'Daily Reminders',
//           channelDescription: 'Channel for daily check-in reminders',
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: true,
//           enableVibration: true,
//           playSound: true,
//         ),
//         iOS: DarwinNotificationDetails(
//           sound: 'default',
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//
//       print('Daily reminder scheduled successfully for: $scheduledDate');
//
//       // Verify it was scheduled
//       final pending = await getPendingNotifications();
//       final dailyReminder = pending.where((n) => n.id == 0).isNotEmpty;
//       print('Daily reminder in pending notifications: $dailyReminder');
//
//     } catch (e) {
//       print('Error scheduling daily reminder: $e');
//       rethrow;
//     }
//   }
//
//   static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
//     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//     return scheduledDate;
//   }
//
//   static Future<void> cancelAll() async {
//     await _notificationsPlugin.cancelAll();
//   }
//
//   // Enhanced test method with detailed logging
//   static Future<Map<String, dynamic>> testScheduledNotificationWithDetails() async {
//     final result = <String, dynamic>{};
//
//     try {
//       print('=== STARTING DETAILED NOTIFICATION TEST ===');
//
//       // Step 1: Check permissions first
//       final permissions = await checkPermissions();
//       result['permissions_before'] = permissions;
//       print('Step 1 - Permissions: $permissions');
//
//       if (Platform.isAndroid) {
//         final exactAlarm = await Permission.scheduleExactAlarm.isGranted;
//         final notification = await Permission.notification.isGranted;
//
//         if (!exactAlarm || !notification) {
//           result['error'] = 'Missing critical permissions';
//           result['missing_permissions'] = {
//             'exactAlarm': !exactAlarm,
//             'notification': !notification,
//           };
//           print('FAILED: Missing permissions - exactAlarm: $exactAlarm, notification: $notification');
//           return result;
//         }
//       }
//
//       // Step 2: Cancel any existing test notification
//       await _notificationsPlugin.cancel(99);
//       print('Step 2 - Cancelled existing test notification');
//
//       // Step 3: Check current time and calculate test time
//       final now = tz.TZDateTime.now(tz.local);
//       final testTime = now.add(const Duration(seconds: 8)); // Give more time
//       result['current_time'] = now.toString();
//       result['scheduled_time'] = testTime.toString();
//       print('Step 3 - Current: $now, Scheduled for: $testTime');
//
//       // Step 4: Schedule the notification
//       await _notificationsPlugin.zonedSchedule(
//         99, // Different ID for test
//         'Detailed Test Notification',
//         'This test was scheduled at ${now.toString().substring(11, 19)} for ${testTime.toString().substring(11, 19)}',
//         testTime,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'test_channel',
//             'Test Notifications',
//             channelDescription: 'Channel for test notifications',
//             importance: Importance.max,
//             priority: Priority.high,
//             showWhen: true,
//             enableVibration: true,
//             playSound: true,
//           ),
//           iOS: DarwinNotificationDetails(
//             sound: 'default',
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       );
//       print('Step 4 - Notification scheduled successfully');
//
//       // Step 5: Verify it was scheduled
//       await Future.delayed(Duration(milliseconds: 500)); // Wait a bit
//       final pending = await getPendingNotifications();
//       final testNotification = pending.where((n) => n.id == 99).first;
//
//       result['scheduled_successfully'] = true;
//       result['pending_count'] = pending.length;
//       result['test_notification_found'] = testNotification != null;
//       result['test_notification_details'] = testNotification != null ? {
//         'id': testNotification.id,
//         'title': testNotification.title,
//         'body': testNotification.body,
//       } : null;
//
//       print('Step 5 - Verification: pending count: ${pending.length}, test found: ${testNotification != null}');
//       print('=== TEST COMPLETED SUCCESSFULLY ===');
//
//     } catch (e) {
//       result['error'] = e.toString();
//       result['scheduled_successfully'] = false;
//       print('ERROR in test: $e');
//       print('=== TEST FAILED ===');
//     }
//
//     return result;
//   }
//
//   // Simple test method (keep for backward compatibility)
//   static Future<void> testScheduledNotification() async {
//     final result = await testScheduledNotificationWithDetails();
//     if (result['error'] != null) {
//       throw Exception(result['error']);
//     }
//   }
//
//   // Get pending notifications for debugging
//   static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     return await _notificationsPlugin.pendingNotificationRequests();
//   }
//
//   // Check if battery optimization is disabled (critical for notifications)
//   static Future<bool> isBatteryOptimizationDisabled() async {
//     if (Platform.isAndroid) {
//       try {
//         // This checks if the app is whitelisted from battery optimization
//         final status = await Permission.ignoreBatteryOptimizations.isGranted;
//         return status;
//       } catch (e) {
//         print('Error checking battery optimization: $e');
//         return false;
//       }
//     }
//     return true; // iOS doesn't have this issue
//   }
//
//   // Request to disable battery optimization
//   static Future<bool> requestBatteryOptimizationDisable() async {
//     if (Platform.isAndroid) {
//       try {
//         final status = await Permission.ignoreBatteryOptimizations.request();
//         return status.isGranted;
//       } catch (e) {
//         print('Error requesting battery optimization disable: $e');
//         return false;
//       }
//     }
//     return true;
//   }
//
//   // Comprehensive diagnostic method
//   static Future<Map<String, dynamic>> runDiagnostics() async {
//     final diagnostics = <String, dynamic>{};
//
//     try {
//       print('=== STARTING COMPREHENSIVE DIAGNOSTICS ===');
//
//       // Check permissions
//       final permissions = await checkPermissions();
//       diagnostics['permissions'] = permissions;
//
//       // Check battery optimization
//       final batteryOptimized = await isBatteryOptimizationDisabled();
//       diagnostics['battery_optimization_disabled'] = batteryOptimized;
//
//       // Check pending notifications
//       final pending = await getPendingNotifications();
//       diagnostics['pendingNotifications'] = pending.length;
//       diagnostics['pendingDetails'] = pending.map((n) => {
//         'id': n.id,
//         'title': n.title,
//         'body': n.body,
//       }).toList();
//
//       // Check timezone
//       final now = tz.TZDateTime.now(tz.local);
//       diagnostics['currentTime'] = now.toString();
//       diagnostics['timezone'] = now.location.name;
//
//       // Platform info
//       diagnostics['platform'] = Platform.isAndroid ? 'Android' : 'iOS';
//
//       // Android 15 specific checks
//       if (Platform.isAndroid) {
//         final exactAlarmGranted = await Permission.scheduleExactAlarm.isGranted;
//         final notificationGranted = await Permission.notification.isGranted;
//
//         diagnostics['android15_critical'] = {
//           'exactAlarmPermission': exactAlarmGranted,
//           'notificationPermission': notificationGranted,
//           'batteryOptimizationDisabled': batteryOptimized,
//           'allRequiredPermissions': exactAlarmGranted && notificationGranted && batteryOptimized,
//         };
//
//         // Build comprehensive warning messages
//         List<String> warnings = [];
//         if (!exactAlarmGranted) {
//           warnings.add('Schedule exact alarms permission missing');
//         }
//         if (!notificationGranted) {
//           warnings.add('Notification permission missing');
//         }
//         if (!batteryOptimized) {
//           warnings.add('Battery optimization enabled (will kill notifications)');
//         }
//
//         if (warnings.isNotEmpty) {
//           diagnostics['android15_warning'] = 'CRITICAL ISSUES: ${warnings.join(', ')}';
//         }
//       }
//
//       print('=== NOTIFICATION DIAGNOSTICS (Android 15) ===');
//       diagnostics.forEach((key, value) {
//         print('$key: $value');
//       });
//       print('=== END DIAGNOSTICS ===');
//
//     } catch (e) {
//       diagnostics['error'] = e.toString();
//       print('Error running diagnostics: $e');
//     }
//
//     return diagnostics;
//   }
//
//   // Check if all necessary permissions are granted
//   static Future<Map<String, bool>> checkPermissions() async {
//     final Map<String, bool> permissions = {};
//
//     if (Platform.isAndroid) {
//       permissions['notifications'] = await Permission.notification.isGranted;
//       permissions['scheduleExactAlarm'] = await Permission.scheduleExactAlarm.isGranted;
//     }
//
//     return permissions;
//   }
//
//   // Request all necessary permissions
//   static Future<bool> requestAllPermissions(BuildContext? context) async {
//     if (Platform.isAndroid) {
//       print('Requesting Android permissions...');
//
//       // Request notification permission first
//       final notificationStatus = await Permission.notification.request();
//       print('Notification permission: $notificationStatus');
//
//       // Request exact alarm permission (critical for Android 15)
//       final alarmStatus = await Permission.scheduleExactAlarm.request();
//       print('Schedule exact alarm permission: $alarmStatus');
//
//       if (!alarmStatus.isGranted && context != null) {
//         showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             title: const Text('🔔 Android 15 Permission Required'),
//             content: const Text(
//               'For daily reminders to work on Android 15, you need to:\n\n'
//               '1. Tap "Open Settings"\n'
//               '2. Look for "Alarms & reminders" or "Schedule exact alarms"\n'
//               '3. Enable this permission\n'
//               '4. Also check "Notifications" are enabled\n\n'
//               'Without this, reminders will not work properly.'
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   openAppSettings();
//                   Navigator.of(ctx).pop();
//                 },
//                 child: const Text('Open Settings'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 child: const Text('I\'ll Check Later'),
//               ),
//             ],
//           ),
//         );
//       }
//
//       final bothGranted = notificationStatus.isGranted && alarmStatus.isGranted;
//       print('All permissions granted: $bothGranted');
//       return bothGranted;
//     }
//
//     return true; // iOS permissions are handled during initialization
//   }
// }
