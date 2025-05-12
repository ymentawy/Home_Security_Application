import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'settings.dart';

class CameraStream extends StatefulWidget {
  final int cameraId;
  final bool isPTZ;
  final String? initialStreamUrl;

  const CameraStream({
    Key? key,
    required this.cameraId,
    this.isPTZ = false,
    this.initialStreamUrl,
  }) : super(key: key);

  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  late TextEditingController _urlController;
  late String _currentStreamUrl;
  late String _piIp;
  late int _streamPort;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _piIp = prefs.getString('pi_ip') ?? PiConfig.defaultPiIp;
    _streamPort = widget.isPTZ
        ? (prefs.getInt('ptz_stream_port') ?? PiConfig.defaultPtzStreamPort)
        : (prefs.getInt('main_stream_port') ?? PiConfig.defaultMainStreamPort);

    _currentStreamUrl = widget.initialStreamUrl ?? _getDefaultStreamUrl();
    _urlController = TextEditingController(text: _currentStreamUrl);
    setState(() {});
  }

  String _getDefaultStreamUrl() => "http://$_piIp:$_streamPort";

  void _updateStream() {
    final newUrl = _urlController.text.trim();
    if (newUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL')),
      );
      return;
    }
    setState(() {
      _currentStreamUrl = newUrl;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera ${widget.cameraId}')),
      body: Column(
        children: [
          // URL input + Load button
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
                      hintText: 'Enter MJPEG stream URL',
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

          // MJPEG Stream (wrapped in KeyedSubtree so it rebuilds on URL change)
          Expanded(
            child: Center(
              child: KeyedSubtree(
                key: ValueKey(_currentStreamUrl),
                child: MJPEGStreamScreen(
                  streamUrl: _currentStreamUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  fit: BoxFit.contain,
                  showLiveIcon: true,
                ),
              ),
            ),
          ),

          // PTZ Controls (if enabled)
          if (widget.isPTZ) PTZControls(serverUrl: _currentStreamUrl),
        ],
      ),
    );
  }
}

class PTZControls extends StatelessWidget {
  final String serverUrl;

  const PTZControls({Key? key, required this.serverUrl}) : super(key: key);

  Future<void> sendPTZCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"command": command}),
      );
      if (response.statusCode == 200) {
        debugPrint("Command sent successfully: $command");
      } else {
        debugPrint(
          "Failed to send command: $command. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error sending command $command: $e");
    }
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
