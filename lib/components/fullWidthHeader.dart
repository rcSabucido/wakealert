import 'package:flutter/material.dart';

class FullWidthHeader extends StatelessWidget {
  final String text;

  const FullWidthHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6961),
      ),
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Container(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}