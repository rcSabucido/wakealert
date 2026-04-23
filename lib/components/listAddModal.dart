import 'package:flutter/material.dart';

class ListAddModal extends StatelessWidget {
  final String title;
  final List<String> list;
  final String addButtonText;

  const ListAddModal(
    {required this.title,
      required this.list,
      required this.addButtonText
    });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 24.0,
      backgroundColor: Colors.transparent, // Remove standard dialog background
      child: Container(
        child: Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 18.0),
          child: Text(
            "Medical Information",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}