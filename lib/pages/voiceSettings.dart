import 'package:flutter/material.dart';
import 'package:wakealert/components/settingsRedirect.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/dropdown.dart';
import 'package:wakealert/components/fullWidthButton.dart';
import 'package:wakealert/components/labeledTextBox.dart';

import 'package:edge_tts/src/voices.dart';
import 'package:edge_tts/edge_tts.dart';

import 'package:audioplayers/audioplayers.dart';

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

  Iterable<Voice> allVoices = <Voice>[];
  Iterable<Voice> voices = <Voice>[];

  late AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadVoicesSelection();

    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
  }

  void loadSpecificVoices() async {
    if (voiceAccent != null) {
      final specificVoices = allVoices.where((v) {
        return v.locale.contains(voiceAccent!);
      });
      setState(() {
        voices = specificVoices;
      });
    }
  }

  void loadVoicesSelection() async {
    debugPrint('=== Voice listing ===');
    final manager = await VoicesManager.create();
    final englishVoices = manager.find(language: 'en');
    debugPrint('Found ${englishVoices.length} English voices:');
    for (final voice in englishVoices) {
      debugPrint('  ${voice.shortName} -> (${voice.gender}, ${voice.locale}, ${voice.language})');
    }
    setState(() {
      allVoices = englishVoices;
    });
  }

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
            DropdownButtonFormField<String>(
              value: voiceAccent,
              decoration: const InputDecoration(
                hintText: "Select an accent",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "en-PH", child: Text("Filipino English")),
                DropdownMenuItem(value: "en-US", child: Text("US English")),
                DropdownMenuItem(value: "en-GB", child: Text("UK English")),
              ],
              onChanged: (value) async {
                setState(() {
                  voiceAccent = value;
                  voiceName = null;
                });

                loadSpecificVoices();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select an accent";
                }
                return null;
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
            DropdownButtonFormField<String>(
              value: voiceName,
              decoration: const InputDecoration(
                hintText: "Select a voice",
                border: OutlineInputBorder(),
              ),
              items: 
                voices.map((v) =>
                  DropdownMenuItem(value: v.shortName, child: Text(v.shortName))
                ).toList(),
              onChanged: (value) {
                setState(() {
                  voiceName = value;    
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a voice name";
                }
                return null;
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
            SegmentedButton<String>(
              showSelectedIcon: false,
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
                ButtonSegment(value: "Slow", label: Text(
                  'Slow',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
                ButtonSegment(value: "Medium", label: Text(
                  'Medium',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
                ButtonSegment(value: "Fast", label: Text(
                  'Fast',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
              ],
              selected: voiceSpeedSelection,
              onSelectionChanged: (newSelection) {
                setState(() {
                  voiceSpeedSelection = newSelection;
                });
              },
              multiSelectionEnabled: false, // ensures only one is selected
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
            SegmentedButton<String>(
              showSelectedIcon: false,
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
                ButtonSegment(value: "Deep", label: Text(
                  'Deep',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
                ButtonSegment(value: "Average", label: Text(
                  'Average',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
                ButtonSegment(value: "High", label: Text(
                  'High',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
              ],
              selected: voicePitchSelection,
              onSelectionChanged: (newSelection) {
                setState(() {
                  voicePitchSelection = newSelection;
                });
              },
              multiSelectionEnabled: false, // ensures only one is selected
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: FullWidthButton(
                  text: "Save",
                  onPressed: onBack,
                ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: FullWidthButton(
                  text: "Temporary Debug Button",
                  onPressed: () async {
                    debugPrint('=== Fetching example speech ===');

                    final tts = Communicate(
                      text: 'Wake word detected. Do you want me to continue contacting your emergency contacts and emergency services?',
                      voice: 'en-PH-JamesNeural',
                      rate: '+0%',
                      pitch: '+0Hz',
                      volume: '+0%',
                    );

                    debugPrint("TTS Player - Fetching sample");

                    final bytes = await tts.toBytes();
                    final source = BytesSource(bytes, mimeType: "audio/mpeg");

                    debugPrint("TTS Player - Setting source");
                    await player.setSource(source);
                    debugPrint("TTS Player - Resuming player");
                    await player.resume();
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }

  childText(String s, {required TextStyle style}) {}
}
