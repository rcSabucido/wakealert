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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: double.infinity,
      color: const Color(0xFFFF6961),
      child: Container(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}