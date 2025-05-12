import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_service.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({super.key});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  List<Map<String, dynamic>> notifications = [];
  int unreadCount = 0;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    NotificationService.instance.addNotificationListener(_handleNotification);
  }

  @override
  void dispose() {
    NotificationService.instance
        .removeNotificationListener(_handleNotification);
    super.dispose();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notificationsJson = _prefs.getString('notifications') ?? '[]';
    setState(() {
      notifications = List<Map<String, dynamic>>.from(
        json.decode(notificationsJson).map((x) => Map<String, dynamic>.from(x)),
      );
      unreadCount = notifications.where((n) => !n['read']).length;
    });
  }

  Future<void> _saveNotifications() async {
    await _prefs.setString('notifications', json.encode(notifications));
  }

  void _handleNotification(String title, String body) {
    addNotification(title, body);
  }

  void addNotification(String title, String body) {
    setState(() {
      notifications.insert(0, {
        'title': title,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      });
      unreadCount++;
      _saveNotifications();
    });
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification['body']),
                    Text(
                      DateTime.parse(notification['timestamp']).toString(),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                leading: Icon(
                  Icons.notifications,
                  color: notification['read'] ? Colors.grey : Colors.blue,
                ),
                onTap: () {
                  setState(() {
                    if (!notification['read']) {
                      notification['read'] = true;
                      unreadCount--;
                      _saveNotifications();
                    }
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in notifications) {
                  notification['read'] = true;
                }
                unreadCount = 0;
                _saveNotifications();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Mark All as Read'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _showNotificationsDialog,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
