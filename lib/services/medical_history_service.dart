import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wakealert/outbox/outbox_provider.dart';

class MedicalHistoryEntry {
  final int historyEntryId;
  final int medicalInfoId;
  final String diagnosis;
  final bool isRecent;

  MedicalHistoryEntry({
    required this.historyEntryId,
    required this.medicalInfoId,
    required this.diagnosis,
    required this.isRecent,
  });

  factory MedicalHistoryEntry.fromJson(Map<String, dynamic> json) =>
      MedicalHistoryEntry(
        historyEntryId: json['history_entry_id'] as int,
        medicalInfoId: json['medical_info_id'] as int,
        diagnosis: json['diagnosis'] as String,
        isRecent: json['is_recent'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'history_entry_id': historyEntryId,
        'medical_info_id': medicalInfoId,
        'diagnosis': diagnosis,
        'is_recent': isRecent,
      };

  @override
  String toString() =>
      'MedicalHistoryEntry#$historyEntryId: $diagnosis (${isRecent ? "recent" : "old"})';
}

class MedicalHistoryService {
  static void enqueueUpsertDiagnosisList({
    required BuildContext context,
    required int medicalInfoId,
    required List<String> diagnoses,
    int? mostRecentIndex,
  }) {
    final repo = OutboxProvider.of(context);

    repo.enqueue(
      endpoint: '/medical_history',
      method: 'POST',
      payload: {
        "medical_info_id": medicalInfoId,
        "diagnoses": diagnoses,
        "most_recent_index": mostRecentIndex ?? -1,
      },
    );
  }

  static Future<List<MedicalHistoryEntry>> fetchByMedicalInfoId(
      int medicalInfoId) async {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$apiUrl/medical_history/$medicalInfoId');
    final resp = await http.get(uri);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to load history: ${resp.statusCode}');
    }

    final List<dynamic> list = jsonDecode(resp.body);
    return list.map((e) => MedicalHistoryEntry.fromJson(e)).toList();
  }
}