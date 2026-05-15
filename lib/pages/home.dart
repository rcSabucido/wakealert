import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPaired = false;
  StreamSubscription? _bleSub;
  int batteryPercentage = 75;

  @override
  void initState() {
    super.initState();
    _listenToState();
  }

  void _listenToState() {
    _bleSub = FlutterBackgroundService()
        .on('bleState')
        .listen((data) {
      if (data == null) return;
      setState(() {
        switch (data['state'] as String) {
          case 'connected':
            setState(() {
              _isPaired = true;
            });
          case 'disconnected':
            setState(() {
              _isPaired = false;
            });
          /*
          case 'scanning':
          */
        }
      });
    });
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
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 120),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6961),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: DefaultTextStyle(
                          style: const TextStyle(color: Colors.white),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Text(
                                "Welcome back,",
                                style: TextStyle(fontSize: 12)
                                ),
                                SizedBox(height: 1),
                              Text(
                                "John Doe",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  ),
                              )
                            ],
                          ),
                        )
                      )
                    )
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40.0),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 22)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ),
      body: Center(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pair your WakeAlert device to your Bluetooth",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50, bottom: 40),
              child: _isPaired 
              ? SizedBox(
                width: 220,
                height: 220,
                child: LiquidCircularProgressIndicator(
                  value: math.max(
                    math.min(100.0, batteryPercentage / 100.0),
                    0,
                  ),
                  valueColor: AlwaysStoppedAnimation(
                    const Color(0xFFFF6961),
                  ),
                  backgroundColor: const Color(0xFFF4EEEE),
                  direction: Axis.vertical,
                  center: Text(
                    "$batteryPercentage%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                )
              ) 
              : RippleAnimation(
                color: const Color(0xFFFF6961),
                delay: const Duration(milliseconds: 300),
                repeat: true,
                minRadius: 64,
                maxRadius: 80,
                ripplesCount: 6,
                duration: const Duration(milliseconds: 3000),
                child: CircleAvatar(
                  minRadius: 110,
                  maxRadius: 110,
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.bluetooth),
                      ),
                    )
                  )
                )
              )
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isPaired ? const Color(0xFFFF6961) : const Color(0xFFF4EEEE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 3,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 35, right: 35, top: 11, bottom: 11),
                child: Text(
                  _isPaired ? "Paired" : "Pairing", 
                  style: TextStyle(
                  color: _isPaired ? Colors.white : const Color(0xFFFF6961) ,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
                )
              )
            )
          ],
        ),
      ),
    );
  }
}
