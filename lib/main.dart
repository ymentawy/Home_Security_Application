import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';

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
  State<HomeSecurityApp> createState() => HomeSecurityAppState();
}

class HomeSecurityAppState extends State<HomeSecurityApp> {
  bool isDarkMode = false;

  void toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

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
