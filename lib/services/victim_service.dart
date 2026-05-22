import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wakealert/outbox/outbox_provider.dart';

class Victim {
  final int victimId;
  final int mobileUserId;
  final String firstName;
  final String lastName;
  final int medicalInfoId;
  int? addressID;

  Victim._({
    required this.victimId,
    required this.mobileUserId,
    required this.firstName,
    required this.lastName,
    required this.medicalInfoId,
    this.addressID,
  });

  factory Victim.fromJson(Map<String, dynamic> json) => Victim._(
        victimId: json['victim_id'] as int,
        mobileUserId: json['mobile_user_id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        medicalInfoId: json['medical_info_id'] as int,
        addressID: json['address_id'] as int?,
      );
}

class VictimService {
  static final String? _apiUrl = dotenv.env['API_URL'];

  static void enqueueUpdateVictim({
    required BuildContext context,
    required int victimId,
    String? firstName,
    String? lastName,
    String? birthDate,
  }) {
    final repo = OutboxProvider.of(context);

    Map<String, dynamic> map = {};
    if (firstName != null && firstName.isNotEmpty) {
      map["first_name"] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      map["last_name"] = lastName;
    }
    if (birthDate != null && birthDate.isNotEmpty) {
      map["birth_date"] = birthDate;
    }

    repo.enqueue(
      endpoint: '/victims/update/${victimId}',
      method: 'POST',
      payload: map,
    );
  }

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

  static Future<Victim> getVictimByMobileUser(int mobileUserId) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('${api}/victims/mobile_user/${mobileUserId}');
    try {
      final resp = await http.get(uri);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        return Victim.fromJson(map);
      }

      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Get victim by mobile user failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      throw Exception('Network error while getting victim details: $e');
    }
  }

  static Future<Map<String, dynamic>> getVictimDetails(int victimId) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('${api}/victims/${victimId}');
    try {
      final resp = await http.get(uri);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        return map;
      }

      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Get victim details failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      throw Exception('Network error while getting victim details: $e');
    }
  }

  static Future<Map<String, dynamic>> getVictimAddressID(int victimId) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('${api}/victims/address_id/${victimId}');
    try {
      final resp = await http.get(uri);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        return map;
      }

      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Get victim address id failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      throw Exception('Network error while getting victim address id: $e');
    }
  }

  static Future<void> setVictimAddressID({
    required int victimId,
    required int addressId
  }) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('${api}/victims/address_id/${victimId}');
    try {
      final resp = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'address_id': addressId,
        })
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return;
      }

      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Setting victim address id failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      throw Exception('Network error while setting victim address id: $e');
    }
  }

  static Future<Map<String, dynamic>> createAddressLine(int victimId) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('${api}/addresses/lines');
    try {
      final resp = await http.post(uri);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        return map;
      }

      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Creating address line failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      throw Exception('Network error while creating address line: $e');
    }
  }

  static Future<Map<String, dynamic>> getAddressLine(int addressId) async {
    final api = _apiUrl;
    if (api == null || api.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('${api}/addresses/lines/${addressId}');
    try {
      final resp = await http.get(uri);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        return map;
      }

      final bodyString = resp.body.isNotEmpty ? resp.body : 'No details';
      throw Exception('Get address line failed (${resp.statusCode}): $bodyString');
    } catch (e) {
      throw Exception('Network error while getting address line: $e');
    }
  }

  static void enqueueUpdateAddressLine({
    required BuildContext context,
    required int addressId,
    required String barangayPsgc,
    required String addressLine,
  }) {
    final repo = OutboxProvider.of(context);

    repo.enqueue(
      endpoint: '/addresses/lines/${addressId}',
      method: 'PUT',
      payload: {
        "address_line": addressLine,
        "barangay_psgc": barangayPsgc,
      },
    );
  }
}
