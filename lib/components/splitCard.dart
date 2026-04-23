import 'package:flutter/material.dart';

class SplitCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final double height;

  const SplitCard({
    Key? key,
    required this.text,
    required this.icon,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LEFT (25%)
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF6961),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),

          // RIGHT (75%)
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Text(
                text,
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}