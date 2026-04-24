import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:wakealert/components/addDiagnosisModal.dart';

class LabeledDiagnosisBox extends StatelessWidget {
  final String label;
  final String? selected;
  final String? lastDiagnosisDate;
  final String? hospital;
  final List<String> medicalHistory;
  final void Function(HashMap) onChanged;

  const LabeledDiagnosisBox({
    Key? key,
    required this.label,
    required this.selected,
    required this.lastDiagnosisDate,
    required this.hospital,
    required this.medicalHistory,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: InkWell(
        onTap: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => AddDiagnosisModal(
              items: medicalHistory,
              selected: selected,
              lastDiagnosisDate: lastDiagnosisDate,
              hospital: hospital,
              onChanged: onChanged
            ),
          );

          if (result != null) {
            onChanged(result);
          }
        },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$label:",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                selected ?? "None",
                maxLines: 1,
                overflow: TextOverflow.ellipsis
              ),
            ]
          ),
        ),
      ),
    );
  }
}