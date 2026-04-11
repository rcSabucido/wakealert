import 'package:flutter/material.dart';
import 'package:wakealert/pages/home.dart';
import 'package:wakealert/main.dart';

class AllSetPage extends StatelessWidget {
  const AllSetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 200,
                height: 140,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle, 
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 95),
              ),
              const SizedBox(height: 30),

            // Title
            const Text(
              "All set!",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Caption/description text
            const Text(
              "You’ll be signed in to your\naccount momentarily. If nothing\nhappens, click continue.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Continue button (wide)
            SizedBox(
              width: 356, // Full width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => AppBar()),
                  //   (route) => false, 
                  // );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
