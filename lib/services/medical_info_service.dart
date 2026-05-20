import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MedicalInfoService {
  static final String? _baseUrl =
      "${dotenv.env['API_URL']}/medical_info/add";

  /// POST with empty body → backend creates blank record.
  /// Returns the parsed JSON (Map<String, dynamic>) which must contain
  /// a key 'medical_info_id'.
  static Future<Map<String, dynamic>> createBlank() async {
    final url = _baseUrl;
    if (url == null || url.isEmpty) {
      throw AssertionError('API_URL/medical_info/add not configured');
    }

    final resp = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: '{}', // empty JSON object
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Failed to create medical_info: ${resp.statusCode}');
    }

    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;

    if (!data.containsKey('medical_info_id')) {
      throw Exception('Response missing medical_info_id');
    }
    return data; // e.g. { "medical_info_id": 42 }
  }
}