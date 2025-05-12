// lib/settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart'; // ← add this
import 'change_password_page.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onDarkModeChanged;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _defaultPiIp = '10.40.47.58';

  late bool isDarkMode;
  bool isNotificationsEnabled = true;
  String language = "English";
  String piIp = _defaultPiIp;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late TextEditingController _ipController;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;

    // Initialize local notifications plugin
    NotificationService.instance.initPlugin();

    _requestNotificationPermission();
    _initializeNotifications();
    _loadNotificationPreference();
  }

  /// Request notification permission (Android 13+)
  void _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Initializes local notifications and sets up a channel
  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'notifications_channel',
      'App Notifications',
      description: 'This channel is used for app notifications.',
      importance: Importance.high,
    );

    final androidImpl =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(channel);
  }

  /// Shows a confirmation notification
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'notifications_channel',
      'App Notifications',
      channelDescription: 'This channel is used for general notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notifications Enabled',
      'You will now receive notifications.',
      notificationDetails,
    );
  }

  /// Loads saved preferences (notifications + Pi IP)
  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    final ip = prefs.getString('pi_ip') ?? _defaultPiIp;

    setState(() {
      isNotificationsEnabled = enabled;
      piIp = ip;
    });

    if (isNotificationsEnabled) {
      NotificationService.instance.enableNotifications('ws://$piIp:8765');
    } else {
      NotificationService.instance.disableNotifications();
    }
  }

  /// Saves only the notification preference
  Future<void> _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  /// Saves only the Pi IP address
  Future<void> _savePiIp(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pi_ip', value);
  }

  /// Handles Factory Reset
  void factoryReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Factory Reset"),
        content:
            const Text("This will reset all settings to default. Proceed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isDarkMode = false;
                isNotificationsEnabled = true;
                language = "English";
                piIp = _defaultPiIp;
              });
              widget.onDarkModeChanged(false);
              _saveNotificationPreference(true);
              _savePiIp(_defaultPiIp);
              NotificationService.instance
                  .enableNotifications('ws://$_defaultPiIp:8765');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Factory reset completed!")),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  /// Navigates to Change Password Page
  void navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              widget.onDarkModeChanged(value);
            },
          ),

          // Notification toggle
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: isNotificationsEnabled,
            onChanged: (value) async {
              setState(() {
                isNotificationsEnabled = value;
              });
              await _saveNotificationPreference(value);
              if (value) {
                await _showNotification();
                NotificationService.instance
                    .enableNotifications('ws://$piIp:8765');
              } else {
                NotificationService.instance.disableNotifications();
              }
            },
          ),

          // Pi IP address picker
          ListTile(
            leading: const Icon(Icons.device_hub),
            title: const Text('Pi IP Address'),
            subtitle: Text(piIp),
            onTap: () {
              _ipController = TextEditingController(text: piIp);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Set Pi IP Address'),
                  content: TextField(
                    controller: _ipController,
                    decoration:
                        const InputDecoration(hintText: 'e.g. 192.168.1.100'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final newIp = _ipController.text.trim();
                        if (newIp.isNotEmpty) {
                          _savePiIp(newIp);
                          setState(() => piIp = newIp);
                          if (isNotificationsEnabled) {
                            NotificationService.instance.disableNotifications();
                            NotificationService.instance
                                .enableNotifications('ws://$piIp:8765');
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            trailing: DropdownButton<String>(
              value: language,
              items: const ["English", "Spanish", "French"]
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  language = value!;
                });
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: navigateToChangePassword,
          ),

          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Factory Reset"),
            onTap: factoryReset,
          ),
        ],
      ),
    );
  }
}
