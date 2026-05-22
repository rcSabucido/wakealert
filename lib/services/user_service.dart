import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ---------- Model ----------
class MobileUser {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;

  MobileUser._({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory MobileUser.fromJson(Map<String, dynamic> json) => MobileUser._(
    id: (json['mobile_user_id'] ?? json['id']) as int,
    email: json['email'] as String,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
  );
}

class AuthResponse {
  final int status;
  final Map<String, dynamic>? body; // null when decode fails
  final String? error;              // network or decode error text

  AuthResponse._({required this.status, this.body, this.error});

  factory AuthResponse.fromHttpResponse(http.Response r) {
    try {
      final decoded = jsonDecode(r.body) as Map<String, dynamic>;
      return AuthResponse._(status: r.statusCode, body: decoded);
    } catch (e) {
      return AuthResponse._(status: r.statusCode, error: e.toString());
    }
  }
}

// ---------- Service ----------
class AuthService {
  static final String? _apiUrl = dotenv.env['API_URL'];

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    if (_apiUrl == null || _apiUrl!.isEmpty) {
      throw AssertionError('LOGIN_ENDPOINT not found in .env');
    }

    try {
      final url = "${_apiUrl!}/mobile/auth/login";
      final resp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );
      return AuthResponse.fromHttpResponse(resp);
    } catch (e) {
      return AuthResponse._(status: 0, error: e.toString());
    }
  }

  // GET /mobile_users/email/{email}
  // Returns MobileUser on 200, throws on network/error, returns null on 404
  static Future<MobileUser?> getMobileUserByEmail(String email) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$api/mobile_users/email/${Uri.encodeComponent(email)}');
    try {
      final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (resp.statusCode == 200) {
        var json = jsonDecode(resp.body);
        return MobileUser._(
          id: json['mobile_user_id'] as int,
          email: json['email'] as String,
        );
      } else if (resp.statusCode == 404) {
        return null; // user not found
      } else {
        throw Exception('Server error ${resp.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Creates a new mobile-user account.
  /// Throws on network errors or unexpected status codes.
  /// Returns the created [MobileUser] when server replies 201.
  static Future<MobileUser> createMobileUser({
    required String email,
    required String password,
  }) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$api/mobile_users');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        // Expecting server to return the created user JSON
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        return MobileUser.fromJson(json);
      }

      // Handle known error shapes if your backend returns them
      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Create user failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      // Re-throw network/JSON errors unchanged
      throw Exception('Network error while creating user: $e');
    }
}
}
