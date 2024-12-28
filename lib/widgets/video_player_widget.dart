import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late Player player;
  late VideoController controller;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    _initializePlayer();
  }

  void _initializePlayer() async {
    try {
      await player.open(
        Media(widget.videoUrl),
        play: true,
      );

      // Print basic video information
      print('Video URL: ${widget.videoUrl}');
      print('Player state: ${player.state}');

      // Listen to player state changes
      player.stream.playing.listen((playing) {
        print('Video is playing: $playing');
      });

      player.stream.duration.listen((duration) {
        print('Video duration: $duration');
      });

      player.stream.width.listen((width) {
        print('Video width: $width');
      });

      player.stream.height.listen((height) {
        print('Video height: $height');
      });
    } catch (e) {
      debugPrint('Error initializing player: $e');
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Column(
        children: [
          Expanded(
            child: Video(
              controller: controller,
              controls: AdaptiveVideoControls,
            ),
          ),
          if (kIsWeb) // Add a play button for web
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await player.play();
                  await player.setVolume(100);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Video'),
              ),
            ),
        ],
      ),
    );
  }
}
