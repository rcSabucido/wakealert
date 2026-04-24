import 'package:flutter/material.dart';
import 'package:wakealert/components/settingsRedirect.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/labeledTextBox.dart';
import 'package:wakealert/components/fullWidthButton.dart';
import 'package:wakealert/components/dropdown.dart';
import 'package:wakealert/components/splitCard.dart';

class WellnessCheckSettingsPage extends StatefulWidget {
  final VoidCallback onBack;

  const WellnessCheckSettingsPage({super.key, required this.onBack});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<WellnessCheckSettingsPage> createState() => _WellnessCheckSettingsPageState(onBack);
}

class _WellnessCheckSettingsPageState extends State<WellnessCheckSettingsPage> {
  late final VoidCallback onBack;

  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController editController = new TextEditingController();

  String? pregnancyStatusOption;
  String? wellnessCheckInterval;

  bool checkEnabled = true;

  _WellnessCheckSettingsPageState(this.onBack);

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
              title: "Wellness Check Settings",
              onBack: onBack,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: SplitCard(
                text: "At certain times, the system may ask for a response to confirm the user is present and in good condition. This feature is used to make sure everything is alright and you’re doing well!",
                icon: Icons.info_outline,
                height: 165,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                "Wellness check toggle",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: FullWidthButton(
                text: checkEnabled ? "Enabled" : "Disabled",
                color: checkEnabled ? const Color(0xFFFF6961) : const Color(0xFF555555),
                onPressed: () {
                  setState(() {
                    checkEnabled = !checkEnabled;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Text(
                "Wellness check interval",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: IgnorePointer(
                ignoring: !checkEnabled,
                child: DropdownButtonFormField<String>(
                value: wellnessCheckInterval,
                decoration: const InputDecoration(
                  hintText: "Select a wellness check interval",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "30", child: Text("30 minutes")),
                  DropdownMenuItem(value: "60", child: Text("60 minutes")),
                  DropdownMenuItem(value: "120", child: Text("12 minutes")),
                ],
                onChanged: (value) {
                  setState(() {
                    wellnessCheckInterval = value;    
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a wellness check interval";
                  }
                  return null;
                },
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
