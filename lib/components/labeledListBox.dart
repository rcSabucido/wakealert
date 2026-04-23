import 'package:flutter/material.dart';

class LabeledListBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;

  const LabeledListBox({
    Key? key,
    required this.label,
    required this.controller,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}