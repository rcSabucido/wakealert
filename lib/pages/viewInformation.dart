import 'package:flutter/material.dart';
import 'package:wakealert/medicalInformation/medicalInformation.dart';

class ViewInformationPage extends StatefulWidget {
  final VoidCallback onBack;

  const ViewInformationPage({super.key, required this.onBack});

  @override
  State<ViewInformationPage> createState() => _ViewInformationPageState();
}

class _ViewInformationPageState extends State<ViewInformationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar 
            Container(
              color: Colors.white, 
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF5350), // Active Tab
                      ),
                      child: const Text(
                        "USER\nINFORMATION",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25, 
                        ),
                      ),
                    ),
                  ),
                  // This is the small white space 
                  const SizedBox(width: 3), 
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            // Targets the MedicalInfoScreen
                            pageBuilder: (context, animation, secondaryAnimation) => const MedicalInfoScreen(),
                            // Removes the entrance animation
                            transitionDuration: Duration.zero,
                            // Removes the exit animation (when pressing back)
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[200], // Inactive Tab
                        ),
                        child: const Text(
                          "MEDICAL\nINFORMATION",
                          textAlign: TextAlign.right, // Better alignment for the "seamless" look
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 25, // Adjusted so it doesn't overflow
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT AREA
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 2, child: InfoTile(label: "Full Name", value: "Juan Dela Cruz")),
                      SizedBox(width: 12),
                      Expanded(flex: 1, child: InfoTile(label: "Blood Type", value: "A+")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(flex: 2, child: InfoTile(label: "Date of Birth", value: "YYYY/MM/DD")),
                      SizedBox(width: 12),
                      Expanded(flex: 1, child: InfoTile(label: "Age", value: "21")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(flex: 2, child: InfoTile(label: "Primary Contact", value: "09XXXXXXXXX")),
                      SizedBox(width: 12),
                      Expanded(flex: 1, child: InfoTile(label: "Relationship", value: "FAMILY")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const InfoTile(label: "Address", value: "Blk X Lot X Subdivision, Barangay, City"),
                  const SizedBox(height: 16),
                  const InfoTile(label: "Pregnancy Status", value: "Unknown"),
                  const SizedBox(height: 16),
                  const InfoTile(label: "Organ Donor", value: "Yes"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const InfoTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 16, 
              fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE55A5A),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}