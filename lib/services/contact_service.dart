import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ContactService {
  static final String? _baseUrl = "${dotenv.env['API_URL']}/contacts/add";

  /// POST a new emergency contact.
  /// Returns the entire http.Response so the caller can inspect
  /// statusCode, body, headers, etc.
  static Future<http.Response> addContact({
    required int clientUserId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String relationshipName,
    required bool isPrimary,
  }) async {
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    return http.post(
      Uri.parse(_baseUrl!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_user_id': clientUserId,
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone_number': phoneNumber.trim(),
        'relationship_name': relationshipName.trim(),
        'is_primary': isPrimary,
      }),
    );
  }
}
