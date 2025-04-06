import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraStream extends StatefulWidget {
  final int cameraId;
  final bool isPTZ;
  final String? initialStreamUrl;

  const CameraStream({
    super.key,
    required this.cameraId,
    this.isPTZ = false,
    this.initialStreamUrl,
  });

  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  late TextEditingController _urlController;
  late String _currentStreamUrl;

  @override
  void initState() {
    super.initState();
    // Initialize with provided URL or default
    _currentStreamUrl = widget.initialStreamUrl ?? _getDefaultStreamUrl();
    _urlController = TextEditingController(text: _currentStreamUrl);
    _initializeVideo();
  }

  /// Get the default stream URL based on cameraId
  String _getDefaultStreamUrl() {
    // Default OBS HLS URL
    return "http://10.40.34.164:8080/hls/test.m3u8";
  }

  void _initializeVideo() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(_currentStreamUrl))
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _controller.play();
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Failed to load stream. Please check the URL or connection.";
        });
      });
  }

  void _updateStream() {
    // Get the new URL from the text controller
    final newUrl = _urlController.text.trim();

    // Check if URL is valid
    if (newUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL')),
      );
      return;
    }

    // Dispose of the old controller
    _controller.dispose();

    // Update the current URL and reinitialize
    setState(() {
      _currentStreamUrl = newUrl;
    });

    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera ${widget.cameraId}')),
      body: Column(
        children: [
          // URL Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Stream URL',
                      border: OutlineInputBorder(),
                      hintText: 'Enter stream URL (HLS, RTSP, etc.)',
                    ),
                    onSubmitted: (_) => _updateStream(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _updateStream,
                  child: const Text('Load'),
                ),
              ],
            ),
          ),

          // Video Player
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
                    : Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
          ),

          // PTZ Controls (if applicable)
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
