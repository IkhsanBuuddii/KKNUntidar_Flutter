import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prefs_service.dart';

class ApiService {
  ApiService._();
  static const baseUrl = 'http://localhost:8080/api';

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'password': password}));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final token = body['token'] as String?;
      if (token != null) await PrefsService.setToken(token);
      return body;
    }
    throw Exception('Login failed: \\${res.statusCode}');
  }

  static Future<Map<String, dynamic>> register(String username, String password, {Set<String>? roles}) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final body = {'username': username, 'password': password, 'roles': roles?.toList() ?? []};
    final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Register failed: \\${res.statusCode}');
  }

  static Future<List<dynamic>> getMahasiswaList() async {
    final url = Uri.parse('$baseUrl/mahasiswa');
    final token = await PrefsService.getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load mahasiswa');
  }

  static Future<Map<String, dynamic>> getMahasiswa(dynamic id) async {
    final url = Uri.parse('$baseUrl/mahasiswa/$id');
    final token = await PrefsService.getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to load mahasiswa');
  }

  // Optional: post an activity map to server. Server may not expose this endpoint; it's a best-effort sync.
  static Future<void> addActivity(Map<String, dynamic> activity) async {
    final url = Uri.parse('$baseUrl/activities');
    final token = await PrefsService.getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await http.post(url, headers: headers, body: jsonEncode(activity));
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to post activity: ${res.statusCode}');
    }
  }
}
