import 'package:flutter/material.dart';

class DiagnosisModalPage extends StatelessWidget {
  final List<String> initialSelection;

  const DiagnosisModalPage({super.key, required this.initialSelection});

  final List<String> options = const [
    "Diabetes (Type 2)", 
    "Asthma", 
    "Hypertension", 
    "High Blood Pressure", 
    "Osteoporosis",
    "Arthritis",
    "Hyperlipidemia",
    "Anxiety Disorder",
    "COPD",
    "Heart Disease"
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
                    child: Text("Last Diagnosis", 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 48), 
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE55A5A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(options[index], 
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