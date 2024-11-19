import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'change_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Use the generated options
  );
  runApp(HomeSecurityApp());
}

class HomeSecurityApp extends StatefulWidget {
  const HomeSecurityApp({super.key});

  @override
  State<HomeSecurityApp> createState() => _HomeSecurityAppState();
}

class _HomeSecurityAppState extends State<HomeSecurityApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Security System',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: LoginPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  String language = "English";

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
                // Assuming the parent widget has a method to toggle dark mode
                (context.findAncestorStateOfType<_HomeSecurityAppState>()!)
                    .setState(() {
                  context
                      .findAncestorStateOfType<_HomeSecurityAppState>()!
                      .isDarkMode = isDarkMode;
                });
              });
            },
            title: Text('Dark Mode'),
          ),
          SwitchListTile(
            value: isNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                isNotificationsEnabled = value;
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
