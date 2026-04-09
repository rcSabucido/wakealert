import 'package:flutter/material.dart';

class LabeledTextBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;

  const LabeledTextBox({
    Key? key,
    required this.label,
    required this.controller,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1),
            TextField(
              controller: controller,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: hintText ?? this.label,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}