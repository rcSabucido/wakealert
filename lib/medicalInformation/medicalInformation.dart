import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/medicalInformation/lastDiagnosis.dart';
import 'package:wakealert/medicalInformation/allergies.dart';
import 'package:wakealert/medicalInformation/medicalHistory.dart';
import 'package:wakealert/medicalInformation/currentMedication.dart';
import 'package:wakealert/prefs_names.dart' as PrefsNames;

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  List<String> selectedDiagnosis = [];
  List<String>? selectedAllergies;
  List<String>? selectedHistory;
  List<String>? selectedMedications;

  String? diagnosisDate;
  String? hospital;
  String? medicalNotes;

  bool _otherPressed = false;

  @override
  void initState() {
    super.initState();

    _loadInfo();
  }

  void _loadInfo() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        selectedAllergies = prefs.getStringList(PrefsNames.ALLERGIES);
        selectedMedications = prefs.getStringList(PrefsNames.MEDICATION);
        selectedHistory = prefs.getStringList(PrefsNames.MEDICAL_HISTORY);

        final _sd = prefs.getString(PrefsNames.LAST_DIAGNOSIS);
        if (_sd != null) {
          selectedDiagnosis = [_sd];
        }

        diagnosisDate = prefs.getString(PrefsNames.LAST_DIAGNOSIS_DATE);
        hospital = prefs.getString(PrefsNames.PLACE_OF_DIAGNOSIS);
        medicalNotes = prefs.getString(PrefsNames.MEDICAL_NOTES) ?? "";
      });
    });
  }

  //  NAVIGATION FUNCTIONS
  void _showDiagnosisPicker() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DiagnosisModalPage(diagnosisOption: selectedDiagnosis ?? []),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _openAllergiesPicker() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AllergiesModalPage(allergyOptions: selectedAllergies ?? []),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _openHistoryPicker() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MedicalHistoryModalPage(historyOptions: selectedHistory ?? []),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _openMedicationPicker() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CurrentMedicationModalPage(medicationOptions: selectedMedications ?? []),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
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
                    child: Listener(
                      onPointerDown: (_) {
                        if (_otherPressed) {
                          Navigator.popUntil(context, ModalRoute.withName('/home'));
                          return;
                        }
                        Navigator.pop(context);
                      },
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
                    child: Listener(
                      onPointerDown: (_) => setState(() => _otherPressed = true),
                      onPointerUp: (_) => setState(() => _otherPressed = false),
                      onPointerCancel: (_) => setState(() => _otherPressed = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: const BoxDecoration(color: Color(0xFFEF5350)),
                        child: const Text("MEDICAL\nINFORMATION",
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                      ),
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
                                Expanded(
                                  flex: 2,
                                  child: InfoTile(
                                    label: "Diagnosis Date",
                                    value: diagnosisDate ?? "",
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
                    _buildDynamicGridSection("Allergies", selectedAllergies ?? [], true, _openAllergiesPicker),
                    const SizedBox(height: 16),
                    _buildDynamicGridSection("Medical History", selectedHistory ?? [], true, _openHistoryPicker),
                    const SizedBox(height: 16),
                    _buildDynamicGridSection("Current Medication", selectedMedications ?? [], true, _openMedicationPicker),
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