import 'dart:convert';
import 'package:http/http.dart' as http;

class OSMService {
  static final OSMService _instance = OSMService._internal();
  factory OSMService() => _instance;
  OSMService._internal();

  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=$query&format=json&limit=10'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error searching location: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> reverseGeocode(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reverse?lat=$lat&lon=$lon&format=json'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }
  
  Future<List<Map<String, dynamic>>> getNearbyFarmers(double lat, double lon, {double radius = 10}) async {
    try {
      // Query for farms/farmers within radius
      final query = '''
        [out:json];
        (
          node["shop"="farm"](${lat - radius},${lon - radius},${lat + radius},${lon + radius});
          node["shop"="greengrocer"](${lat - radius},${lon - radius},${lat + radius},${lon + radius});
          node["farm"](around:$radius,$lat,$lon);
        );
        out body;
      ''';
      
      final response = await http.get(
        Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> results = [];
        
        for (var element in data['elements']) {
          results.add({
            'id': element['id'],
            'lat': element['lat'],
            'lon': element['lon'],
            'name': element['tags']?['name'] ?? 'Unknown Farm',
            'tags': element['tags'],
          });
        }
        
        return results;
      }
      return [];
    } catch (e) {
      print('Error finding nearby farmers: $e');
      return [];
    }
  }
}