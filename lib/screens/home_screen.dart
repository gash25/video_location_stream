import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/map_widget.dart';
import '../providers/stream_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // List of test video streams
  static const List<String> videoStreams = [
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Stream Location'),
        actions: [
          Consumer<StreamLocationProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isFlying ? Icons.pause_circle : Icons.play_circle,
                ),
                onPressed: () {
                  if (provider.isFlying) {
                    provider.stopFlying();
                  } else {
                    provider.startFlying();
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<StreamLocationProvider>(
                context,
                listen: false,
              );
              final currentUrl =
                  provider.streamLocation?.streamUrl ?? videoStreams[0];
              provider.updateStreamUrl(currentUrl);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stream selection buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: List.generate(
                videoStreams.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.videocam),
                    label: Text('Drone ${index + 1}'),
                    onPressed: () {
                      final provider = Provider.of<StreamLocationProvider>(
                        context,
                        listen: false,
                      );
                      provider.updateStreamUrl(videoStreams[index]);
                    },
                  ),
                ),
              ),
            ),
          ),
          // Video and map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 60,
                    child: Consumer<StreamLocationProvider>(
                      builder: (context, provider, _) {
                        final videoUrl = provider.streamLocation?.streamUrl ??
                            videoStreams[0];
                        print('Current video URL: $videoUrl'); // Debug print
                        return VideoPlayerWidget(
                          videoUrl: videoUrl,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 40,
                    child: MapWidget(
                      key: ValueKey('map'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}