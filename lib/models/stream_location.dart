class StreamLocation {
  final double latitude;
  final double longitude;
  final String? streamUrl;

  StreamLocation({
    required this.latitude,
    required this.longitude,
    this.streamUrl,
  });
}
