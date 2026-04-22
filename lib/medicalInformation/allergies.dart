import 'package:flutter/material.dart';

class AllergiesModalPage extends StatelessWidget {
  final List<String> initialSelection;

  const AllergiesModalPage({super.key, required this.initialSelection});

  final List<String> allergyOptions = const [
    "Eczema", "Anaphylaxis", "Asthma", "Urticaria",
    "Allergic Rhinitis", "Shrimp", "Peanuts", "Dust Mites",
    "Penicillin", "Latex", "Pollen", "Cat Dander", "Dairy"
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
                    child: Text("Allergies",
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
                itemCount: allergyOptions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE55A5A),
                      borderRadius: BorderRadius.circular(8),
                      // Kept a subtle shadow to maintain your previous style
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Text(allergyOptions[index],
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