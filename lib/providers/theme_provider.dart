import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _showFlightPath = false;

  bool get isDarkMode => _isDarkMode;
  bool get showFlightPath => _showFlightPath;

  ThemeData get currentTheme => _isDarkMode
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleFlightPath() {
    _showFlightPath = !_showFlightPath;
    notifyListeners();
  }
}
