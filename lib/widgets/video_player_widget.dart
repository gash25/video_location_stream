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
      if (kIsWeb) {
        // Web-specific initialization
        await player.open(
          Media(widget.videoUrl),
          play: true, // Auto-play
        );
        // Set initial volume to 0 (muted)
        await player.setVolume(0);

        // Try to unmute after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          player.setVolume(100);
        });
      } else {
        // Non-web initialization
        await player.open(Media(widget.videoUrl));
      }
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
