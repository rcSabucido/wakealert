import 'package:another_telephony/telephony.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart' as Flutterlibphonenumber;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/background_ble_service.dart';
import 'package:wakealert/database/database.dart';
import 'package:wakealert/database/outbox_dao.dart';
import 'package:wakealert/outbox/connectivity_outbox.dart';
import 'package:wakealert/outbox/outbox_processor.dart';
import 'package:wakealert/outbox/outbox_provider.dart';
import 'package:wakealert/outbox/outbox_repository.dart';
import 'package:wakealert/pages/contacts.dart';
import 'package:wakealert/pages/home.dart';
import 'package:wakealert/pages/onboarding.dart';
import 'package:wakealert/pages/settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakealert/pages/viewInformation.dart';

import 'package:wakealert/prefs_names.dart' as PrefsNames;

final String? _emergencyNumber = dotenv.env['EMERGENCY_NUMBER'];
  
final appDb = AppDatabase();
final outboxRepo = OutboxRepository(OutboxDao(appDb));
final Telephony telephony = Telephony.instance;

Future<void> main() async {
  debugPrint('Loading .env');
  await dotenv.load();
  await Flutterlibphonenumber.init();

  final prefs = await SharedPreferences.getInstance();

  final apiUrl = dotenv.env["API_URL"]!;
  final processor = OutboxProcessor(
    repository: outboxRepo,
    dio: Dio(BaseOptions(baseUrl: apiUrl)),
  );

  processor.start();

  final onboardingFinished = prefs.getBool(PrefsNames.ONBOARDING_FINISHED) ?? false;
  debugPrint("onboardingFinished? $onboardingFinished");
  if (onboardingFinished) {
    debugPrint('Starting ble service');
    initBackgroundBleService();
  } else {
    // Onboarding not finished, flush the queue first since fresh data is received after login/signup.
    await outboxRepo.flushQueue();
  }

  ConnectivityOutbox(processor: processor);
  runApp(MyApp(initialRoute: onboardingFinished ? '/home' : '/onboarding')); 
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
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
        colorScheme: .fromSeed(seedColor: const Color(0xFFFF6961)),
      ),
      routes: {
        '/onboarding':  (_) => const OnboardingPage(),
        '/alert':       (_) => ViewInformationPage(onBack: () {
            final service = FlutterBackgroundService();
            service.invoke('navigateTo', {'route': "/home"});
          },
        ),
        '/home':        (_) => const AppScreen(title: 'Flutter Demo Home Page'),
      },
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
  late final List<Widget> _pages = [
    HomePage(),
    ContactsPage(),
    SettingsPage(onSignOut: () => _signOut()),
  ];

  void _signOut() async {
    await outboxRepo.flushQueue();
    final service = FlutterBackgroundService();
    service.invoke('stopService');

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(PrefsNames.ONBOARDING_FINISHED, false);

    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', ModalRoute.withName('/'));
  }

  @override
  void initState() {
    super.initState();
    _listenForCalls();
  }

  void _listenForCalls() {
    final service = FlutterBackgroundService();

    // Listen for call requests from the background service
    service.on('triggerCall').listen((data) async {
      final phone = data ? ['phone'] as String?;
      if (phone != null) {
        await FlutterPhoneDirectCaller.callNumber(phone);
      }
    });
    service.on('navigateTo').listen((event) {
      final route = event ? ['route'] as String?;
      if (route != null && mounted) {
        Navigator.of(context).pushNamed(route);
      }
    });
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Widget buildNavigationItem(IconData? iconData, int index) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
          if (index == _currentIndex) {
          _navigatorKeys[index]
              .currentState!
              .popUntil((route) => route.isFirst);
        } else {
          setState(() => _currentIndex = index);
        }
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
    return OutboxProvider(
      repository: outboxRepo,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(3, (index) {
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) => _pages[index],
                );
              },
            );
          }),
        ),
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
              ],
            ),
          ),
        ),
      )
    );
  }
}
