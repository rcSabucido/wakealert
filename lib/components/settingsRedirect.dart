import 'package:flutter/material.dart';

class SettingsRedirect extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const SettingsRedirect({
    Key? key,
    required this.title,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed ?? () => Navigator.of(context).pop(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: const Icon(Icons.arrow_right_sharp),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}