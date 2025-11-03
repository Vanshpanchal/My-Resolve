import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'dart:developer' as developer;
import 'awesome_snackbar_helper.dart';
import '../firebase_options.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static String? _token;
  static bool _isInitialized = false;
  
  // Private constructor to prevent instantiation
  FirebaseNotificationService._();

  // Getters for accessing private members
  static bool get isInitialized => _isInitialized;
  static String? get currentToken => _token;
  static FirebaseMessaging get messaging => _messaging;

  // Initialize Firebase and request permissions
  static Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('Firebase already initialized', name: 'FirebaseService');
      return;
    }
    
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      developer.log('Firebase initialized successfully', name: 'FirebaseService');

      // Initialize timezone data
      tz.initializeTimeZones();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permissions
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('Notification permission status: ${settings.authorizationStatus}', name: 'FirebaseService');

      // Get FCM token with retries. Sometimes Firebase services take a moment
      // to become available (emulators without Play Services or bad config
      // can cause MISSING_INSTANCE errors). We'll attempt a few times and
      // continue gracefully if token cannot be obtained.
      const int maxAttempts = 3;
      int attempt = 0;
      while (attempt < maxAttempts) {
        attempt++;
        try {
          _token = await _messaging.getToken();
          if (_token != null && _token!.isNotEmpty) {
            developer.log('FCM Token obtained: ${_token!.substring(0, 20)}...', name: 'FirebaseService');
            break;
          } else {
            developer.log('Attempt $attempt: FCM token is null/empty', name: 'FirebaseService');
          }
        } catch (e, st) {
          // Log detailed error for diagnosis. If it's the known MISSING_INSTANCE
          // error, provide actionable guidance in the log message.
          final msg = e.toString();
          developer.log('Attempt $attempt: Error getting FCM token: $msg', name: 'FirebaseService', error: e, stackTrace: st);
          if (msg.contains('MISSING_INSTANCE') || msg.contains('MISSING_INSTANCEID') || msg.contains('MISSING_INSTANCE_ID')) {
            developer.log('MISSING_INSTANCE error detected — check google-services.json, applicationId, and device Play Services', name: 'FirebaseService');
          }
        }

        // Short backoff before retrying
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(seconds: 2 * 1));
        }
      }
      if (_token == null) {
        developer.log('Failed to obtain FCM token after $maxAttempts attempts — continuing without token', name: 'FirebaseService');
      }

      // Set up message handlers
      _setupMessageHandlers();

      // Subscribe to daily reminder topic
      await _messaging.subscribeToTopic('daily_reminders');
      developer.log('Subscribed to daily_reminders topic', name: 'FirebaseService');
      
      _isInitialized = true;

    } catch (e, stackTrace) {
      developer.log(
        'Error initializing Firebase notifications', 
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Set up message handlers for different app states
  static void _setupMessageHandlers() {
    // Handle message when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Received foreground message: ${message.messageId}', name: 'FirebaseService');
      developer.log('Message data: ${message.data}', name: 'FirebaseService');

      if (message.notification != null) {
        developer.log('Message notification: ${message.notification!.title}', name: 'FirebaseService');
        _showInAppNotification(message);
      }
    });

    // Handle message when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('App opened from notification: ${message.messageId}', name: 'FirebaseService');
      developer.log('Message data: ${message.data}', name: 'FirebaseService');
      _handleMessageNavigation(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        developer.log('Local notification tapped: ${response.payload}', name: 'FirebaseService');
        // Handle notification tap
        _handleNotificationTap(response.payload);
      },
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  // Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Create default notification channel
      const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
        'default_notification_channel',
        'Default Notifications',
        description: 'Default notification channel for the app',
        importance: Importance.high,
      );

      // Create daily reminder notification channel
      const AndroidNotificationChannel dailyReminderChannel = AndroidNotificationChannel(
        'daily_reminder_channel',
        'Daily Reminders',
        description: 'Daily reminder notifications',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await androidImplementation.createNotificationChannel(defaultChannel);
      await androidImplementation.createNotificationChannel(dailyReminderChannel);
      
      developer.log('Notification channels created successfully', name: 'FirebaseService');
    }
  }

  // Show in-app notification when app is in foreground
  static Future<void> _showInAppNotification(RemoteMessage message) async {
    developer.log(
      'Showing foreground notification: ${message.notification?.title}', 
      name: 'FirebaseService'
    );
    
    if (message.notification != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'default_notification_channel',
        'Default Notifications',
        channelDescription: 'Default notification channel for the app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(String? payload) {
    developer.log('Notification tapped with payload: $payload', name: 'FirebaseService');
    // TODO: Implement navigation based on payload
  }

  // Handle message navigation
  static void _handleMessageNavigation(RemoteMessage message) {
    developer.log('Handling navigation for message: ${message.data}', name: 'FirebaseService');
    
    // TODO: Implement navigation logic based on message data
    // Example:
    // final screen = message.data['screen'];
    // if (screen != null) {
    //   NavigationService.navigateTo(screen);
    // }
  }

  // Get FCM token
  static Future<String?> getToken() async {
    if (!_isInitialized) {
      developer.log('Firebase not initialized, initializing now...', name: 'FirebaseService');
      await initialize();
    }
    
    try {
      _token = await _messaging.getToken();
      if (_token != null) {
        developer.log('FCM token retrieved successfully', name: 'FirebaseService');
      }
      return _token;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting FCM token',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // Schedule daily reminder (using both local notifications and FCM)
  static Future<void> scheduleDailyReminder(int hour, int minute, {BuildContext? context}) async {
    // Validate input
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Invalid time: hour must be 0-23, minute must be 0-59');
    }
    
    try {
      developer.log('Scheduling daily reminder for $hour:${minute.toString().padLeft(2, '0')}', name: 'FirebaseService');
      
      // Save reminder time locally
      final box = await Hive.openBox('reminderBox');
      await box.put('reminder', {
        'hour': hour, 
        'minute': minute,
        'enabled': true,
        'lastScheduled': DateTime.now().toIso8601String(),
      });
      
      // Schedule local daily notifications
      await _scheduleLocalDailyReminder(hour, minute);
      
      // Get FCM token for logging
      final token = await getToken();
      
      if (token != null) {
        developer.log('Daily reminder scheduled successfully', name: 'FirebaseService');
        developer.log('FCM Token: ${token.substring(0, 20)}...', name: 'FirebaseService');
        
        // Show success message
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Daily reminder set for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Failed to obtain FCM token');
      }
      
    } catch (e, stackTrace) {
      developer.log(
        'Error scheduling daily reminder',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error scheduling reminder: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    }
  }

  // Test immediate notification (using Firebase Cloud Functions)
  static Future<void> showImmediateNotification() async {
    try {
      final token = await getToken();
      if (token != null) {
        developer.log('Immediate notification requested', name: 'FirebaseService');
        developer.log('FCM Token: ${token.substring(0, 20)}...', name: 'FirebaseService');
        
        // Show a test local notification to verify the system works
        await _showTestLocalNotification();
        
        // TODO: Call your server endpoint to send immediate notification
        // await _sendImmediateNotification(token);
        
        developer.log(
          'Test local notification shown. For FCM test: Send from Firebase Console', 
          name: 'FirebaseService'
        );
      } else {
        throw Exception('Failed to obtain FCM token for immediate notification');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error requesting immediate notification',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Show test local notification
  static Future<void> _showTestLocalNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_notification_channel',
      'Default Notifications',
      channelDescription: 'Default notification channel for the app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      12345, // Unique ID for test notification
      '🔥 Firebase Test',
      'Local notifications are working! Now test FCM from Firebase Console.',
      platformChannelSpecifics,
      payload: 'test_notification',
    );
  }

  // Test scheduled local notification (shows in 5 seconds)
  static Future<void> testScheduledLocalNotification({BuildContext? context}) async {
    try {
      // Ensure timezone data is initialized
      tz.initializeTimeZones();
      
      // Get the local timezone location with fallback
      tz.Location location;
      final String timeZoneName = DateTime.now().timeZoneName;
      
      try {
        location = tz.getLocation(timeZoneName);
      } catch (e) {
        developer.log('Failed to get timezone "$timeZoneName", using UTC offset fallback', name: 'FirebaseService');
        // Fallback: detect timezone by UTC offset
        final int offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
        final int offsetHours = offsetMinutes ~/ 60;
        final String offsetString = offsetHours >= 0 ? '+$offsetHours' : '$offsetHours';
        
        // For IST (UTC+5:30), try common timezone names
        if (offsetMinutes == 330) { // UTC+5:30
          try {
            location = tz.getLocation('Asia/Kolkata');
          } catch (e2) {
            location = tz.UTC; // Final fallback
          }
        } else {
          location = tz.UTC; // Fallback to UTC
        }
      }
      
      developer.log('Device timezone: $timeZoneName (offset: ${DateTime.now().timeZoneOffset})', name: 'FirebaseService');
      developer.log('Using timezone location: ${location.name}', name: 'FirebaseService');
      
      // Schedule notification for 5 seconds from now using proper timezone
      final tz.TZDateTime now = tz.TZDateTime.now(location);
      final tz.TZDateTime tzScheduledTime = now.add(const Duration(seconds: 5));
      
      developer.log('Current local time: $now', name: 'FirebaseService');
      developer.log('Scheduling test notification for: $tzScheduledTime', name: 'FirebaseService');
      developer.log('Time difference: ${tzScheduledTime.difference(now).inSeconds} seconds', name: 'FirebaseService');
      
      await _localNotifications.zonedSchedule(
        99999, // Unique ID for test scheduled notification
        '⏰ Test Scheduled Notification',
        'This notification was scheduled 5 seconds ago. Local notifications are working!',
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Daily reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'test_scheduled_notification',
      );
      
      // Also show an immediate notification to test if notifications work at all
      await _localNotifications.show(
        88888, // Unique ID for immediate test
        '🔔 Immediate Test',
        'This should show right now. If you see this, notifications work!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Daily reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'immediate_test_notification',
      );
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📅 Scheduled in 5s + immediate test shown. Check if you see the immediate notification!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 6),
          ),
        );
      }
      
      developer.log('Test scheduled notification set successfully', name: 'FirebaseService');
      
    } catch (e, stackTrace) {
      developer.log(
        'Error scheduling test notification',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error scheduling test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get notification permissions status
  static Future<Map<String, bool>> checkPermissions() async {
    final Map<String, bool> permissions = {};
    
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final NotificationSettings settings = await _messaging.getNotificationSettings();
      
      permissions['notifications'] = settings.authorizationStatus == AuthorizationStatus.authorized;
      permissions['firebase_initialized'] = Firebase.apps.isNotEmpty;
      
      final token = await getToken();
      permissions['fcm_token_available'] = token != null;
      
      developer.log('Permissions checked successfully', name: 'FirebaseService');
      
    } catch (e, stackTrace) {
      developer.log(
        'Error checking permissions',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      permissions['error'] = true;
    }
    
    return permissions;
  }

  // Request all necessary permissions
  static Future<bool> requestAllPermissions(BuildContext? context) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Request Firebase messaging permissions
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Request local notification permissions for Android
      bool localPermissionGranted = true;
      if (Platform.isAndroid) {
        final androidImplementation = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidImplementation != null) {
          localPermissionGranted = await androidImplementation.requestNotificationsPermission() ?? false;
          
          // Request exact alarm permission for scheduled notifications
          final exactAlarmPermission = await androidImplementation.requestExactAlarmsPermission();
          developer.log('Exact alarm permission: $exactAlarmPermission', name: 'FirebaseService');
        }
      }

      final fcmGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
      final allGranted = fcmGranted && localPermissionGranted;
      
      developer.log(
        'Permission request result - FCM: $fcmGranted, Local: $localPermissionGranted', 
        name: 'FirebaseService'
      );
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(allGranted 
              ? '✅ All notification permissions granted!'
              : '❌ Some notification permissions missing'),
            backgroundColor: allGranted ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      return allGranted;
    } catch (e, stackTrace) {
      developer.log(
        'Error requesting permissions',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error requesting permissions'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // Test immediate notification to check if basic notifications work
  static Future<void> testImmediateNotification({BuildContext? context}) async {
    try {
      await _localNotifications.show(
        77777, // Unique ID for immediate test
        '🚨 Immediate Notification Test',
        'If you see this, basic notifications work! The issue might be with scheduled notifications.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Daily reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'immediate_test',
      );
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📢 Immediate notification sent! Did you see it?'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      developer.log('Immediate test notification sent', name: 'FirebaseService');
      
    } catch (e, stackTrace) {
      developer.log(
        'Error sending immediate notification',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Run comprehensive diagnostics
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final diagnostics = <String, dynamic>{};
    
    try {
      developer.log('Running Firebase diagnostics...', name: 'FirebaseService');
      
      // Check Firebase initialization
      diagnostics['firebase_initialized'] = Firebase.apps.isNotEmpty && _isInitialized;
      
      // Check permissions
      final permissions = await checkPermissions();
      diagnostics['permissions'] = permissions;
      
      // Check FCM token
      final token = await getToken();
      diagnostics['fcm_token'] = token != null ? 'Available (${token.substring(0, 20)}...)' : 'Not available';
      
      // Check notification settings
      final NotificationSettings settings = await _messaging.getNotificationSettings();
      diagnostics['notification_settings'] = {
        'authorization_status': settings.authorizationStatus.name,
        'alert_setting': settings.alert.name,
        'badge_setting': settings.badge.name,
        'sound_setting': settings.sound.name,
      };
      
      // Platform and environment info
      diagnostics['platform'] = Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Other';
      diagnostics['current_time'] = DateTime.now().toIso8601String();
      diagnostics['timezone'] = DateTime.now().timeZoneName;
      
      // App state
      diagnostics['app_state'] = 'Active'; // Could be enhanced with actual app state
      
      developer.log('Firebase diagnostics completed successfully', name: 'FirebaseService');
      
    } catch (e, stackTrace) {
      diagnostics['error'] = e.toString();
      developer.log(
        'Error running Firebase diagnostics',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
    }
    
    return diagnostics;
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    if (topic.isEmpty) {
      throw ArgumentError('Topic name cannot be empty');
    }
    
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      await _messaging.subscribeToTopic(topic);
      developer.log('Subscribed to topic: $topic', name: 'FirebaseService');
    } catch (e, stackTrace) {
      developer.log(
        'Error subscribing to topic: $topic',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    if (topic.isEmpty) {
      throw ArgumentError('Topic name cannot be empty');
    }
    
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      await _messaging.unsubscribeFromTopic(topic);
      developer.log('Unsubscribed from topic: $topic', name: 'FirebaseService');
    } catch (e, stackTrace) {
      developer.log(
        'Error unsubscribing from topic: $topic',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Schedule local daily reminder as backup
  static Future<void> _scheduleLocalDailyReminder(int hour, int minute) async {
    try {
      // Ensure timezone data is initialized
      tz.initializeTimeZones();
      
      // Cancel any existing daily reminders
      await _localNotifications.cancelAll();
      
      // Get the local timezone location with fallback
      tz.Location location;
      final String timeZoneName = DateTime.now().timeZoneName;
      
      try {
        location = tz.getLocation(timeZoneName);
      } catch (e) {
        developer.log('Failed to get timezone "$timeZoneName", using UTC offset fallback', name: 'FirebaseService');
        // Fallback: detect timezone by UTC offset
        final int offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
        
        // For IST (UTC+5:30), use Asia/Kolkata
        if (offsetMinutes == 330) { // UTC+5:30
          try {
            location = tz.getLocation('Asia/Kolkata');
          } catch (e2) {
            location = tz.UTC; // Final fallback
          }
        } else {
          location = tz.UTC; // Fallback to UTC
        }
      }
      
      // Calculate next reminder time using proper timezone
      final tz.TZDateTime now = tz.TZDateTime.now(location);
      var scheduledDate = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
      
      // If the time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      developer.log('Device timezone: $timeZoneName', name: 'FirebaseService');
      developer.log('Current time: $now', name: 'FirebaseService');
      developer.log('Scheduling local daily reminder for: $scheduledDate', name: 'FirebaseService');
      developer.log('Time until notification: ${scheduledDate.difference(now)}', name: 'FirebaseService');
      
      // Schedule the notification
      await _localNotifications.zonedSchedule(
        0, // Notification ID
        '⏰ Daily Reminder',
        'Time for your daily check-in! Stay committed to your goals.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Daily reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
        payload: 'daily_reminder',
      );
      
      developer.log('Local daily reminder scheduled successfully', name: 'FirebaseService');
    } catch (e, stackTrace) {
      developer.log(
        'Error scheduling local daily reminder',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Cancel daily reminder
  static Future<void> cancelDailyReminder({BuildContext? context}) async {
    try {
      // Cancel local notifications
      await _localNotifications.cancelAll();
      
      // Remove from local storage
      final box = await Hive.openBox('reminderBox');
      await box.put('reminder', {'enabled': false});
      
      developer.log('Daily reminder cancelled', name: 'FirebaseService');
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚫 Daily reminder cancelled'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error cancelling daily reminder',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Get current reminder settings
  static Future<Map<String, dynamic>?> getCurrentReminder() async {
    try {
      final box = await Hive.openBox('reminderBox');
      final reminder = box.get('reminder');
      return reminder is Map ? Map<String, dynamic>.from(reminder) : null;
    } catch (e) {
      developer.log('Error getting current reminder', name: 'FirebaseService', error: e);
      return null;
    }
  }
}

// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    developer.log(
      'Background message received: ${message.messageId}',
      name: 'FirebaseBackgroundHandler'
    );
    developer.log('Message data: ${message.data}', name: 'FirebaseBackgroundHandler');
    
    if (message.notification != null) {
      developer.log(
        'Notification: ${message.notification!.title}',
        name: 'FirebaseBackgroundHandler'
      );
    }
    
    // TODO: Handle background message processing
    // Example: Update local database, show local notification, etc.
    
  } catch (e, stackTrace) {
    developer.log(
      'Error handling background message',
      name: 'FirebaseBackgroundHandler',
      error: e,
      stackTrace: stackTrace,
    );
  }
}