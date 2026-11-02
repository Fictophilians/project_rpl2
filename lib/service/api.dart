import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Apiservice {
  static String get baseUrl {
    return "http://localhost:3000/api";
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveUserInfo(String role, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
    await prefs.setString('username', username);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    return _safeRequest(() async {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    return _safeRequest(() async {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    return _safeRequest(() async {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> delete(String endpoint) async {
    return _safeRequest(() async {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> uploadProfilePhoto(XFile file) async {
    return _safeRequest(() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/photo'),
      );

      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
      final mimeSubType = (ext == 'png')
          ? 'png'
          : (ext == 'webp')
              ? 'webp'
              : (ext == 'gif')
                  ? 'gif'
                  : 'jpeg';
      final fileName = file.name.contains('.') ? file.name : '${file.name}.$mimeSubType';
      final contentType = (file.mimeType != null && file.mimeType!.startsWith('image/'))
          ? MediaType.parse(file.mimeType!)
          : MediaType('image', mimeSubType);

      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: fileName,
          contentType: contentType,
        ),
      );

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      return _prosesResponse(response);
    });
  }

  static Future<dynamic> _safeRequest(Future<dynamic> Function() action) async {
    try {
      return await action();
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke backend. Pastikan server Express aktif dan kabel USB terhubung!');
    } on http.ClientException {
      throw Exception('Koneksi ke backend gagal. Pastikan server Express aktif di port 3000!');
    } on TimeoutException {
      throw Exception('Waktu tunggu koneksi habis. Server tidak merespons.');
    }
  }

  static dynamic _prosesResponse(http.Response response) {
    final dynamic body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final pesanError = (body is Map && body['message'] != null)
        ? body['message']
        : 'Terjadi kesalahan pada server (Kode: ${response.statusCode})';

    throw Exception(pesanError);
  }
}
