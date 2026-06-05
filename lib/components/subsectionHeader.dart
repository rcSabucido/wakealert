import 'package:flutter/material.dart';

class SubsectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final bool? isDisabled;

  const SubsectionHeader({
    Key? key,
    required this.title,
    this.isDisabled,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: (isDisabled != null && isDisabled!) ? () {} : onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}