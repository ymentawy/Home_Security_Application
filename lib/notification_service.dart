import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

// Update callback to include a tap handler
typedef NotificationCallback = void Function(
    String title, String body, VoidCallback onTap);

class NotificationService {
  // Singleton pattern
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  IOWebSocketChannel? _channel;
  bool _isListening = false;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final List<NotificationCallback> _callbacks = [];

  // Store navigation key
  static GlobalKey<NavigatorState>? navigatorKey;

  // Navigate to recordings page
  void _navigateToRecordings() {
    if (navigatorKey?.currentState != null) {
      navigatorKey!.currentState!.pushNamed('/recordings');
    }
  }

  void addNotificationListener(NotificationCallback callback) {
    _callbacks.add(callback);
  }

  void removeNotificationListener(NotificationCallback callback) {
    _callbacks.remove(callback);
  }

  /// Call once at app start to set up notification plugin
  Future<void> initPlugin() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'motion_detection',
          actions: [
            DarwinNotificationAction.plain(
              'view_recording',
              'View Recording',
              options: {
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
        ),
      ],
    );
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _navigateToRecordings();
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    const channel = AndroidNotificationChannel(
      'pi_notifications',
      'Pi Notifications',
      description: 'Alerts from your Raspberry Pi',
      importance: Importance.max,
    );
    final androidImpl =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(channel);

    print('🔔 Local notification plugin initialized');
  }

  /// Start listening to the Pi WebSocket server
  void enableNotifications(String wsUrl) {
    if (_isListening) {
      print('⚠️ Already listening for notifications');
      return;
    }
    try {
      print('🌐 Connecting to WebSocket: $wsUrl');
      _channel = IOWebSocketChannel.connect(wsUrl);
      _channel!.stream.listen(
        (message) {
          print('🌐 WS message received: $message');
          try {
            final data = json.decode(message);
            final title = data['title']?.toString() ?? 'No Title';
            final body = data['body']?.toString() ?? 'No Body';
            print('🔔 Parsed title="$title", body="$body"');
            _showNotification(title, body);
          } catch (e) {
            print('❌ Error parsing WS message: $e');
          }
        },
        onError: (err) {
          print('❌ WS error: $err');
          _isListening = false;
        },
        onDone: () {
          print('⚠️ WS connection closed');
          _isListening = false;
        },
      );
      _isListening = true;
    } catch (e) {
      print('❌ Failed to connect WebSocket: $e');
    }
  }

  /// Stop listening and close connection
  void disableNotifications() {
    if (!_isListening) {
      print('⚠️ Notifications already disabled');
      return;
    }
    _channel?.sink.close();
    _isListening = false;
    print('🌐 WebSocket connection closed by client');
  }

  Future<void> _showNotification(String title, String body) async {
    print('🏷️ Showing notification: title="$title", body="$body"');

    // Notify all listeners with tap handler
    for (final callback in _callbacks) {
      callback(title, body, _navigateToRecordings);
    }

    const androidDetails = AndroidNotificationDetails(
      'pi_notifications',
      'Pi Notifications',
      channelDescription: 'Alerts from your Raspberry Pi',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'view_recording',
          'View Recording',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    final iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'motion_detection',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        0,
        title,
        body,
        details,
        payload: 'recordings_page',
      );
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Handle notification tap in background
  if (NotificationService.navigatorKey?.currentState != null) {
    NotificationService.navigatorKey!.currentState!.pushNamed('/recordings');
  }
}
