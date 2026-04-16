import 'package:flutter/material.dart';
import 'package:wakealert/Login/login.dart';
import 'package:wakealert/signup/sign_Up.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center (
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20), // rounded corners
              ),
              child: const Icon(Icons.sos, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 20), 

            const Text(
              'Welcome to WakeAlert',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Hello World',
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Login Button
            SizedBox(
              width: 335,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login'),
              ),
            ),
            const SizedBox(height: 8),

            // Sign Up Button
            SizedBox(
              width: 335,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
