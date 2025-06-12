import 'package:flutter/material.dart';
import 'dart:convert'; // For decoding JSON
import 'package:intl/intl.dart'; // Import DateFormat from intl package
import '../services/notification_service.dart'; // Import NotificationService for API

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = []; // To hold notifications
  final int _userID = 1; // Placeholder for userID. Replace with the current logged-in user ID
  int unreadCount = 0; // To store the unread notifications count

  @override
  void initState() {
    super.initState();
    _loadUserNotifications();
    _fetchUnreadNotificationsCount();
  }

  // Load notifications from API
  _loadUserNotifications() async {
    final response = await NotificationService.getUserNotifications(_userID, page: 1, limit: 10);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _notifications = data['notifications']; // Store the notifications
        _isLoading = false; // Stop loading
      });
    } else {
      setState(() {
        _isLoading = false; // Stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load notifications')));
    }
  }

  // Fetch unread notifications count
  _fetchUnreadNotificationsCount() async {
    final response = await NotificationService.getUnreadUserNotificationsCount(_userID);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        unreadCount = data['count']; // Update unread notifications count
      });
    }
  }

  // Mark notification as read
  _markAsRead(int notificationId) async {
    final response = await NotificationService.readNotification(_userID, notificationId.toString());
    if (response.statusCode == 200) {
      setState(() {
        _notifications.firstWhere((notification) => notification['id'] == notificationId)['status'] = 'Read';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification marked as read')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to mark notification as read')));
    }
  }

  // Handle the "Mark All as Read" button
  _markAllAsRead() async {
    final response = await NotificationService.markAllNotificationsAsRead(_userID);
    if (response.statusCode == 200) {
      setState(() {
        for (var notification in _notifications) {
          notification['status'] = 'Read';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to mark all notifications as read')));
    }
  }

  // Convert ISO8601 timestamp to a readable date
  String _formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    dateTime = dateTime.toLocal();
    return DateFormat('MMM dd, yyyy, HH:mm').format(dateTime); // You can adjust the format here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'mark_all_read_button',
        onPressed: _markAllAsRead,
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  // Build notification card
  Widget _buildNotificationCard(notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: notification['status'] == 'Unread' ? Colors.blue[50] : Colors.grey[200], // Highlight unread notifications
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: Text(
          notification['message'],
          style: TextStyle(
            fontWeight: notification['status'] == 'Unread' ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
        subtitle: Text(_formatTimestamp(notification['timestamp'])), // Format the timestamp here
        trailing: notification['status'] == 'Unread'
            ? IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => _markAsRead(notification['id']),
              )
            : null,
      ),
    );
  }
}