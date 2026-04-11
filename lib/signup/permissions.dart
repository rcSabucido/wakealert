import 'package:flutter/material.dart';
import 'package:wakealert/signup/Allset.dart';

class OnboardingPermissions extends StatefulWidget {
  const OnboardingPermissions({super.key});

  @override
  State<OnboardingPermissions> createState() => _OnboardingPermissionsState();
}

class _OnboardingPermissionsState extends State<OnboardingPermissions> {
  bool _locationAllowed = false;
  bool _bluetoothAllowed = false;

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
                  onPressed: () {
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
                  onPressed: () {
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

             const Spacer(),


            // Thank you message appears only when both are allowed
            if (_locationAllowed && _bluetoothAllowed) ...[
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
                  if (_locationAllowed && _bluetoothAllowed) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllSetPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please allow both permissions to continue")),
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
