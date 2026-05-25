import 'dart:convert';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/main.dart';
import 'package:wakealert/models/contact.dart';
import 'package:wakealert/prefs_names.dart' as PrefsNames;

class AlertService {
  static final String? _apiUrl = dotenv.env['API_URL'];
  static final String? _emergencyNumber = dotenv.env['EMERGENCY_NUMBER'];
  
  static Future<void> smsAlert ({
    required int victimId,
    required double latitude,
    required double longitude,
    required ServiceInstance service,
  }) async {
      var jsonStr = jsonEncode({
          'victim_id': victimId,
          'latitude': '$latitude',
          'longitude': '$longitude',
      });
      await telephony.sendSms(
	    to: _emergencyNumber!,
	    message: "[WakeAlert Client Info] ${jsonStr}",
	    statusListener: (SendStatus status) {
	      print('SMS status: $status');
	    },
    );


      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString(PrefsNames.CONTACTS);
      if (raw == null) return;

      final List<dynamic> list = json.decode(raw);
      final loaded = list.map((e) => Contact.fromJson(e)).toList();

      debugPrint("Sorting contacts");

      loaded.sort((a, b) {
        // true (1) comes before false (0)
        int primaryCmp = a.isPrimary ? 1 : 0 - (b.isPrimary ? 1 : 0);
        if (primaryCmp != 0) return primaryCmp;

        // secondary ordering: alphabetically by last name, then first
        int lastCmp = a.lastName.compareTo(b.lastName);
        return lastCmp != 0 ? lastCmp : a.firstName.compareTo(b.firstName);
      });

      debugPrint("Trying to call: ${loaded.first.phoneNumber}");
      //await FlutterPhoneDirectCaller.callNumber(loaded.first.phoneNumber);
      service.invoke('triggerCall', {'phone': loaded.first.phoneNumber});

  }
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