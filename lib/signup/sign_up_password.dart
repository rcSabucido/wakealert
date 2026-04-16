import 'package:flutter/material.dart';
import 'package:wakealert/signup/primary_emergency_contact.dart';

class SignUpPassword extends StatefulWidget {
  const SignUpPassword({super.key});

  @override
  State<SignUpPassword> createState() => _SignUpPasswordState();
}

class _SignUpPasswordState extends State<SignUpPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showPasswords = false; // single toggle for both fields

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard on outside tap
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create a Password',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPasswords,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 15),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showPasswords,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Switch toggle to show/hide passwords
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch(
                      value: _showPasswords,
                      activeThumbColor: Colors.redAccent, // red toggle color
                      onChanged: (value) {
                        setState(() {
                          _showPasswords = value;
                        });
                      },
                    ),
                    const Text("Show Password"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, size: 24),
            ),
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
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrimaryEmergencyContact()),
                    );
                  }
                },
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
