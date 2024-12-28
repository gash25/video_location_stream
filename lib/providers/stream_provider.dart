import 'package:flutter/foundation.dart';
import 'dart:math' show Random, pi, sin, cos;
import '../models/stream_location.dart';
import 'dart:async';

class StreamLocationProvider with ChangeNotifier {
  StreamLocation? _streamLocation;
  final _random = Random();

  // Movement and position properties
  double _angle = 0;
  bool _isFlying = false;
  bool _isMoving = false;
  double _baseLatitude = 0;
  double _baseLongitude = 0;
  Timer? _timer;

  // Constants for movement
  final double _radius = 0.02; // Approximately 2km radius
  final double _circleTime = 60.0; // Time to complete circle in seconds
  final int _updateInterval = 16; // Milliseconds between updates (60fps)

  // Define major landmasses using bounding boxes
  final List<({double minLat, double maxLat, double minLng, double maxLng})>
      landmasses = [
    // North America (USA focused)
    (minLat: 25.0, maxLat: 48.0, minLng: -125.0, maxLng: -75.0),
    // Europe (Western Europe)
    (minLat: 40.0, maxLat: 55.0, minLng: -5.0, maxLng: 20.0),
    // Asia (East Asia)
    (minLat: 20.0, maxLat: 40.0, minLng: 100.0, maxLng: 145.0),
    // Australia (Main continent)
    (minLat: -35.0, maxLat: -20.0, minLng: 115.0, maxLng: 150.0),
  ];

  StreamLocationProvider() {
    updateStreamUrl(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
  }

  StreamLocation? get streamLocation => _streamLocation;
  bool get isFlying => _isFlying;
  double get droneAngle => _angle - (pi / 2);

  // Add getters for base coordinates
  double get baseLatitude => _baseLatitude;
  double get baseLongitude => _baseLongitude;

  void startFlying() {
    if (_streamLocation != null) {
      print("Starting flight simulation");
      _isFlying = true;
      _isMoving = true;
      _baseLatitude = _streamLocation!.latitude;
      _baseLongitude = _streamLocation!.longitude;
      _angle = 0;

      _timer?.cancel();

      // Calculate angle increment for smooth movement
      // 2π radians / (10 seconds * 60fps) = angle per frame
      final anglePerFrame = (2 * pi) / ((_circleTime * 1000) / _updateInterval);

      // Use a timer for smooth movement
      _timer = Timer.periodic(Duration(milliseconds: _updateInterval), (timer) {
        if (_isMoving) {
          _angle += anglePerFrame;
          if (_angle > 2 * pi) {
            _angle = 0;
          }

          final newLatitude = _baseLatitude + (_radius * sin(_angle));
          final newLongitude = _baseLongitude + (_radius * cos(_angle));

          _streamLocation = StreamLocation(
            latitude: newLatitude,
            longitude: newLongitude,
            streamUrl: _streamLocation?.streamUrl,
          );

          notifyListeners();
        }
      });
    }
  }

  void stopFlying() {
    print("Stopping flight simulation");
    _isFlying = false;
    _isMoving = false;
    _timer?.cancel();
    _timer = null;
  }

  void updateStreamUrl(String url) {
    stopFlying();

    final landmass = landmasses[_random.nextInt(landmasses.length)];

    _baseLatitude = _random.nextDouble() * (landmass.maxLat - landmass.minLat) +
        landmass.minLat;
    _baseLongitude =
        _random.nextDouble() * (landmass.maxLng - landmass.minLng) +
            landmass.minLng;

    print('New stream location: $_baseLatitude, $_baseLongitude');

    _streamLocation = StreamLocation(
      latitude: _baseLatitude,
      longitude: _baseLongitude,
      streamUrl: url,
    );

    _angle = 0;
    _isMoving = false;
    _isFlying = false;

    notifyListeners();

    // Automatically start flying after location is set
    startFlying();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
