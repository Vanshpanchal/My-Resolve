import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;
  final _storage = const FlutterSecureStorage();

  List<NotificationItem> get notifications => _notifications;
  List<NotificationItem> get allNotifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with sample data (replace with API call)
  void initializeNotifications() {
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'New Check-in Pending!',
        subtitle: 'Review and vote on [Name]\'s daily update.',
        icon: Icons.pending_actions,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange.withOpacity(0.1),
        time: '2 min ago',
        hasAction: true,
        actionText: 'Review',
        actionColor: const Color(0xFF4A90E2),
        type: NotificationType.checkInPending,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'We All Showed Up!',
        subtitle: 'Another perfect day. The streak is unstoppable.',
        icon: Icons.check_circle,
        iconColor: Colors.green,
        backgroundColor: Colors.green.withOpacity(0.1),
        time: 'Yesterday',
        hasAction: false,
        type: NotificationType.streakSuccess,
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        title: 'Your Streak Is At Risk!',
        subtitle: 'Don\'t let your hard work go to waste — lock in today!',
        icon: Icons.warning,
        iconColor: Colors.red,
        backgroundColor: Colors.red.withOpacity(0.1),
        time: '3 days ago',
        hasAction: true,
        actionText: 'Check - In',
        actionColor: const Color(0xFF4A90E2),
        type: NotificationType.streakWarning,
        isRead: false,
      ),
    ];
    notifyListeners();
  }

  // Add a new notification
  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      // Also mark as read on the server
      _markAsReadOnServer(notificationId);
    }
  }

  // Mark notification as read on server
  Future<void> _markAsReadOnServer(String notificationId) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return;

      final url = Uri.parse(ApiEndpoints.baseUrl + '${ApiEndpoints.notifications}/$notificationId/mark-read');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      // Silently fail - the local state is already updated
      if (kDebugMode) {
        print('Failed to mark notification as read on server: $e');
      }
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  // Remove notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Undo mark as read (for swipe undo functionality)
  void undoMarkAsRead(NotificationItem notification) {
    // Check if notification still exists in the list
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      // Update existing notification to unread
      _notifications[index] = _notifications[index].copyWith(isRead: false);
    } else {
      // Add the notification back to the beginning of the list as unread
      final unreadNotification = notification.copyWith(isRead: false);
      _notifications.insert(0, unreadNotification);
    }
    notifyListeners();
    
    // Also mark as unread on server
    _markAsUnreadOnServer(notification.id);
  }

  // Mark notification as unread on server
  Future<void> _markAsUnreadOnServer(String notificationId) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return;

      final url = Uri.parse(ApiEndpoints.baseUrl + '${ApiEndpoints.notifications}/$notificationId/mark-unread');
      await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      // Silently fail - the local state is already updated
      if (kDebugMode) {
        print('Failed to mark notification as unread on server: $e');
      }
    }
  }

  // Get unread notification count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Fetch notifications from API
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.notifications);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(response.body);
        final List<dynamic> notificationsData = responseData['notifications'] ?? responseData['data'] ?? [];
        
        _notifications = notificationsData.map((notificationJson) {
          return _parseNotificationFromApi(notificationJson);
        }).toList();
        
        _error = null;
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      // Fallback to sample data if API fails
      if (kDebugMode) {
        initializeNotifications();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Parse notification data from API response
  NotificationItem _parseNotificationFromApi(Map<String, dynamic> json) {
    // Map notification types from API to local types
    NotificationType type = NotificationType.reminder;
    IconData icon = Icons.notifications;
    Color iconColor = Colors.blue;
    Color backgroundColor = Colors.blue.withOpacity(0.1);
    bool hasAction = false;
    String? actionText;
    Color? actionColor;

    final String notificationType = json['type']?.toString().toLowerCase() ?? '';
    final String message = json['message']?.toString() ?? json['subtitle']?.toString() ?? '';
    final String title = json['title']?.toString() ?? '';
    
    // Check if message or title contains "Gemini AI"
    final bool isAIRelated = message.toLowerCase().contains('gemini ai') || 
                            title.toLowerCase().contains('gemini ai');
    
    switch (notificationType) {
      case 'checkin_pending':
      case 'check_in_pending':
        type = NotificationType.checkInPending;
        if (isAIRelated) {
          icon = Icons.auto_awesome; // AI sparkle icon
          iconColor = Colors.purple;
          backgroundColor = Colors.purple.withOpacity(0.1);
        } else {
          icon = Icons.pending_actions;
          iconColor = Colors.orange;
          backgroundColor = Colors.orange.withOpacity(0.1);
        }
        hasAction = true;
        actionText = 'Review';
        actionColor = const Color(0xFF4A90E2);
        break;
      case 'streak_success':
        type = NotificationType.streakSuccess;
        if (isAIRelated) {
          icon = Icons.auto_awesome; // AI sparkle icon
          iconColor = Colors.purple;
          backgroundColor = Colors.purple.withOpacity(0.1);
        } else {
          icon = Icons.check_circle;
          iconColor = Colors.green;
          backgroundColor = Colors.green.withOpacity(0.1);
        }
        break;
      case 'streak_warning':
        type = NotificationType.streakWarning;
        if (isAIRelated) {
          icon = Icons.auto_awesome; // AI sparkle icon
          iconColor = Colors.purple;
          backgroundColor = Colors.purple.withOpacity(0.1);
        } else {
          icon = Icons.warning;
          iconColor = Colors.red;
          backgroundColor = Colors.red.withOpacity(0.1);
        }
        hasAction = true;
        actionText = 'Check - In';
        actionColor = const Color(0xFF4A90E2);
        break;
      case 'pact_invite':
        type = NotificationType.pactInvite;
        if (isAIRelated) {
          icon = Icons.auto_awesome; // AI sparkle icon
          iconColor = Colors.purple;
          backgroundColor = Colors.purple.withOpacity(0.1);
        } else {
          icon = Icons.group_add;
          iconColor = Colors.purple;
          backgroundColor = Colors.purple.withOpacity(0.1);
        }
        hasAction = true;
        actionText = 'View Invite';
        actionColor = const Color(0xFF4A90E2);
        break;
      case 'achievement':
        type = NotificationType.achievement;
        if (isAIRelated) {
          icon = Icons.auto_awesome; // AI sparkle icon
          iconColor = Colors.purple;
          backgroundColor = Colors.purple.withOpacity(0.1);
        } else {
          icon = Icons.star;
          iconColor = Colors.amber;
          backgroundColor = Colors.amber.withOpacity(0.1);
        }
        break;
      case 'checkin':
        type = NotificationType.checkInPending;
        if (isAIRelated) {
          icon = Icons.auto_awesome; // AI sparkle icon
          iconColor = Colors.purple;
          backgroundColor = Colors.purple.withOpacity(0.1);
        } else {
          icon = Icons.check_circle;
          iconColor = Colors.green;
          backgroundColor = Colors.green.withOpacity(0.1);
        }
        break;
      default:
        type = NotificationType.reminder;
        if (isAIRelated) {
          icon = Icons.auto_awesome; // AI sparkle icon
          iconColor = Colors.purple;
          backgroundColor = Colors.purple.withOpacity(0.1);
        } else {
          icon = Icons.notifications;
          iconColor = Colors.blue;
          backgroundColor = Colors.blue.withOpacity(0.1);
        }
        break;
    }

    return NotificationItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: title.isNotEmpty ? title : 'Notification',
      subtitle: message,
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      time: _formatTime(json['createdAt']?.toString() ?? json['timestamp']?.toString()),
      hasAction: hasAction,
      actionText: actionText,
      actionColor: actionColor,
      type: type,
      isRead: json['isRead'] == true || json['read'] == true,
      data: json['data'],
    );
  }

  // Format timestamp to relative time
  String _formatTime(String? timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      
      // Create date-only versions for accurate day comparison
      final DateTime dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final DateTime todayOnly = DateTime(now.year, now.month, now.day);
      final Duration dayDifference = todayOnly.difference(dateOnly);
      final int daysDiff = dayDifference.inDays;
      
      final Duration timeDifference = now.difference(dateTime);

      if (timeDifference.inMinutes < 1) {
        return 'Just now';
      } else if (timeDifference.inMinutes < 60) {
        return '${timeDifference.inMinutes} min ago';
      } else if (daysDiff == 0) {
        // Same day - show hours ago
        return '${timeDifference.inHours} hours ago';
      } else if (daysDiff == 1) {
        return 'Yesterday';
      } else if (daysDiff < 7) {
        return '$daysDiff days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}

enum NotificationType {
  checkInPending,
  streakSuccess,
  streakWarning,
  pactInvite,
  achievement,
  reminder,
}

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String time;
  final bool hasAction;
  final String? actionText;
  final Color? actionColor;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data; // Additional data for actions

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.time,
    this.hasAction = false,
    this.actionText,
    this.actionColor,
    required this.type,
    this.isRead = false,
    this.data,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    String? time,
    bool? hasAction,
    String? actionText,
    Color? actionColor,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      time: time ?? this.time,
      hasAction: hasAction ?? this.hasAction,
      actionText: actionText ?? this.actionText,
      actionColor: actionColor ?? this.actionColor,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}