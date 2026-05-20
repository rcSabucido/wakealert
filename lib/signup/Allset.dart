import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/background_ble_service.dart';
import 'package:wakealert/pages/home.dart';
import 'package:wakealert/main.dart';

import 'dart:convert';
import 'package:wakealert/models/contact.dart';

import 'package:wakealert/prefs_names.dart' as PrefsNames;
import 'package:wakealert/services/contact_service.dart';
import 'package:wakealert/services/medical_info_service.dart';
import 'package:wakealert/services/user_service.dart';
import 'package:wakealert/services/victim_service.dart';

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
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final raw = prefs.getString(PrefsNames.CONTACTS);
                  if (raw == null) return;

                  final List<dynamic> list = json.decode(raw);
                  final loaded = list.map((e) => Contact.fromJson(e)).toList();
                  final primaryContact = loaded.first;

                  debugPrint("First ever contact: ${primaryContact}");
                  debugPrint("Email: ${prefs.getString(PrefsNames.EMAIL)}");

                  try {
                    // Create mobile user first
                    final newUser = await AuthService.createMobileUser(
                      email: prefs.getString(PrefsNames.EMAIL)!,
                      password: prefs.getString(PrefsNames.PASSWORD)!,
                    );
                    debugPrint('User created with id=${newUser.id}, email=${newUser.email}');

                    // Add primary contact
                    final resp = await ContactService.addContact(
                      clientUserId: newUser.id,
                      firstName: primaryContact.firstName,
                      lastName: primaryContact.lastName,
                      phoneNumber: primaryContact.phoneNumber,
                      relationshipName: primaryContact.relationship.name,
                      isPrimary: true,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact added')),
                    );

                    final newRecord = await MedicalInfoService.createBlank();
                    final mi_id = newRecord['medical_info_id'];
                    debugPrint('New medical_info id = $mi_id');

                    final newVictim = await VictimService.addVictim(
                      mobileUserId: newUser.id,
                      firstName: prefs.getString(PrefsNames.FIRST_NAME)!,
                      lastName: prefs.getString(PrefsNames.LAST_NAME)!,
                      medicalInfoId: mi_id,
                    );
                    debugPrint('Victim created with id=${newVictim.victimId}');

                    prefs.setInt(PrefsNames.MOBILE_USER_ID, newUser.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User data created.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error in registration: ${e.toString()}")),
                    );
                  } 
                  debugPrint('Starting ble service');
                  initBackgroundBleService();

                  prefs.setBool(PrefsNames.ONBOARDING_FINISHED, true);

                  Navigator.of(context).pushReplacementNamed('/home');
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
