import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin client for the FarmWise FastAPI backend.
///
/// Base URL can be changed at build time:
///   flutter run -d chrome --dart-define=API_URL=http://192.168.1.10:8000/api/v1
class ApiClient {
  static const String defaultBaseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000/api/v1');

  final String baseUrl;
  final http.Client _http;
  final Duration timeout;

  ApiClient({String? baseUrl, http.Client? client, this.timeout = const Duration(seconds: 8)})
      : baseUrl = baseUrl ?? defaultBaseUrl,
        _http = client ?? http.Client();

  Future<dynamic> _get(String path) async {
    final res = await _http.get(Uri.parse('$baseUrl$path')).timeout(timeout);
    return _decode(res);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final res = await _http
        .post(Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
        .timeout(timeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<Map<String, dynamic>> health() async => await _get('/health');
  Future<Map<String, dynamic>> dashboard() async => await _get('/dashboard');
  Future<Map<String, dynamic>> location() async => await _get('/location');
  Future<Map<String, dynamic>> seasons() async => await _get('/seasons');
  Future<Map<String, dynamic>> soil() async => await _get('/soil');

  Future<Map<String, dynamic>> recommendations({double? soilPh}) async =>
      await _post('/recommendations', {if (soilPh != null) 'soil_ph': soilPh});

  Future<List<dynamic>> rotations(String rotation, List<String> priorities) async =>
      await _post('/rotations', {'rotation': rotation, 'priorities': priorities});

  Future<String> chat(String message, {String? rotation, List<String>? priorities}) async {
    final res = await _post('/chat', {
      'message': message,
      if (rotation != null) 'rotation': rotation,
      if (priorities != null) 'priorities': priorities,
    });
    return res['reply'] as String;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
