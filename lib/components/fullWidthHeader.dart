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
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6961),
      ),
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Container(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}