import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AlertService {
  static final String? _apiUrl = dotenv.env['API_URL'];
  static Future<void> addAlert({
    required int victimId,
    required double latitude,
    required double longitude,
  }) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$api/alerts');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'victim_id': victimId,
          'latitude': '$latitude',
          'longitude': '$longitude',
        }),
      );

      if (resp.statusCode == 201) {
        return;
      }

      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Add alert failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      throw Exception('Network error while adding victim: $e');
    }
  }
}