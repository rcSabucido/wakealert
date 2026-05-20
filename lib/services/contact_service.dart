import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wakealert/models/contact.dart';

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
        'relationship': relationshipName.trim(),
        'is_primary': isPrimary,
      }),
    );
  }

  /// GET all contacts for a given mobile-user id.
  /// Returns List<Contact> parsed from the JSON array.
  static Future<List<Contact>> getContactsByClient(int clientUserId) async {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$apiUrl/contacts/client/$clientUserId');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to load contacts: ${resp.statusCode}');
    }

    debugPrint("body out: ${resp.body}");

    final List<dynamic> list = jsonDecode(resp.body);
    return list.map((json) => Contact.fromJson(json)).toList();
  }
}
