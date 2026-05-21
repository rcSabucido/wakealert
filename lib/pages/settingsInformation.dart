import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/components/labeledDatePicker.dart';
import 'package:wakealert/components/settingsRedirect.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/labeledTextBox.dart';
import 'package:wakealert/pages/medicalInformation.dart';
import 'package:wakealert/pages/userAddressSettings.dart';

import 'package:wakealert/prefs_names.dart' as PrefsNames;
import 'package:wakealert/services/medical_history_service.dart';
import 'package:wakealert/services/medical_info_service.dart';
import 'package:wakealert/services/victim_service.dart';

class SettingsInformationPage extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsInformationPage({super.key, required this.onBack});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<SettingsInformationPage> createState() => _SettingsInformationPageState(onBack);
}

class _SettingsInformationPageState extends State<SettingsInformationPage> {
  late final VoidCallback onBack;
  int _currentIndex = -1;

  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController birthDateController = new TextEditingController();

  String? pregnancyStatusOption = "No";
  String? bloodTypeOption = "O-";
  String? organDonorOption = "No";

  _SettingsInformationPageState(this.onBack);

  void onBackSave() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(PrefsNames.FIRST_NAME, firstNameController.text);
      prefs.setString(PrefsNames.LAST_NAME, lastNameController.text);
      prefs.setString(PrefsNames.BIRTH_DATE, birthDateController.text);

      VictimService.enqueueUpdateVictim(
        context: context,
        victimId: prefs.getInt(PrefsNames.VICTIM_ID)!,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        birthDate: birthDateController.text
      );

      prefs.setString(PrefsNames.PREGNANCY_STATUS, pregnancyStatusOption!);
      prefs.setString(PrefsNames.BLOOD_TYPE, bloodTypeOption!);
      prefs.setString(PrefsNames.ORGAN_DONOR, organDonorOption!);

      MedicalInfoService.enqueueUpdateMedicalInfo(
        context: context,
        medicalInfoId: prefs.getInt(PrefsNames.MEDICAL_INFO_ID)!,
        allergies: prefs.getStringList(PrefsNames.ALLERGIES)!.join(", "),
        medication: prefs.getStringList(PrefsNames.MEDICATION)!.join(", "),
        medicalNotes: prefs.getString(PrefsNames.MEDICAL_NOTES),
        lastDiagnosisDate: prefs.getString(PrefsNames.LAST_DIAGNOSIS_DATE),
        lastDiagnosisHospitalName: prefs.getString(PrefsNames.PLACE_OF_DIAGNOSIS),
        pregnancyStatusName: prefs.getString(PrefsNames.PREGNANCY_STATUS),
        donorStatusName: prefs.getString(PrefsNames.ORGAN_DONOR),
        bloodTypeName: prefs.getString(PrefsNames.BLOOD_TYPE),
      );

      final diagnoses = prefs.getStringList(PrefsNames.MEDICAL_HISTORY)!;
      final lastDiagnosis = prefs.getString(PrefsNames.LAST_DIAGNOSIS);
      final index = lastDiagnosis != null ? diagnoses.indexOf(lastDiagnosis!) : -1;

      MedicalHistoryService.enqueueDeleteHistoryByInfo(
        context: context,
        medicalInfoId: prefs.getInt(PrefsNames.MEDICAL_INFO_ID)!,
      );
      MedicalHistoryService.enqueueUpsertDiagnosisList(
        context: context,
        medicalInfoId: prefs.getInt(PrefsNames.MEDICAL_INFO_ID)!,
        diagnoses: diagnoses,
        mostRecentIndex: index,
      );

      onBack();
    });
  }

  void onBackAdditional() {
    setState(() {
      _currentIndex = -1;
    });
  }

  late final List<Widget> _pages = [
    UserAddressSettingsPage(onBack: onBackAdditional),
    MedicalInformationPage(onBack: onBackAdditional),
  ];

  void loadInfo() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        firstNameController.text = prefs.getString(PrefsNames.FIRST_NAME) ?? "";
        lastNameController.text = prefs.getString(PrefsNames.LAST_NAME) ?? "";
        birthDateController.text = prefs.getString(PrefsNames.BIRTH_DATE) ?? "";

        pregnancyStatusOption = prefs.getString(PrefsNames.PREGNANCY_STATUS) ?? "No";
        debugPrint("pregnancyStatusOption $pregnancyStatusOption");
        organDonorOption = prefs.getString(PrefsNames.ORGAN_DONOR) ?? "No";
        debugPrint("organDonorOption $organDonorOption");
        bloodTypeOption = prefs.getString(PrefsNames.BLOOD_TYPE) ?? "O-";
        debugPrint("bloodTypeOption $bloodTypeOption");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadInfo();
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
      body: _currentIndex >= 0 ? _pages[_currentIndex] : Padding(
        padding: EdgeInsets.only(top: 32.0, left: 8.0, right: 8.0),
        child: ListView(
          children: [
            SubsectionHeader(
              title: "Information",
              onBack: onBackSave,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
              child: Text(
                "User Information:",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: LabeledDatePicker(
                label: "Birth Date:",
                controller: birthDateController,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: DropdownButtonFormField<String>(
                value: pregnancyStatusOption,
                decoration: const InputDecoration(
                  labelText: "Pregnancy Status:",
                  hintText: "Select pregnancy status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Yes", child: Text("Yes")),
                  DropdownMenuItem(value: "No", child: Text("No")),
                  DropdownMenuItem(value: "Unknown", child: Text("Unknown")),
                ],
                onChanged: (value) {
                  setState(() {
                    pregnancyStatusOption = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a pregnancy status";
                  }
                  return null;
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: DropdownButtonFormField<String>(
                value: organDonorOption,
                decoration: const InputDecoration(
                  labelText: "Organ Donor:",
                  hintText: "Select organ donor status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Yes", child: Text("Yes")),
                  DropdownMenuItem(value: "No", child: Text("No")),
                  DropdownMenuItem(value: "Unknown", child: Text("Unknown")),
                ],
                onChanged: (value) {
                  setState(() {
                    debugPrint("New value: $value");
                    organDonorOption = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select an organ donor status";
                  }
                  return null;
                },
              ),
            ),

            DropdownButtonFormField<String>(
              value: bloodTypeOption,
              decoration: const InputDecoration(
                labelText: "Blood Type:",
                hintText: "Select a blood type",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "O+", child: Text("O+")),
                DropdownMenuItem(value: "O-", child: Text("O-")),
                DropdownMenuItem(value: "A+", child: Text("A+")),
                DropdownMenuItem(value: "A-", child: Text("A-")),
                DropdownMenuItem(value: "B+", child: Text("B+")),
                DropdownMenuItem(value: "B-", child: Text("B-")),
                DropdownMenuItem(value: "AB+", child: Text("AB+")),
                DropdownMenuItem(value: "AB-", child: Text("AB-")),
                DropdownMenuItem(value: "Unknown", child: Text("Unknown")),
              ],
              onChanged: (value) {
                setState(() async {
                  bloodTypeOption = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a blood type";
                }
                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 8.0, top: 16.0, bottom: 6.0),
              child: Text(
                "Additional Information",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SettingsRedirect(
              title: "User Address",
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            SettingsRedirect(
              title: "User Medical Information",
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
