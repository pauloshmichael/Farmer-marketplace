import 'dart:convert';
import 'package:http/http.dart' as http;

class NominatimService {
  static final NominatimService _instance = NominatimService._internal();
  factory NominatimService() => _instance;
  NominatimService._internal();

  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=$query&format=json&limit=10&addressdetails=1'),
        headers: {
          'User-Agent': 'FarmerMarketplace/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final address = item['address'] as Map<String, dynamic>? ?? {};
          return {
            'lat': double.parse(item['lat'].toString()),
            'lon': double.parse(item['lon'].toString()),
            'display_name': item['display_name'],
            'street': address['road'] ?? address['street'] ?? '',
            'city': address['city'] ?? address['town'] ?? address['village'] ?? '',
            'state': address['state'] ?? '',
            'country': address['country'] ?? '',
            'postcode': address['postcode'] ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching address: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> reverseGeocode(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1'),
        headers: {
          'User-Agent': 'FarmerMarketplace/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>? ?? {};
        
        return {
          'lat': lat,
          'lon': lon,
          'display_name': data['display_name'],
          'street': address['road'] ?? address['street'] ?? '',
          'city': address['city'] ?? address['town'] ?? address['village'] ?? '',
          'state': address['state'] ?? '',
          'country': address['country'] ?? '',
          'postcode': address['postcode'] ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getAddressDetails(String osmId, String osmType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lookup?osm_ids=$osmType$osmId&format=json&addressdetails=1'),
        headers: {
          'User-Agent': 'FarmerMarketplace/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final item = data[0];
          final address = item['address'] as Map<String, dynamic>? ?? {};
          
          return {
            'lat': double.parse(item['lat'].toString()),
            'lon': double.parse(item['lon'].toString()),
            'display_name': item['display_name'],
            'street': address['road'] ?? address['street'] ?? '',
            'city': address['city'] ?? address['town'] ?? address['village'] ?? '',
            'state': address['state'] ?? '',
            'country': address['country'] ?? '',
            'postcode': address['postcode'] ?? '',
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting address details: $e');
      return null;
    }
  }
  
  Future<List<Map<String, dynamic>>> autocomplete(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=$query&format=json&limit=5&addressdetails=1&limit=5'),
        headers: {
          'User-Agent': 'FarmerMarketplace/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return {
            'display_name': item['display_name'],
            'lat': double.parse(item['lat'].toString()),
            'lon': double.parse(item['lon'].toString()),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error autocompleting address: $e');
      return [];
    }
  }
}