import 'package:flutter/material.dart';

class FullWidthProgressButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Color? progressColor;
  final bool? isBold;
  final double progress; // 0.0 to 1.0

  const FullWidthProgressButton({
    Key? key,
    required this.onPressed,
    required this.progress,
    this.isBold,
    this.color,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Button background
            Container(
              color: buttonColor,
            ),

            // Progress background
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                color: progressColor ?? const Color(0xFFFF6961), // Colors.black.withOpacity(0.2),
              ),
            ),

            // Button content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                child: Center(
                  child: Text(
                    "${(progress * 100).toInt()}%",
                    style: TextStyle(
                      color: Colors.black, //const Color(0xFFFF6961),
                      fontSize: 16,
                      fontWeight: isBold != null && isBold!
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}