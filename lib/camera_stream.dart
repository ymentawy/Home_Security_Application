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

  /// 🚀 Modular function to get the correct stream URL based on `cameraId`
  String _getStreamUrl() {
    // 🔹 Both Main Camera & PTZ Camera now use OBS HLS
    return "http://IP:8080/hls/test.m3u8"; // OBS HLS URL
  }

  void _initializeVideo() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String streamUrl = _getStreamUrl(); // Get the correct URL dynamically

    _controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl))
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _controller.play();
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load stream. Please check the connection.";
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
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 50),
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _initializeVideo,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.cover, // 🔥 Fixes aspect ratio issue
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
          ),
          if (widget.isPTZ) const PTZControls(),
        ],
      ),
    );
  }
}

class PTZControls extends StatelessWidget {
  const PTZControls({super.key});

  void sendPTZCommand(String command) {
    // TODO: Implement API call for PTZ control in the future
    print("PTZ Command Sent: $command");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => sendPTZCommand('pan_left'),
            child: const Icon(Icons.arrow_left),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => sendPTZCommand('tilt_up'),
                child: const Icon(Icons.arrow_drop_up),
              ),
              ElevatedButton(
                onPressed: () => sendPTZCommand('zoom_in'),
                child: const Icon(Icons.zoom_in),
              ),
              ElevatedButton(
                onPressed: () => sendPTZCommand('zoom_out'),
                child: const Icon(Icons.zoom_out),
              ),
              ElevatedButton(
                onPressed: () => sendPTZCommand('tilt_down'),
                child: const Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => sendPTZCommand('pan_right'),
            child: const Icon(Icons.arrow_right),
          ),
        ],
      ),
    );
  }
}
