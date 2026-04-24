import 'package:flutter/material.dart';
import 'package:wakealert/components/labeledDatePicker.dart';
import 'package:wakealert/components/settingsRedirect.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/labeledTextBox.dart';
import 'package:wakealert/pages/medicalInformation.dart';
import 'package:wakealert/pages/userAddressSettings.dart';

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

  String? pregnancyStatusOption;
  String? bloodTypeOption;
  String? organDonorOption;

  _SettingsInformationPageState(this.onBack);

  void onBackAdditional() {
    setState(() {
      _currentIndex = -1;
    });
  }

  late final List<Widget> _pages = [
    UserAddressSettingsPage(onBack: onBackAdditional),
    MedicalInformationPage(onBack: onBackAdditional),
  ];

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
              onBack: onBack,
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
              ],
              onChanged: (value) {
                setState(() {
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
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                "Additional Information",
                style: const TextStyle(
                  fontSize: 16,
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
