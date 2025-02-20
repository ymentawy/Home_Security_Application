import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_drawer.dart';
import 'camera_stream.dart';

class HomePage extends StatelessWidget {
  final User? user;
  final Map<String, dynamic>? userProfile;

  const HomePage({super.key, required this.user, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NEUROVISION'),
      ),
      drawer: AppDrawer(
        user: user,
        userProfile: userProfile,
      ), // AppDrawer for navigation
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome, ${userProfile?['name'] ?? user?.email ?? "User"}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text("Select a Camera to View"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CameraStream(cameraId: 1)),
                  );
                },
                child: Text("Main Camera"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CameraStream(cameraId: 2, isPTZ: true)),
                  );
                },
                child: Text("PTZ Camera"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
