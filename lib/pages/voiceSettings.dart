import 'package:flutter/material.dart';
import 'package:wakealert/components/settingsRedirect.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/dropdown.dart';
import 'package:wakealert/components/fullWidthButton.dart';
import 'package:wakealert/components/labeledTextBox.dart';

class VoiceSettingsPage extends StatefulWidget {
  final VoidCallback onBack;

  const VoiceSettingsPage({super.key, required this.onBack});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<VoiceSettingsPage> createState() => _VoiceSettingsPageState(onBack);
}

class _VoiceSettingsPageState extends State<VoiceSettingsPage> {
  late final VoidCallback onBack;

  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController editController = new TextEditingController();

  String? voiceAccent;
  String? voiceName;
  Set<String> voiceSpeedSelection = {"Medium"};
  Set<String> voicePitchSelection = {"Average"};

  _VoiceSettingsPageState(this.onBack);

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
              title: "Voice Settings",
              onBack: onBack,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text(
                "Voice Accent",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Dropdown<String>(
              value: voiceAccent,
              items: [
                DropdownMenuItem(value: "en-PH", child: Text("Filipino")),
                DropdownMenuItem(value: "en-US", child: Text("US English")),
                DropdownMenuItem(value: "en-GB", child: Text("UK English")),
              ],
              onChanged: (value) {
                setState(() {
                  voiceAccent = value;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text(
                "Voice Name",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Dropdown<String>(
              value: voiceName,
              items: [
                DropdownMenuItem(value: "rn", child: Text("Rosa Normal")),
                DropdownMenuItem(value: "an", child: Text("Adrian Normal")),
                DropdownMenuItem(value: "jn", child: Text("John Normal")),
              ],
              onChanged: (value) {
                setState(() {
                  voiceName = value;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text(
                "Voice Speed",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: SegmentedButton<String>(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)){
                          return const Color(0xFFFF6961);
                        }
                        return Colors.white;
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)){
                          return Colors.white;
                        }
                        return const Color(0xFFFF6961);
                      },
                    ),
                  ),
                  segments: const [
                    ButtonSegment(value: "Slow", label: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Slow'))),
                    ButtonSegment(value: "Medium", label: Text('Medium')),
                    ButtonSegment(value: "Fast", label: Text('Fast')),
                  ],
                  selected: voiceSpeedSelection,
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      voiceSpeedSelection = newSelection;
                    });
                  },
                  multiSelectionEnabled: false, // ensures only one is selected
                ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text(
                "Voice Pitch",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: SegmentedButton<String>(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)){
                          return const Color(0xFFFF6961);
                        }
                        return Colors.white;
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)){
                          return Colors.white;
                        }
                        return const Color(0xFFFF6961);
                      },
                    ),
                  ),
                  segments: const [
                    ButtonSegment(value: "Deep", label: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Deep'))),
                    ButtonSegment(value: "Average", label: Text('Average')),
                    ButtonSegment(value: "High", label: Text('High')),
                  ],
                  selected: voicePitchSelection,
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      voicePitchSelection = newSelection;
                    });
                  },
                  multiSelectionEnabled: false, // ensures only one is selected
                ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: FullWidthButton(
                  text: "Save",
                  onPressed: onBack,
                ),
            ),
          ],
        ),
      ),
    );
  }
}
