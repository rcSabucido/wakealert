import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wakealert/outbox/outbox_provider.dart';

/*
class MedicalInfo {
  final int medicalInfoId;
  final String allergies;
  final String medication;
  final String medicalNotes;
  final String lastDiagnosisDate;
  final String lastDiagnosisHospitalName;
  final String pregnancyStatusName;
  final String donorStatusName;
  final String bloodTypeName;

  MedicalInfo._({
    required this.medicalInfoId,
    required this.allergies,
    required this.medication,
    required this.medicalNotes,
    required this.lastDiagnosisDate,
    required this.lastDiagnosisHospitalName,
    required this.pregnancyStatusName,
    required this.donorStatusName,
    required this.bloodTypeName,
  });

  factory MedicalInfo.fromJson(Map<String, dynamic> json) => MedicalInfo._(
        medicalInfoId: json['medical_info_id'] as int,
        allergies: json['allergies'] as String,
        medication: json['medication'] as String,
        medicalNotes: json['medical_notes'] as String,
        lastDiagnosisDate: json['last_diagnosis_date'] as String,
        lastDiagnosisHospitalName: json['last_diagnosis_hospital_name'] as String,
        pregnancyStatusName: json['pregnancy_status_name'] as String,
        donorStatusName: json['donor_status_name'] as String,
        bloodTypeName: json['blood_type_name'] as String,
      );
}
*/

class MedicalInfoService {
  static final String? _baseUrl =
      "${dotenv.env['API_URL']}/medical_info/add";

  static void enqueueUpdateMedicalInfo({
    required BuildContext context,
    required int medicalInfoId,
    String? allergies,
    String? medication,
    String? medicalNotes,
    String? lastDiagnosisDate,
    String? lastDiagnosisHospitalName,
    String? pregnancyStatusName,
    String? donorStatusName,
    String? bloodTypeName,
  }) {
    final repo = OutboxProvider.of(context);

    Map<String, dynamic> map = {};
    if (allergies != null && allergies.isNotEmpty) {
      map["allergies"] = allergies;
    }
    if (medication != null && medication.isNotEmpty) {
      map["medication"] = medication;
    }
    if (medicalNotes != null && medicalNotes.isNotEmpty) {
      map["medical_notes"] = medicalNotes;
    }
    if (lastDiagnosisDate != null && lastDiagnosisDate.isNotEmpty) {
      map["last_diagnosis_date"] = lastDiagnosisDate;
    }
    if (lastDiagnosisHospitalName != null && lastDiagnosisHospitalName.isNotEmpty) {
      map["last_diagnosis_hospital_name"] = lastDiagnosisHospitalName;
    }
    if (pregnancyStatusName != null && pregnancyStatusName.isNotEmpty) {
      map["pregnancy_status_name"] = pregnancyStatusName;
    }
    if (donorStatusName != null && donorStatusName.isNotEmpty) {
      map["donor_status_name"] = donorStatusName;
    }
    if (bloodTypeName != null && bloodTypeName.isNotEmpty) {
      map["blood_type_name"] = bloodTypeName;
    }

    repo.enqueue(
      endpoint: '/medical_info/update/${medicalInfoId}',
      method: 'PUT',
      payload: map,
    );
  }

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