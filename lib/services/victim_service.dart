import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Victim {
  final int victimId;
  final int mobileUserId;
  final String firstName;
  final String lastName;
  final int medicalInfoId;

  Victim._({
    required this.victimId,
    required this.mobileUserId,
    required this.firstName,
    required this.lastName,
    required this.medicalInfoId,
  });

  factory Victim.fromJson(Map<String, dynamic> json) => Victim._(
        victimId: json['victim_id'] as int,
        mobileUserId: json['mobile_user_id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        medicalInfoId: json['medical_info_id'] as int,
      );
}

class VictimService {
  static final String? _apiUrl = dotenv.env['API_URL'];

  /// Creates a new victim record.
  /// Throws on network errors or unexpected status codes.
  /// Returns the created [Victim] when server replies 201.
  static Future<Victim> addVictim({
    required int mobileUserId,
    required String firstName,
    required String lastName,
    required int medicalInfoId,
  }) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$api/victims/add');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_user_id': mobileUserId,
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'medical_info_id': medicalInfoId,
        }),
      );

      if (resp.statusCode == 201) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        return Victim.fromJson(json);
      }

      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Add victim failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      throw Exception('Network error while adding victim: $e');
    }
  }
}
