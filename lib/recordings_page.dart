import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'settings.dart';

class RecordingsPage extends StatefulWidget {
  const RecordingsPage({super.key});

  @override
  State<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  List<String> recordings = [];
  bool isLoading = true;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? currentlyPlaying;

  late String _piIp;
  late int _port;
  late String _recordingsPath;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _piIp = prefs.getString('pi_ip') ?? PiConfig.defaultPiIp;
    _port = prefs.getInt('main_stream_port') ?? PiConfig.defaultMainStreamPort;
    _recordingsPath =
        prefs.getString('recordings_path') ?? PiConfig.defaultRecordingsPath;
    _fetchRecordings();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _fetchRecordings() async {
    try {
      final response = await http.get(
        Uri.parse('http://$_piIp:$_port/list_recordings?path=$_recordingsPath'),
      );

      if (response.statusCode == 200) {
        setState(() {
          recordings = List<String>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recordings');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recordings: $e')),
        );
      }
    }
  }

  Future<void> _playVideo(String fileName) async {
    if (currentlyPlaying == fileName) return;

    _videoController?.dispose();
    _chewieController?.dispose();

    setState(() {
      currentlyPlaying = fileName;
    });

    try {
      final videoController = VideoPlayerController.network(
        'http://$_piIp:$_port$_recordingsPath/$fileName',
      );

      await videoController.initialize();

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: videoController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _videoController = videoController;
        _chewieController = chewieController;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing video: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
      ),
      body: Column(
        children: [
          if (_chewieController != null)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : recordings.isEmpty
                    ? const Center(child: Text('No recordings found'))
                    : ListView.builder(
                        itemCount: recordings.length,
                        itemBuilder: (context, index) {
                          final fileName = recordings[index];
                          return ListTile(
                            leading: const Icon(Icons.video_library),
                            title: Text(fileName),
                            onTap: () => _playVideo(fileName),
                            selected: currentlyPlaying == fileName,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
