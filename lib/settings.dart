// lib/settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';
import 'change_password_page.dart';

class PiConfig {
  static const String defaultPiIp = '10.40.47.58';
  static const int defaultMainStreamPort = 8001;
  static const int defaultPtzStreamPort = 8000;
  static const int defaultNotificationsPort = 8765;
  static const String defaultRecordingsPath = '/yoloBT/records';
}

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

  // Pi Configuration
  String piIp = PiConfig.defaultPiIp;
  int mainStreamPort = PiConfig.defaultMainStreamPort;
  int ptzStreamPort = PiConfig.defaultPtzStreamPort;
  int notificationsPort = PiConfig.defaultNotificationsPort;
  String recordingsPath = PiConfig.defaultRecordingsPath;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late TextEditingController _ipController;
  late TextEditingController _mainPortController;
  late TextEditingController _ptzPortController;
  late TextEditingController _notifPortController;
  late TextEditingController _recordingsPathController;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
    NotificationService.instance.initPlugin();
    _requestNotificationPermission();
    _initializeNotifications();
    _loadAllPreferences();
  }

  Future<void> _loadAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      piIp = prefs.getString('pi_ip') ?? PiConfig.defaultPiIp;
      mainStreamPort =
          prefs.getInt('main_stream_port') ?? PiConfig.defaultMainStreamPort;
      ptzStreamPort =
          prefs.getInt('ptz_stream_port') ?? PiConfig.defaultPtzStreamPort;
      notificationsPort = prefs.getInt('notifications_port') ??
          PiConfig.defaultNotificationsPort;
      recordingsPath =
          prefs.getString('recordings_path') ?? PiConfig.defaultRecordingsPath;
    });

    if (isNotificationsEnabled) {
      NotificationService.instance
          .enableNotifications('ws://$piIp:$notificationsPort');
    }
  }

  Future<void> _saveAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pi_ip', piIp);
    await prefs.setInt('main_stream_port', mainStreamPort);
    await prefs.setInt('ptz_stream_port', ptzStreamPort);
    await prefs.setInt('notifications_port', notificationsPort);
    await prefs.setString('recordings_path', recordingsPath);
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
                piIp = PiConfig.defaultPiIp;
                mainStreamPort = PiConfig.defaultMainStreamPort;
                ptzStreamPort = PiConfig.defaultPtzStreamPort;
                notificationsPort = PiConfig.defaultNotificationsPort;
                recordingsPath = PiConfig.defaultRecordingsPath;
              });
              widget.onDarkModeChanged(false);
              _saveAllPreferences();
              NotificationService.instance
                  .enableNotifications('ws://$piIp:$notificationsPort');
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

  void _showPiConfigDialog() {
    _ipController = TextEditingController(text: piIp);
    _mainPortController =
        TextEditingController(text: mainStreamPort.toString());
    _ptzPortController = TextEditingController(text: ptzStreamPort.toString());
    _notifPortController =
        TextEditingController(text: notificationsPort.toString());
    _recordingsPathController = TextEditingController(text: recordingsPath);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raspberry Pi Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(labelText: 'IP Address'),
              ),
              TextField(
                controller: _mainPortController,
                decoration:
                    const InputDecoration(labelText: 'Main Stream Port'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _ptzPortController,
                decoration: const InputDecoration(labelText: 'PTZ Stream Port'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _notifPortController,
                decoration:
                    const InputDecoration(labelText: 'Notifications Port'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _recordingsPathController,
                decoration: const InputDecoration(labelText: 'Recordings Path'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                piIp = _ipController.text.trim();
                mainStreamPort = int.tryParse(_mainPortController.text) ??
                    PiConfig.defaultMainStreamPort;
                ptzStreamPort = int.tryParse(_ptzPortController.text) ??
                    PiConfig.defaultPtzStreamPort;
                notificationsPort = int.tryParse(_notifPortController.text) ??
                    PiConfig.defaultNotificationsPort;
                recordingsPath = _recordingsPathController.text.trim();
              });
              _saveAllPreferences();
              if (isNotificationsEnabled) {
                NotificationService.instance.disableNotifications();
                NotificationService.instance
                    .enableNotifications('ws://$piIp:$notificationsPort');
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
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

          const Divider(),

          // Pi Configuration Section
          const ListTile(
            title: Text('Raspberry Pi Configuration',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.settings_remote),
            title: const Text('Pi Configuration'),
            subtitle: Text(
                'IP: $piIp\nPorts: $mainStreamPort, $ptzStreamPort, $notificationsPort'),
            onTap: _showPiConfigDialog,
          ),

          const Divider(),

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
                    .enableNotifications('ws://$piIp:$notificationsPort');
              } else {
                NotificationService.instance.disableNotifications();
              }
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
            title: const Text('Factory Reset'),
            onTap: factoryReset,
          ),
        ],
      ),
    );
  }
}
