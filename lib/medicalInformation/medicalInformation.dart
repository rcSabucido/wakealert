import 'package:flutter/material.dart';
import 'package:wakealert/medicalInformation/lastDiagnosis.dart';
import 'package:wakealert/medicalInformation/allergies.dart';
import 'package:wakealert/medicalInformation/medicalHistory.dart';
import 'package:wakealert/medicalInformation/currentMedication.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  List<String> selectedDiagnosis = ["Diabetes (Type 2)"];
  List<String> selectedAllergies = ["Eczema", "Anaphylaxis"];
  List<String> selectedHistory = ["Diabetes (Type 2)", "Asthma", "Hypertension"];
  List<String> selectedMedications = ["Insulin", "Penicillin", "Morphine", "Metformin"];

  //  NAVIGATION FUNCTIONS
  void _showDiagnosisPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisModalPage(initialSelection: selectedDiagnosis),
      ),
    );
  }

  void _openAllergiesPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllergiesModalPage(initialSelection: selectedAllergies),
      ),
    );
  }

  void _openHistoryPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalHistoryModalPage(initialSelection: selectedHistory),
      ),
    );
  }

  void _openMedicationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentMedicationModalPage(initialSelection: selectedMedications),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(color: Colors.blueGrey[200]),
                        child: const Text("USER\nINFORMATION",
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 25)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: const BoxDecoration(color: Color(0xFFEF5350)),
                      child: const Text("MEDICAL\nINFORMATION",
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // GROUPED DIAGNOSIS SECTION
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B), // Group Background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: InfoTile(
                                    label: "Last Diagnosis",
                                    value: selectedDiagnosis.isNotEmpty ? selectedDiagnosis[0] : "None",
                                    showIcon: true,
                                    onIconTap: _showDiagnosisPicker,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  flex: 2,
                                  child: InfoTile(
                                    label: "Diagnosis Date",
                                    value: "YYYY-MM-DD",
                                    showIcon: true, // Keep true for alignment
                                    hideIconVisually: true, // New property to hide it
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const InfoTile(
                            label: "Place of Diagnosis",
                            value: "Davao Doctors Hospital",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDynamicGridSection("Allergies", selectedAllergies, true, _openAllergiesPicker),
                    const SizedBox(height: 16),
                    _buildDynamicGridSection("Medical History", selectedHistory, true, _openHistoryPicker),
                    const SizedBox(height: 16),
                    _buildDynamicGridSection("Current Medication", selectedMedications, true, _openMedicationPicker),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REUSABLE GRID BUILDER
  Widget _buildDynamicGridSection(String title, List<String> items, bool showIcon, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon) const SizedBox(width: 20),
              Expanded(
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
              ),
              if (showIcon)
                GestureDetector(
                  onTap: onTap,
                  child: const Icon(Icons.fullscreen, color: Colors.white70, size: 22),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              for (int i = 0; i < items.length; i += 2)
                if (i + 1 < items.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildSmallInnerBox(items[i])),
                        const SizedBox(width: 10),
                        Expanded(child: _buildSmallInnerBox(items[i + 1])),
                      ],
                    ),
                  )
                else
                  _buildSmallInnerBox(items[i]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInnerBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE55A5A),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 2),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool showIcon;
  final bool hideIconVisually; 
  final VoidCallback? onIconTap;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.showIcon = false,
    this.hideIconVisually = false,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon) const SizedBox(width: 14.5),
              Expanded(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
              ),
              if (showIcon)
                Visibility(
                  visible: !hideIconVisually,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: GestureDetector(
                    onTap: onIconTap,
                    child: const Icon(Icons.fullscreen, color: Colors.white70, size: 22),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE55A5A),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 2),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}