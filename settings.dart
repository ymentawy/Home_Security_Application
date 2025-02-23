import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late bool isDarkMode;
  bool isNotificationsEnabled = true;
  String language = "English";

  // Notification plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
    _initializeNotifications();
    _loadNotificationPreference(); // Load saved notification state
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'notifications_channel', // Channel ID
      'App Notifications', // Channel Name
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Notifications Enabled', // Title
      'You will now receive notifications.', // Body
      notificationDetails,
    );
  }

  Future<void> _loadNotificationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  void factoryReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Factory Reset"),
        content: Text("This will reset all settings to default. Proceed?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isDarkMode = false;
                isNotificationsEnabled = true;
                language = "English";
              });
              widget.onDarkModeChanged(false);
              _saveNotificationPreference(true); // Reset notification preference
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Factory reset completed!")),
              );
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              widget.onDarkModeChanged(value);
            },
            title: Text('Dark Mode'),
          ),
          SwitchListTile(
            value: isNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                isNotificationsEnabled = value;
                _saveNotificationPreference(value); // Save new state
                if (value) {
                  _showNotification(); // Show notification when enabled
                }
              });
            },
            title: Text('Enable Notifications'),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text("Language"),
            trailing: DropdownButton<String>(
              value: language,
              items: ["English", "Spanish", "French"]
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
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
            onTap: navigateToChangePassword,
          ),
          ListTile(
            leading: Icon(Icons.restore),
            title: Text("Factory Reset"),
            onTap: factoryReset,
          ),
        ],
      ),
    );
  }
}
