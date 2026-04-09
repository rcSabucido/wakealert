import 'package:flutter/material.dart';
import 'package:wakealert/components/fullWidthHeader.dart';
import 'package:wakealert/components/fullWidthIconButton.dart';
import 'package:wakealert/components/settingsRedirect.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/pages/labeledDropdown.dart';
import 'package:wakealert/pages/labeledTextBox.dart';

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

  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController editController = new TextEditingController();

  String? pregnancyStatusOption;

  _SettingsInformationPageState(this.onBack);

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
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                "User Information:",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            LabeledTextBox(
              label: "First Name",
              controller: firstNameController,
            ),
            LabeledTextBox(
              label: "Last Name",
              controller: lastNameController,
            ),
            LabeledTextBox(
              label: "Birth Date",
              controller: editController,
            ),
            LabeledDropdown<String>(
              label: "Pregnancy Status",
              value: pregnancyStatusOption,
              items: [
                DropdownMenuItem(value: "Yes", child: Text("Yes")),
                DropdownMenuItem(value: "No", child: Text("No")),
                DropdownMenuItem(value: "Unknown", child: Text("Unknown")),
              ],
              onChanged: (value) {
                pregnancyStatusOption = value;
              },
            ),
            LabeledTextBox(
              label: "Organ Donor",
              controller: editController,
            ),
            LabeledTextBox(
              label: "Blood Type",
              controller: editController,
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
              onPressed: onBack,
            ),
            SettingsRedirect(
              title: "User Medical Information",
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
