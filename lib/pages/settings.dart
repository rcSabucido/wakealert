import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/components/fullWidthHeader.dart';
import 'package:wakealert/components/fullWidthIconButton.dart';
import 'package:wakealert/main.dart';
import 'package:wakealert/pages/settingsInformation.dart';
import 'package:wakealert/pages/viewInformation.dart';
import 'package:wakealert/pages/voiceSettings.dart';
import 'package:wakealert/pages/wellnessCheckSettings.dart';
import 'package:wakealert/prefs_names.dart' as PrefsNames;

class SettingsPage extends StatefulWidget {
  final VoidCallback onSignOut;

  const SettingsPage({super.key, required this.onSignOut});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _currentIndex = -1;

  void onBack() {
    Navigator.pop(context);
  }

  late final List<Widget> _pages = [
    SettingsInformationPage(onBack: onBack),
    VoiceSettingsPage(onBack: onBack),
    WellnessCheckSettingsPage(onBack: onBack),
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
      appBar: PreferredSize(preferredSize: const Size(double.infinity, 120), 
      child: _currentIndex == -1 ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6961),
            ),
            child: Center(
              child: Text(
                "SETTINGS",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                )
              )
            )
          )
        )
      ) : Container(),
      ),
      body: _currentIndex >= 0 ? _pages[_currentIndex] : Padding(
        padding: EdgeInsets.only(top: 14.0),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          children: [
            FullWidthIconButton(
              text: "Information",
              icon: Icons.info_outline,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _pages[0]),
                );
              },
            ),
            FullWidthIconButton(
              text: "Voice Settings",
              icon: Icons.spatial_audio_off_rounded,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _pages[1]),
                );
              },
            ),
            FullWidthIconButton(
              text: "Wellness Check",
              icon: Icons.mood_sharp,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _pages[2]),
                );
              },
            ),
            FullWidthIconButton(
              text: "Sign Out",
              icon: Icons.door_sliding_sharp,
              onPressed: () async {
                widget.onSignOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
