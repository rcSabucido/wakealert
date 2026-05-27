import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakealert/signup/Allset.dart';

class OnboardingPermissions extends StatefulWidget {
  final bool fromLogin;

  const OnboardingPermissions({super.key, required this.fromLogin});

  @override
  State<OnboardingPermissions> createState() => _OnboardingPermissionsState();
}

class _OnboardingPermissionsState extends State<OnboardingPermissions> {
  bool _locationAllowed = false;
  bool _bluetoothAllowed = false;
  bool _smsAllowed = false;
  bool _callingAllowed = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final loc = await Permission.locationAlways.status;
    final bt  = await Permission.bluetoothScan.status;
    final sms = await Permission.sms.status;
    final call  = await Permission.phone.status;

    if (mounted) {
      setState(() {
        _locationAllowed  = loc.isGranted;
        _bluetoothAllowed = bt.isGranted;
        _smsAllowed       = sms.isGranted;
        _callingAllowed   = call.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            // Caption text pinned at the top
            const Text(
              "Before you proceed please allow\nthese permissions for the\n app to function properly.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Location Permission Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    backgroundColor: _locationAllowed
                        ? Colors.redAccent
                        : const Color(0xFFF4EEEE),
                    foregroundColor: _locationAllowed
                        ? Colors.white
                        : const Color(0xFFFF6961),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    var status = await Permission.location.request();
                    print('location status = $status');
                    if (!status.isGranted) {
                      debugPrint("[Permissions] Permission.location not granted!");
                      return;
                    }
                    status = await Permission.locationAlways.request();
                    print('locationAlways status = $status');
                    if (!status.isGranted) {
                      debugPrint("[Permissions] Permission.locationAlways not granted!");
                      return;
                    }
                    setState(() {
                      _locationAllowed = true;
                    });
                  },
                  child: _locationAllowed
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : const Text("Allow", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bluetooth Permission Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bluetooth",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    backgroundColor: _bluetoothAllowed
                        ? Colors.redAccent
                        : const Color(0xFFF4EEEE),
                    foregroundColor: _bluetoothAllowed
                        ? Colors.white
                        : const Color(0xFFFF6961),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    var status = await Permission.bluetoothScan.request();
                    print('bluetoothScan status = $status');
                    if (!status.isGranted) {
                      debugPrint("[Permissions] Permission.bluetoothScan not granted!");
                      return;
                    }
                    status = await Permission.bluetoothConnect.request();
                    print('bluetoothConnect status = $status');
                    if (!status.isGranted) {
                      debugPrint("[Permissions] Permission.bluetoothConnect not granted!");
                      return;
                    }
                    status = await Permission.bluetooth.request();
                    print('bluetooth status = $status');
                    if (!status.isGranted) {
                      debugPrint("[Permissions] Permission.bluetooth not granted!");
                      return;
                    }
                    setState(() {
                      _bluetoothAllowed = true;
                    });
                  },
                  child: _bluetoothAllowed
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : const Text("Allow", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SMS Permission Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Send Text Messages",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    backgroundColor: _smsAllowed
                        ? Colors.redAccent
                        : const Color(0xFFF4EEEE),
                    foregroundColor: _smsAllowed
                        ? Colors.white
                        : const Color(0xFFFF6961),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final status = await Permission.sms.request();
                    print('sms status = $status');
                    if (!status.isGranted) {
                      debugPrint("[Permissions] Permission.sms not granted!");
                      return;
                    }
                    setState(() {
                      _smsAllowed = true;
                    });
                  },
                  child: _smsAllowed
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : const Text("Allow", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Calling Permission Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Make Calls",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    backgroundColor: _callingAllowed
                        ? Colors.redAccent
                        : const Color(0xFFF4EEEE),
                    foregroundColor: _callingAllowed
                        ? Colors.white
                        : const Color(0xFFFF6961),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final status = await Permission.phone.request();
                    print('phone status = $status');
                    if (!status.isGranted) {
                      debugPrint("[Permissions] Permission.phone not granted!");
                      return;
                    }
                    setState(() {
                      _callingAllowed = true;
                    });
                  },
                  child: _callingAllowed
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : const Text("Allow", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),

            const Spacer(),

            // Thank you message appears only when all are allowed
            if (_locationAllowed && _bluetoothAllowed && _smsAllowed && _callingAllowed) ...[
              const SizedBox(height: 0),
              const Text(
                "Thank you! for your\nCooperation.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const Spacer(),
          ],
        ),
      ),

      // Bottom Navigation Buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, size: 24),
            ),

            // Next Button
            SizedBox(
              width: 140,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_locationAllowed && _bluetoothAllowed && _callingAllowed && _locationAllowed) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllSetPage(fromLogin: widget.fromLogin)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please allow all permissions to continue")),
                    );
                  }
                },
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
