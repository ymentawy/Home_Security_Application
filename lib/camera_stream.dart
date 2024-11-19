import 'package:flutter/material.dart';

class CameraStream extends StatelessWidget {
  final int cameraId;
  final bool isPTZ;

  const CameraStream({super.key, required this.cameraId, this.isPTZ = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera $cameraId'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  "Livestream from Camera $cameraId",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          if (isPTZ) PTZControls(),
        ],
      ),
    );
  }
}

class PTZControls extends StatelessWidget {
  const PTZControls({super.key});

  void sendPTZCommand(String command) {
    // Replace with actual API call or command to the Raspberry Pi
    print("PTZ Command Sent: $command");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => sendPTZCommand('pan_left'),
            child: Icon(Icons.arrow_left),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => sendPTZCommand('tilt_up'),
                child: Icon(Icons.arrow_drop_up),
              ),
              ElevatedButton(
                onPressed: () => sendPTZCommand('zoom_in'),
                child: Icon(Icons.zoom_in),
              ),
              ElevatedButton(
                onPressed: () => sendPTZCommand('zoom_out'),
                child: Icon(Icons.zoom_out),
              ),
              ElevatedButton(
                onPressed: () => sendPTZCommand('tilt_down'),
                child: Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => sendPTZCommand('pan_right'),
            child: Icon(Icons.arrow_right),
          ),
        ],
      ),
    );
  }
}
