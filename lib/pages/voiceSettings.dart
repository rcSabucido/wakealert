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
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wakealert/prefs_names.dart' as PrefsNames;

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
  final List<String> englishVoices = [
    "en-AU-WilliamMultilingualNeural",
    "en-AU-NatashaNeural",
    "en-CA-ClaraNeural",
    "en-CA-LiamNeural",
    "en-HK-YanNeural",
    "en-HK-SamNeural",
    "en-IN-NeerjaExpressiveNeural",
    "en-IN-NeerjaNeural",
    "en-IN-PrabhatNeural",
    "en-IE-ConnorNeural",
    "en-IE-EmilyNeural",
    "en-KE-AsiliaNeural",
    "en-KE-ChilembaNeural",
    "en-NZ-MitchellNeural",
    "en-NZ-MollyNeural",
    "en-NG-AbeoNeural",
    "en-NG-EzinneNeural",
    "en-PH-JamesNeural",
    "en-PH-RosaNeural",
    "en-US-AvaNeural",
    "en-US-AndrewNeural",
    "en-US-EmmaNeural",
    "en-US-BrianNeural",
    "en-SG-LunaNeural",
    "en-SG-WayneNeural",
    "en-ZA-LeahNeural",
    "en-ZA-LukeNeural",
    "en-TZ-ElimuNeural",
    "en-TZ-ImaniNeural",
    "en-GB-LibbyNeural",
    "en-GB-MaisieNeural",
    "en-GB-RyanNeural",
    "en-GB-SoniaNeural",
    "en-GB-ThomasNeural",
    "en-US-AnaNeural",
    "en-US-AndrewMultilingualNeural",
    "en-US-AriaNeural",
    "en-US-AvaMultilingualNeural",
    "en-US-BrianMultilingualNeural",
    "en-US-ChristopherNeural",
    "en-US-EmmaMultilingualNeural",
    "en-US-EricNeural",
    "en-US-GuyNeural",
    "en-US-JennyNeural",
    "en-US-MichelleNeural",
    "en-US-RogerNeural",
    "en-US-SteffanNeural",
  ];

  late final VoidCallback onBack;

  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController editController = new TextEditingController();

  String? voiceAccent;
  String? voiceName;
  Set<String> voiceSpeedSelection = {"+0%"};
  Set<String> voicePitchSelection = {"+0Hz"};

  Iterable<Voice> allVoices = <Voice>[];
  Iterable<Voice> voices = <Voice>[];

  late AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadVoicesSelection();
    loadInfo();

    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> onBackSave() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefsNames.VOICE_ACCENT, voiceAccent!);
    prefs.setString(PrefsNames.VOICE_NAME, voiceName!);
    prefs.setString(PrefsNames.VOICE_SPEED, voiceSpeedSelection.first);
    prefs.setString(PrefsNames.VOICE_PITCH, voicePitchSelection.first);

    this.onBack();
  }

  void loadInfo() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        voiceAccent = prefs.getString(PrefsNames.VOICE_ACCENT) ?? "en-PH";
        voiceName = prefs.getString(PrefsNames.VOICE_NAME) ?? "en-PH-RosaNeural";
        voiceSpeedSelection = {prefs.getString(PrefsNames.VOICE_SPEED) ?? "+0%"};
        voicePitchSelection = {prefs.getString(PrefsNames.VOICE_PITCH) ?? "+0Hz"};
      });
    });
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
              onBack: onBackSave,
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
                DropdownMenuItem(value: "en-AU", child: Text("Australian English")),
                DropdownMenuItem(value: "en-CA", child: Text("Canadian English")),
                DropdownMenuItem(value: "en-HK", child: Text("Hong Kong English")),
                DropdownMenuItem(value: "en-IN", child: Text("Indian English")),
                DropdownMenuItem(value: "en-IE", child: Text("Irish English")),
                DropdownMenuItem(value: "en-KE", child: Text("Kenyan English")),
                DropdownMenuItem(value: "en-NZ", child: Text("New Zealand English")),
                DropdownMenuItem(value: "en-NG", child: Text("Nigerian English")),
                DropdownMenuItem(value: "en-SG", child: Text("Singaporean English")),
                DropdownMenuItem(value: "en-ZA", child: Text("South African English")),
                DropdownMenuItem(value: "en-TZ", child: Text("Tanzanian English")),
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
                voices.length > 0 ?
                  voices.map((v) =>
                    DropdownMenuItem(value: v.shortName, child: Text(v.shortName))
                  ).toList()
                  :
                  englishVoices.map((v) =>
                    DropdownMenuItem(value: v, child: Text(v))
                  ).toList()
                ,
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
                ButtonSegment(value: "-15%", label: Text(
                  'Slow',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
                ButtonSegment(value: "+0%", label: Text(
                  'Medium',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
                ButtonSegment(value: "+15%", label: Text(
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
                ButtonSegment(value: "-20Hz", label: Text(
                  'Deep',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
                ButtonSegment(value: "+0Hz", label: Text(
                  'Average',
                  style: const TextStyle(
                    fontSize: 12,
                  )
                )),
                ButtonSegment(value: "+20Hz", label: Text(
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
                  onPressed: onBackSave,
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
                      voice: voiceName ?? 'en-PH-JamesNeural',
                      rate: voiceSpeedSelection.first,
                      pitch: voicePitchSelection.first,
                      volume: '+20%',
                    );

                    debugPrint("TTS - Fetching sample");

                    final bytes = await tts.toBytes();

                    //final source = BytesSource(bytes, mimeType: "audio/mpeg");

                    /*
                    debugPrint("TTS Player - Setting source");
                    await player.setSource(source);
                    debugPrint("TTS Player - Resuming player");
                    await player.resume();
                    */

                    debugPrint("Sending speech samples via Bluetooth LE...");

                    FlutterBackgroundService().invoke('blobTransfer', {
                      'name': 'wake_word_detected.mp3',
                      'bytes': bytes,
                    });
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
