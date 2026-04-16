import 'package:flutter/material.dart';
import 'package:wakealert/signup/permissions.dart';

class PrimaryEmergencyContact extends StatefulWidget {
  const PrimaryEmergencyContact({super.key});

  @override
  State<PrimaryEmergencyContact> createState() => _PrimaryEmergencyContactState();
}

class _PrimaryEmergencyContactState extends State<PrimaryEmergencyContact> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  String? _selectedRelation;
  final List<String> _relations = ['Family', 'Partner', 'Friend'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft, // Forces it to the left
                child: Text(
                'Please enter your\nprimary contact:',
                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                 textAlign: TextAlign.left, // Optional, left is default
                  ),
                ),
              const SizedBox(height: 20),

              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.left,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 15),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.left,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter last name' : null,
              ),
              const SizedBox(height: 15),

              // Number
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Number',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.left,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter number' : null,
              ),
              const SizedBox(height: 15),

              // Relations Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRelation,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  border: OutlineInputBorder(),
                ),
                items: _relations
                    .map((relation) => DropdownMenuItem(
                          value: relation,
                          child: Text(relation, textAlign: TextAlign.center),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelation = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select a relation' : null,
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Arrow Button
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
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingPermissions(),
                      ),
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
