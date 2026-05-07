import 'dart:convert';
import 'package:http/http.dart' as http;

class OSRMService {
  static final OSRMService _instance = OSRMService._internal();
  factory OSRMService() => _instance;
  OSRMService._internal();

  static const String _baseUrl = 'https://router.project-osrm.org';
  
  Future<Map<String, dynamic>> getRoute(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Error getting route: $e');
      return {};
    }
  }
  
  Future<Map<String, dynamic>> getDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=false'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          return {
            'distance': route['distance'] / 1000, // Convert to km
            'duration': route['duration'] / 60, // Convert to minutes
          };
        }
      }
      return {'distance': 0, 'duration': 0};
    } catch (e) {
      print('Error getting distance: $e');
      return {'distance': 0, 'duration': 0};
    }
  }
  
  Future<Map<String, dynamic>> getTable(
    List<List<double>> coordinates,
  ) async {
    try {
      final coordString = coordinates.map((coord) => '${coord[1]},${coord[0]}').join(';');
      final response = await http.get(
        Uri.parse('$_baseUrl/table/v1/driving/$coordString'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Error getting table: $e');
      return {};
    }
  }
  
  Future<Map<String, dynamic>> getNearest(
    double lat,
    double lon,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/nearest/v1/driving/$lon,$lat?number=1'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Error getting nearest: $e');
      return {};
    }
  }
}