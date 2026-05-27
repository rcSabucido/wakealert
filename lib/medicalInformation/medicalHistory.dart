import 'package:flutter/material.dart';

class MedicalHistoryModalPage extends StatelessWidget {
  final List<String> historyOptions;

  const MedicalHistoryModalPage({super.key, required this.historyOptions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER SECTION
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Medical History",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Close button
                ],
              ),
            ),

            // LIST OF OPTIONS
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: historyOptions.length,
                itemBuilder: (context, index) {
                  final option = historyOptions[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      // Standard background for all items, no highlights
                      color: const Color(0xFFE55A5A), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 18, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  );
                },
              ),
            ),
            // Confirm button has been removed as requested
          ],
        ),
      ),
    );
  }
}