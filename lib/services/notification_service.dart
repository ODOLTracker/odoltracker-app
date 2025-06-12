import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class NotificationService {
  static const String baseUrl = 'https://api.odltracker.my.id/v1';
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  Timer? _pollingTimer;
  int? _currentUserId;
  DateTime? _lastNotificationCheck;
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped with payload: ${response.payload}');
      },
    );
  }

  void startNotificationPolling(int userId) {
    _currentUserId = userId;
    _lastNotificationCheck = DateTime.now();
    
    // Cancel existing timer if any
    _pollingTimer?.cancel();
    
    // Check immediately
    _checkNewNotifications();
    
    // Then start periodic checking every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNewNotifications();
    });
  }

  void stopNotificationPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentUserId = null;
  }

  Future<void> _checkNewNotifications() async {
    if (_currentUserId == null) return;

    try {
      final url = Uri.parse('$baseUrl/notification/user/$_currentUserId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> notifications = data['notifications'] ?? [];
        
        // Filter and show only unread notifications
        final unreadNotifications = notifications.where((notification) => 
          notification['status'] == 'Unread' &&
          DateTime.parse(notification['timestamp']).isAfter(_lastNotificationCheck ?? DateTime.now())
        );
        
        for (var notification in unreadNotifications) {
          await showNotification(
            title: 'ODOLTracker Notification',
            body: notification['message'] ?? '',
            payload: json.encode({
              'id': notification['id'],
              'userID': notification['userID'],
              'message': notification['message'],
              'timestamp': notification['timestamp']
            }),
          );
        }
        
        _lastNotificationCheck = DateTime.now();
      }
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'odol_tracker_channel',
      'Odol Tracker Notifications',
      channelDescription: 'Channel for Odol Tracker app notifications',
      importance: Importance.max,
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

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 2147483647,  // Unique ID for each notification
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Create a new notification
  static Future<http.Response> createNotification({
    required String userID,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/notification');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userID': userID,
        'message': message,
      }),
    );
    return response;
  }

  // Get all notifications (admin only)
  static Future<http.Response> getNotifications({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/notification?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get notification by ID (admin only)
  static Future<http.Response> getNotification(String id) async {
    final url = Uri.parse('$baseUrl/notification/$id');
    final response = await http.get(url);
    return response;
  }

  // Update notification by ID (admin only)
  static Future<http.Response> updateNotification({
    required String id,
    required String message,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/notification/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'status': status,
      }),
    );
    return response;
  }

  // Delete notification by ID (admin only)
  static Future<http.Response> deleteNotification(String id) async {
    final url = Uri.parse('$baseUrl/notification/$id');
    final response = await http.delete(url);
    return response;
  }

  // Get all notifications of a user
  static Future<http.Response> getUserNotifications(int userID, {int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/notification/user/$userID?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get all unread notifications of a user
  static Future<http.Response> getUnreadUserNotifications(int userID) async {
    final url = Uri.parse('$baseUrl/notification/user/$userID/unread');
    final response = await http.get(url);
    return response;
  }

  // Mark all notifications of a user as read
  static Future<http.Response> markAllNotificationsAsRead(int userID) async {
    final url = Uri.parse('$baseUrl/notification/user/$userID/mark-all-as-read');
    final response = await http.put(url);
    return response;
  }

  // Mark a specific notification of a user as read
  static Future<http.Response> readNotification(int userID, String notificationID) async {
    final url = Uri.parse('$baseUrl/notification/user/$userID/read/$notificationID');
    final response = await http.put(url);
    return response;
  }

  // Delete a specific notification of a user
  static Future<http.Response> deleteUserNotification(int userID, String notificationID) async {
    final url = Uri.parse('$baseUrl/notification/user/$userID/delete/$notificationID');
    final response = await http.delete(url);
    return response;
  }

  // Get the count of unread notifications of a user
  static Future<http.Response> getUnreadUserNotificationsCount(int userID) async {
    final url = Uri.parse('$baseUrl/notification/user/$userID/unread/count');
    final response = await http.get(url);
    return response;
  }

  // Handle notification from API
  Future<void> handleApiNotification(Map<String, dynamic> notificationData) async {
    await showNotification(
      title: notificationData['title'] ?? 'New Notification',
      body: notificationData['message'] ?? '',
      payload: notificationData['payload'],
    );
  }

  // Process incoming notification data
  Future<void> processNotification(String notificationJson) async {
    try {
      final Map<String, dynamic> notificationData = json.decode(notificationJson);
      await handleApiNotification(notificationData);
    } catch (e) {
      print('Error processing notification: $e');
    }
  }
}