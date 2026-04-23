import 'package:flutter/material.dart';
import 'package:wakealert/components/labeledListBox.dart';
import 'package:wakealert/components/settingsRedirect.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/labeledTextBox.dart';

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

  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController editController = new TextEditingController();

  List<String> allergies = [
    "Eczema", "Anaphylaxis", "Asthma", "Urticaria",
    "Allergic Rhinitis", "Shrimp", "Peanuts", "Dust Mites",
    "Penicillin", "Latex", "Pollen", "Cat Dander", "Dairy"
  ];
  List<String> medication = [
    "Insulin", "Penicillin", "Morphine", "Vicodin", "Percocet", "Metformin",
    "Amlodipine", "Atorvastatin", "Albuterol", "Omeprazole", "Losartan",
    "Gabapentin", "Levothyroxine"
  ];
  List<String> medicalHistory = const [
    "Diabetes (Type 2)", 
    "Asthma", 
    "Hypertension", 
    "High Blood Pressure", 
    "Osteoporosis", 
    "Arthritis",
    "Heart Disease",
    "Thyroid Disorder",
    "Chronic Kidney Disease",
    "Anemia",
    "Epilepsy",
    "High Cholesterol"
  ];

  String? lastDiagnosisOption;

  _MedicalInformationPageState(this.onBack);

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
              onBack: onBack,
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
              onChanged: (items) {
                setState(() {
                  allergies = items;
                });
              }
            ),
            LabeledListBox(
              label: "Medication",
              items: medication,
              onChanged: (items) {
                setState(() {
                  medication = items;
                });
              }
            ),
            LabeledListBox(
              label: "Medical History",
              items: medicalHistory,
              onChanged: (items) {
                setState(() {
                  medicalHistory = items;
                });
              }
            ),
            LabeledDropdown<String>(
              label: "Last Diagnosis:",
              value: lastDiagnosisOption,
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
            LabeledTextBox(
              label: "Medical Notes:",
              controller: editController,
            ),
          ],
        ),
      ),
    );
  }
}
