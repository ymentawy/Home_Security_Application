import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'settings.dart';
import 'main.dart';

class AppDrawer extends StatefulWidget {
  final User? user;
  final Map<String, dynamic>? userProfile;

  const AppDrawer({super.key, this.user, this.userProfile});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = "User"; // Default name

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    if (widget.userProfile != null &&
        widget.userProfile!['first_name'] != null) {
      setState(() {
        userName =
            "${widget.userProfile!['first_name']} ${widget.userProfile!['last_name']}";
      });
    } else if (widget.user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = "${userDoc['first_name']} ${userDoc['last_name']}";
          });
        }
      } catch (e) {
        print("Error fetching user name: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity, // Ensures full width
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
                          builder: (context) =>
                              ProfilePage(userId: widget.user!.uid),
                        ),
                      );
                    }
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
                          builder: (context) => SettingsPage(
                            isDarkMode: homeState.isDarkMode,
                            onDarkModeChanged: homeState.toggleDarkMode,
                          ),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    _showLogoutConfirmation(context);
                  },
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
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
