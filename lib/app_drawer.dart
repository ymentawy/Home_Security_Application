import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'settings.dart';
import 'main.dart';
import 'recordings_page.dart';

class AppDrawer extends StatefulWidget {
  final User? user;
  final Map<String, dynamic>? userProfile;

  const AppDrawer({Key? key, this.user, this.userProfile}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = 'User';
  bool _notificationsEnabled = true;
  String _piIp = '192.168.1.100';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _loadPreferences();
  }

  Future<void> _fetchUserName() async {
    if (widget.userProfile != null &&
        widget.userProfile!['first_name'] != null) {
      setState(() {
        userName =
            '${widget.userProfile!['first_name']} ${widget.userProfile!['last_name']}';
      });
    } else if (widget.user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user!.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userName = '${userDoc['first_name']} ${userDoc['last_name']}';
          });
        }
      } catch (e) {
        print('Error fetching user name: $e');
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    final ip = prefs.getString('pi_ip') ?? '192.168.1.100';

    setState(() {
      _notificationsEnabled = enabled;
      _piIp = ip;
    });

    if (_notificationsEnabled) {
      NotificationService.instance.enableNotifications('ws://$_piIp:8765');
    }
  }

  void _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
    if (value) {
      NotificationService.instance.enableNotifications('ws://$_piIp:8765');
    } else {
      NotificationService.instance.disableNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 64, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    if (widget.user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(userId: widget.user!.uid),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Recordings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecordingsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    final homeState =
                        context.findAncestorStateOfType<HomeSecurityAppState>();
                    if (homeState != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                            isDarkMode: homeState.isDarkMode,
                            onDarkModeChanged: homeState.toggleDarkMode,
                          ),
                        ),
                      ).then((_) => _loadPreferences());
                    }
                  },
                ),
                ListTile(
                  leading: Icon(
                    _notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                  ),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
