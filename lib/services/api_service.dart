import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:green_guard/models/plant_model.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  // Backend base URL for real Android devices (developer machine LAN IP).
static const String baseUrl = 'http://127.0.0.1:5000/api';
  static const String _tokenKey = 'token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> _jsonHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    try {
      // Debug logging
      // ignore: avoid_print
      print("Login request URL: $baseUrl/auth/login");

      final res = await http
          .post(
            uri,
            headers: _jsonHeaders(null),
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      // ignore: avoid_print
      print('Login response: ${res.statusCode} ${res.body}');

      final body = _decode(res);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(body['message']?.toString() ?? 'Login failed');
      }
      return body;
    } on TimeoutException {
      throw ApiException('Login request timed out. Please check your network.');
    } on SocketException {
      throw ApiException('Unable to reach server. Please check your network.');
    }
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    try {
      final res = await http
          .post(
            uri,
            headers: _jsonHeaders(null),
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final body = _decode(res);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(body['message']?.toString() ?? 'Register failed');
      }
      return body;
    } on TimeoutException {
      throw ApiException(
        'Register request timed out. Please check your network.',
      );
    } on SocketException {
      throw ApiException('Unable to reach server. Please check your network.');
    }
  }

  Future<List<PlantModel>> getPlants() async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/plants');
    try {
      print('Fetching plants from: $uri');
      final res = await http
          .get(uri, headers: _jsonHeaders(token))
          .timeout(const Duration(seconds: 10));

      print('Get plants response status: ${res.statusCode}');
      print('Response body: ${res.body}');
      
      final decoded = _decodeAny(res);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        final message = (decoded is Map && decoded['message'] != null)
            ? decoded['message'].toString()
            : 'Failed to fetch plants';
        print('Error fetching plants: $message');
        throw ApiException(message);
      }

      // Handle response format {success: true, plants: [...]}
      final plantsList = decoded is Map ? decoded['plants'] : decoded;
      if (plantsList is! List) {
        print('Unexpected response format: $plantsList');
        throw ApiException('Unexpected response for plants list');
      }

      print('Successfully fetched ${plantsList.length} plants');
      return plantsList
          .whereType<Map<String, dynamic>>()
          .map(_plantFromApi)
          .toList();
    } on TimeoutException {
      print('Timeout fetching plants');
      throw ApiException(
        'Fetching plants timed out. Please check your network.',
      );
    } on SocketException {
      print('Socket error fetching plants');
      throw ApiException('Unable to reach server. Please check your network.');
    } catch (e) {
      print('Error in getPlants: $e');
      rethrow;
    }
  }

  Future<PlantModel> createPlant(
    String plantName,
    double latitude,
    double longitude,
    File? photoFile,
  ) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/plants');
    final req = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }

    req.fields['plantName'] = plantName;
    req.fields['latitude'] = latitude.toString();
    req.fields['longitude'] = longitude.toString();
    req.fields['status'] = 'Healthy'; // Default status

    if (photoFile != null) {
      print('Uploading photo from: ${photoFile.path}');
      req.files.add(await http.MultipartFile.fromPath('photo', photoFile.path));
    }

    try {
      print('Sending plant creation request to: $uri');
      final streamed =
          await req.send().timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(streamed);
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
      
      final decoded = _decode(res);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        print('Error creating plant: ${decoded['message']}');
        throw ApiException(
          decoded['message']?.toString() ?? 'Create plant failed',
        );
      }

      // Handle response format {success: true, plant: {...}}
      final plantData = decoded['plant'] ?? decoded;
      print('Plant created successfully');
      return _plantFromApi(plantData);
    } on TimeoutException {
      print('Timeout creating plant');
      throw ApiException(
        'Creating plant timed out. Please check your network.',
      );
    } on SocketException {
      print('Socket error creating plant');
      throw ApiException('Unable to reach server. Please check your network.');
    } catch (e) {
      print('Unexpected error creating plant: $e');
      rethrow;
    }
  }

  Future<PlantModel> updatePlantStatus(String plantId, String status) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/plants/$plantId');
    try {
      final res = await http
          .put(
            uri,
            headers: _jsonHeaders(token),
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));

      final decoded = _decode(res);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(
          decoded['message']?.toString() ?? 'Update plant failed',
        );
      }
      // Handle new response format {success: true, data: {...}}
      final plantData = decoded['data'] ?? decoded;
      return _plantFromApi(plantData);
    } on TimeoutException {
      throw ApiException(
        'Updating plant timed out. Please check your network.',
      );
    } on SocketException {
      throw ApiException('Unable to reach server. Please check your network.');
    }
  }

  Future<void> deletePlant(String plantId) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/plants/$plantId');
    try {
      final res = await http
          .delete(uri, headers: _jsonHeaders(token))
          .timeout(const Duration(seconds: 10));
      final decoded = _decodeAny(res);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        final message = (decoded is Map && decoded['message'] != null)
            ? decoded['message'].toString()
            : 'Delete plant failed';
        throw ApiException(message);
      }
    } on TimeoutException {
      throw ApiException(
        'Deleting plant timed out. Please check your network.',
      );
    } on SocketException {
      throw ApiException('Unable to reach server. Please check your network.');
    }
  }

  // ---- helpers ----

  PlantModel _plantFromApi(Map<String, dynamic> map) {
    final id = (map['_id'] ?? map['id'] ?? map['plantId'] ?? '').toString();
    final name = (map['plantName'] ?? '').toString();
    
    // Extract latitude/longitude from location.coordinates or direct fields
    double lat = 0;
    double lng = 0;
    
    if (map['latitude'] != null || map['longitude'] != null) {
      // Direct latitude/longitude fields
      lat = (map['latitude'] is num)
          ? (map['latitude'] as num).toDouble()
          : double.tryParse((map['latitude'] ?? '0').toString()) ?? 0;
      lng = (map['longitude'] is num)
          ? (map['longitude'] as num).toDouble()
          : double.tryParse((map['longitude'] ?? '0').toString()) ?? 0;
    } else if (map['location'] != null && map['location'] is Map) {
      // GeoJSON format: { type: 'Point', coordinates: [lng, lat] }
      final location = map['location'] as Map<String, dynamic>;
      final coordinates = location['coordinates'] as List?;
      if (coordinates != null && coordinates.length >= 2) {
        lng = (coordinates[0] is num) 
            ? (coordinates[0] as num).toDouble() 
            : 0;
        lat = (coordinates[1] is num) 
            ? (coordinates[1] as num).toDouble() 
            : 0;
      }
    }
    
    final photoUrl = (map['photoUrl'] ?? '').toString();
    final status = (map['status'] ?? 'Healthy').toString();
    final lastUpdatedRaw = map['lastUpdated']?.toString();
    final lastUpdated =
        (lastUpdatedRaw == null) ? DateTime.now() : DateTime.tryParse(lastUpdatedRaw) ?? DateTime.now();

    return PlantModel(
      plantId: id,
      plantName: name,
      latitude: lat,
      longitude: lng,
      photoUrl: photoUrl,
      status: status,
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> _decode(http.Response res) {
    final decoded = _decodeAny(res);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException('Unexpected response format');
  }

  dynamic _decodeAny(http.Response res) {
    if (res.body.isEmpty) return {};
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return {'message': res.body};
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

