import 'dart:math' as math;
import 'package:flutter/material.dart';

class MapProvider extends ChangeNotifier {
  double? _currentLatitude;
  double? _currentLongitude;
  String? _currentAddress;
  bool _isLoading = false;
  String? _errorMessage;

  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate getting location
    await Future.delayed(const Duration(seconds: 1));

    // Mock location (New York City)
    _currentLatitude = 40.7128;
    _currentLongitude = -74.0060;
    _currentAddress = 'New York, NY, USA';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchLocation(String query) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // Mock search results
    _currentAddress = query;

    _isLoading = false;
    notifyListeners();
  }

  Future<double> calculateDistance(
      double lat1, double lon1, double lat2, double lon2) async {
    // Haversine formula to calculate distance between two points
    const double R = 6371; // Earth's radius in km

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    double distance = R * c;

    return distance;
  }

  double _toRadians(double degree) {
    return degree * 3.141592653589793 / 180;
  }

  double _sin(double x) {
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  double _cos(double x) {
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  double _sqrt(double x) {
    return x > 0 ? math.sqrt(x) : 0;
  }

  double _atan2(double y, double x) {
    return math.atan2(y, x);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
