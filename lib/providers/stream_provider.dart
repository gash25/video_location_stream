import 'package:flutter/foundation.dart';
import 'dart:math' show Random, pi, sin, cos;
import '../models/stream_location.dart';
import 'dart:async';

class StreamLocationProvider with ChangeNotifier {
  StreamLocation? _streamLocation;
  final _random = Random();
  // For drone movement
  double _angle = 0;
  bool _isFlying = false;
  bool _isMoving = false;
  double _radius =
      0.02; // Radius of approximately 2km (0.02 degrees at equator)
  double _baseLatitude = 0;
  double _baseLongitude = 0;
  Timer? _timer;

  // Movement speed
  double _movementSpeed = 0.02;

  // Define major landmasses using bounding boxes (rough approximations)
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
    // Set initial video URL and location
    updateStreamUrl(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
  }

  StreamLocation? get streamLocation => _streamLocation;
  bool get isFlying => _isFlying;
  double get droneAngle =>
      _angle - (pi / 2); // Adjust angle for proper rotation

  void startFlying() {
    if (_streamLocation != null) {
      print("Starting flight simulation"); // Debug print
      _isFlying = true;
      _isMoving = true;
      _baseLatitude = _streamLocation!.latitude;
      _baseLongitude = _streamLocation!.longitude;
      _angle = 0;

      _timer?.cancel();

      // Use a separate timer for movement
      _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (_isMoving) {
          _updateDronePosition();
        }
      });
    }
  }

  void stopFlying() {
    print("Stopping flight simulation"); // Debug print
    _isFlying = false;
    _isMoving = false;
    _timer?.cancel();
    _timer = null;
  }

  void _updateDronePosition() {
    _angle += _movementSpeed;
    if (_angle > 2 * pi) {
      _angle = 0;
    }

    final newLatitude = _baseLatitude + (_radius * sin(_angle));
    final newLongitude = _baseLongitude + (_radius * cos(_angle));

    print("New drone position: $newLatitude, $newLongitude"); // Debug print

    _streamLocation = StreamLocation(
      latitude: newLatitude,
      longitude: newLongitude,
      streamUrl: _streamLocation?.streamUrl,
    );

    notifyListeners();
  }

  void updateStreamLocation(StreamLocation location) {
    _streamLocation = location;
    notifyListeners();
  }

  void updateStreamUrl(String url) {
    // Stop any ongoing flight
    stopFlying();

    // Generate new location
    final landmass = landmasses[_random.nextInt(landmasses.length)];

    // Calculate new coordinates
    _baseLatitude = _random.nextDouble() * (landmass.maxLat - landmass.minLat) +
        landmass.minLat;
    _baseLongitude =
        _random.nextDouble() * (landmass.maxLng - landmass.minLng) +
            landmass.minLng;

    print('New stream location: $_baseLatitude, $_baseLongitude');

    // Create new StreamLocation with both new coordinates and URL
    _streamLocation = StreamLocation(
      latitude: _baseLatitude,
      longitude: _baseLongitude,
      streamUrl: url,
    );

    // Reset movement parameters
    _angle = 0;
    _isMoving = false;
    _isFlying = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
