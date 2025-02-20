import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraStream extends StatefulWidget {
  final int cameraId;
  final bool isPTZ;

  const CameraStream({super.key, required this.cameraId, this.isPTZ = false});

  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Replace with actual RTSP/HTTP URL from Raspberry Pi
    String streamUrl = widget.cameraId == 1
        ? "http://raspberrypi.local:8080/stream1"
        : "http://raspberrypi.local:8080/stream2";

    _controller = VideoPlayerController.network(streamUrl)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _controller.play();
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load video. Please check the connection.";
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera ${widget.cameraId}')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 50),
                            SizedBox(height: 10),
                            Text(_errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red)),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _initializeVideo,
                              child: Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
          ),
          if (widget.isPTZ) PTZControls(),
        ],
      ),
    );
  }
}

class PTZControls extends StatelessWidget {
  const PTZControls({super.key});

  void sendPTZCommand(String command) {
    // TODO: Implement API call to Raspberry Pi for PTZ control
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
