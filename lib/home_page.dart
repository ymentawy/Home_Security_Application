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
      appBar: AppBar(title: const Text('NEUROVISION')),
      drawer: AppDrawer(user: user, userProfile: userProfile),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome, ${userProfile?['name'] ?? user?.email ?? "User"}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text("Select a Camera to View",
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),

              // Main Camera (OBS HLS)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraStream(cameraId: 1),
                    ),
                  );
                },
                child: const Text("Main Camera"),
              ),

              const SizedBox(height: 20),

              // PTZ Camera (OBS HLS)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CameraStream(cameraId: 2, isPTZ: true),
                    ),
                  );
                },
                child: const Text("PTZ Camera"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
