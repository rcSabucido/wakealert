import 'package:flutter/material.dart';

class LabeledDatePicker extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Color? backgroundColor;
  final void Function(String)? onChanged;

  const LabeledDatePicker({
    Key? key,
    required this.label,
    required this.controller,
    this.hintText,
    this.firstDate,
    this.lastDate,
    this.backgroundColor,
    this.onChanged,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      onChanged!(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
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
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              readOnly: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: hintText ?? "Select date",
                border: InputBorder.none,
                isDense: true,
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}