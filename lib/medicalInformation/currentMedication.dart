import 'package:flutter/material.dart';

class CurrentMedicationModalPage extends StatelessWidget {
  final List<String> initialSelection;

  const CurrentMedicationModalPage({super.key, required this.initialSelection});

  final List<String> medicationOptions = const [
    "Insulin", "Penicillin", "Morphine", "Vicodin", "Percocet", "Metformin",
    "Amlodipine", "Atorvastatin", "Albuterol", "Omeprazole", "Losartan",
    "Gabapentin", "Levothyroxine"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text("Current Medication",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: medicationOptions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE55A5A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(medicationOptions[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}