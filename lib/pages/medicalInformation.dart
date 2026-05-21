import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/components/labeledDiagnosisBox.dart';
import 'package:wakealert/components/labeledListBox.dart';
import 'package:wakealert/components/settingsRedirect.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/labeledTextBox.dart';
import 'package:wakealert/prefs_names.dart' as PrefsNames;

class MedicalInformationPage extends StatefulWidget {
  final VoidCallback onBack;

  const MedicalInformationPage({super.key, required this.onBack});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MedicalInformationPage> createState() => _MedicalInformationPageState(onBack);
}

class _MedicalInformationPageState extends State<MedicalInformationPage> {
  late final VoidCallback onBack;

  final TextEditingController medicalNotesController = new TextEditingController();

  List<String> allergies = [""];
  List<String> medication = [""];
  List<String> medicalHistory = [""];

  String? lastDiagnosisOption;
  String? lastDiagnosisDate;
  String? hospital;

  _MedicalInformationPageState(this.onBack);

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  void _loadMedicalInfo() {
    SharedPreferences.getInstance().then((prefs) {
      _loadContactsState(prefs);
    });
  }

  void _loadContactsState(SharedPreferences prefs) {
    debugPrint("Medical info sharedprefs loaded");

    setState(() {
      allergies = prefs.getStringList(PrefsNames.ALLERGIES)!;
      medication = prefs.getStringList(PrefsNames.MEDICATION)!;
      medicalHistory = prefs.getStringList(PrefsNames.MEDICAL_HISTORY)!;
      lastDiagnosisOption = prefs.getString(PrefsNames.LAST_DIAGNOSIS);
      lastDiagnosisDate = prefs.getString(PrefsNames.LAST_DIAGNOSIS_DATE);
      hospital = prefs.getString(PrefsNames.PLACE_OF_DIAGNOSIS);
      medicalNotesController.text = prefs.getString(PrefsNames.MEDICAL_NOTES) ?? "";
    });
  }

  void onBackSave() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(PrefsNames.ALLERGIES, allergies);
      prefs.setStringList(PrefsNames.MEDICATION, medication);
      prefs.setStringList(PrefsNames.MEDICAL_HISTORY, medicalHistory);
      prefs.setString(PrefsNames.LAST_DIAGNOSIS, lastDiagnosisOption ?? "");
      prefs.setString(PrefsNames.LAST_DIAGNOSIS_DATE, lastDiagnosisDate ?? "");
      prefs.setString(PrefsNames.PLACE_OF_DIAGNOSIS, hospital ?? "");
      prefs.setString(PrefsNames.MEDICAL_NOTES, medicalNotesController.text);

      onBack();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 32.0, left: 8.0, right: 8.0),
        child: ListView(
          children: [
            SubsectionHeader(
              title: "Information",
              onBack: onBackSave,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Text(
                "Medical Information",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            LabeledListBox(
              label: "Allergies",
              items: allergies,
              addText: "Add Allergy",
              onChanged: (items) {
                setState(() {
                  allergies = items;
                });
              }
            ),
            LabeledListBox(
              label: "Medication",
              items: medication,
              addText: "Add Medication",
              onChanged: (items) {
                setState(() {
                  debugPrint("New medication list: ${medication}");
                  medication = items;
                });
              }
            ),
            LabeledListBox(
              label: "Medical History",
              items: medicalHistory,
              addText: "Add Medical Condition",
              onChanged: (items) {
                setState(() {
                  medicalHistory = items;
                });
              }
            ),
            /*
            LabeledDropdown<String>(
              label: "Last Diagnosis:",
              value: lastDiagnosisOption != null &&
                medicalHistory.contains(lastDiagnosisOption) ?
                lastDiagnosisOption : medicalHistory[0],
              items: [
                for (var str in medicalHistory)
                  DropdownMenuItem(value: str, child: Text(str)),
              ],
              onChanged: (value) {
                setState(() {
                  lastDiagnosisOption = value;
                });
              },
            ),
            */
            LabeledDiagnosisBox(
              label: "Last Diagnosis",
              medicalHistory: medicalHistory,
              lastDiagnosisDate: lastDiagnosisDate,
              hospital: hospital,
              selected: lastDiagnosisOption != null &&
              medicalHistory.contains(lastDiagnosisOption) ?
              lastDiagnosisOption : medicalHistory[0],
              onChanged: (resultMap) {
                setState(() {
                  if (resultMap.containsKey("lastDiagnosis")) {
                    lastDiagnosisOption = resultMap["lastDiagnosis"];
                  }
                  if (resultMap.containsKey("hospital")) {
                    hospital = resultMap["hospital"];
                  }
                  if (resultMap.containsKey("lastDiagnosisDate")) {
                    lastDiagnosisDate = resultMap["lastDiagnosisDate"];
                  }
                });
              }
            ),
            LabeledTextBox(
              label: "Medical Notes:",
              controller: medicalNotesController,
            ),
          ],
        ),
      ),
    );
  }
}
