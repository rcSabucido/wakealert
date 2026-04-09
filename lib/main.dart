import 'package:flutter/material.dart';
import 'package:wakealert/pages/contacts.dart';
import 'package:wakealert/pages/home.dart';
import 'package:wakealert/pages/onboarding.dart';
import 'package:wakealert/pages/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class AppScreen extends StatefulWidget {
  const AppScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _NeumorphicInset extends StatelessWidget {
  final Widget child;

  const _NeumorphicInset({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                    const Color(0xFFFF534A),
                    const Color(0xFFFF6961),
                ],
              ),
            ),
          ),

          // top inner shadow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),

          // bottom highlight
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: Center(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppScreenState extends State<AppScreen> {
  int _counter = 0;
  int _currentIndex = 0;


  // List of widgets for each page
  final List<Widget> _pages = [
    HomePage(),
    ContactsPage(),
    SettingsPage(),
    OnboardingPage(),
  ];

  Widget buildNavigationItem(IconData? iconData, int index) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: SizedBox(
        width: 72,
        height: 48,
        child: Center(
          child: isSelected
              ? _NeumorphicInset(
                  child: Icon(iconData, color: Colors.white),
                )
              : Icon(iconData, color: Colors.black),
        ),
      ),
    );
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
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavigationItem(Icons.home, 0),
              buildNavigationItem(Icons.contacts, 1),
              buildNavigationItem(Icons.settings, 2),
              buildNavigationItem(Icons.person_pin_circle, 3),
            ],
          ),
        ),
      ),
    );
  }
}
