import 'package:flutter/material.dart';

class FullWidthIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const FullWidthIconButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6961),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(size: 32, icon),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}