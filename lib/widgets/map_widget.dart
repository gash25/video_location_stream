import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart';
import '../providers/theme_provider.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _mapController;

  // Update dark mode URL to use CartoDB dark matter
  final String _darkModeUrl =
      'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png';
  final String _lightModeUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Add subdomains for CartoDB
  final List<String> _subdomains = ['a', 'b', 'c', 'd'];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _focusLocation(LatLng position) {
    // Add a small delay to ensure the map is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      _mapController.move(position, 12.0);
      print('Focusing map on: ${position.latitude}, ${position.longitude}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StreamLocationProvider, ThemeProvider>(
      builder: (context, streamProvider, themeProvider, child) {
        final location = streamProvider.streamLocation;
        final position = location != null
            ? LatLng(location.latitude, location.longitude)
            : const LatLng(0, 0);

        _focusLocation(position);

        return Card(
          elevation: 5.0,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: position,
              zoom: 12.0,
              minZoom: 3.0,
              maxZoom: 19.0,
              onMapReady: () {
                _mapController.move(position, 12.0);
              },
              interactiveFlags: streamProvider.isFlying
                  ? InteractiveFlag.none
                  : InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    themeProvider.isDarkMode ? _darkModeUrl : _lightModeUrl,
                userAgentPackageName: 'com.example.app',
                maxZoom: 19,
                subdomains: themeProvider.isDarkMode
                    ? _subdomains
                    : const [], // Add subdomains for dark mode
              ),
              if (location != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: position,
                      width: 100,
                      height: 100,
                      builder: (context) => Transform.rotate(
                        angle: streamProvider.isFlying
                            ? streamProvider.droneAngle
                            : 0,
                        child: const DroneMarker(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

class DroneMarker extends StatefulWidget {
  const DroneMarker({super.key});

  @override
  State<DroneMarker> createState() => _DroneMarkerState();
}

class _DroneMarkerState extends State<DroneMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing circle
            Container(
              width: 70 + (_animation.value * 30),
              height: 70 + (_animation.value * 30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2 * (1 - _animation.value)),
              ),
            ),
            // Inner pulsing circle
            Container(
              width: 50 + (_animation.value * 20),
              height: 50 + (_animation.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.3 * (1 - _animation.value)),
              ),
            ),
            // New drone icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center body
                  const Icon(
                    Icons.lens,
                    color: Colors.red,
                    size: 20,
                  ),
                  // Drone arms and propellers
                  Transform.rotate(
                    angle: pi / 4, // 45 degrees
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Arms
                        Container(
                          width: 30,
                          height: 4,
                          color: Colors.red,
                        ),
                        Container(
                          width: 4,
                          height: 30,
                          color: Colors.red,
                        ),
                        // Propellers
                        const Positioned(
                          top: 0,
                          left: 0,
                          child: Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 8,
                          ),
                        ),
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 8,
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          child: Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 8,
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
