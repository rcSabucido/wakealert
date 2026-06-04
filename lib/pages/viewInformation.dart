import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/medicalInformation/medicalInformation.dart';
import 'package:wakealert/models/contact.dart';
import 'package:wakealert/prefs_names.dart' as PrefsNames;

class ViewInformationPage extends StatefulWidget {
  final VoidCallback onBack;

  const ViewInformationPage({super.key, required this.onBack});

  @override
  State<ViewInformationPage> createState() => _ViewInformationPageState();
}

class _ViewInformationPageState extends State<ViewInformationPage> {
  String fullName = "";
  String birthDate = "";
  String pregnancyStatus = "Unknown";
  String organDonorStatus = "Unknown";
  String bloodType = "Unknown";
  String phoneNumber = "";
  String relationship = "";
  String fullAddress = "";
  int age = 0;

  bool _otherPressed = false;

  @override
  void initState() {
    super.initState();

    _loadInfo();
  }

  int calculateAge(String birthDateString) {
    final birthDate = DateTime.parse(birthDateString);
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);

    if (birthDate.isAfter(currentDate)) {
      throw ArgumentError('Birth date cannot be in the future.');
    }

    int years = currentDate.year - birthDate.year;

    final hasBirthdayPassedThisYear = 
        (currentDate.month > birthDate.month) ||
        (currentDate.month == birthDate.month && 
         currentDate.day >= birthDate.day);

    if (!hasBirthdayPassedThisYear) {
      years--;
    }

    return years;
  }

  void _loadInfo() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        fullName = "${prefs.getString(PrefsNames.FIRST_NAME) ?? ""} ${prefs.getString(PrefsNames.LAST_NAME) ?? ""}";
        birthDate = prefs.getString(PrefsNames.BIRTH_DATE) ?? "";

        pregnancyStatus = prefs.getString(PrefsNames.PREGNANCY_STATUS) ?? "No";
        organDonorStatus = prefs.getString(PrefsNames.ORGAN_DONOR) ?? "No";
        bloodType = prefs.getString(PrefsNames.BLOOD_TYPE) ?? "O-";

        fullAddress = prefs.getString(PrefsNames.FULL_ADDRESS) ?? "";

        age = calculateAge(birthDate);

        final raw = prefs.getString(PrefsNames.CONTACTS);
        if (raw == null) return;

        final List<dynamic> list = json.decode(raw);
        final loaded = list.map((e) => Contact.fromJson(e)).toList();

        loaded.sort((a, b) {
          // true (1) comes before false (0)
          int primaryCmp = b.isPrimary ? 1 : 0 - (a.isPrimary ? 1 : 0);
          if (primaryCmp != 0) return primaryCmp;

          // secondary ordering: alphabetically by last name, then first
          int lastCmp = a.lastName.compareTo(b.lastName);
          return lastCmp != 0 ? lastCmp : a.firstName.compareTo(b.firstName);
        });

        if (loaded.length > 0 && loaded.first.isPrimary) {
          phoneNumber = loaded.first.phoneNumber;
          relationship = loaded.first.relationship.name;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar 
            Container(
              color: Colors.white, 
              child: Row(
                children: [
                  Expanded(
                    child: Listener(
                      onPointerDown: (_) {
                        debugPrint("onPointerDown");
                        setState(() => _otherPressed = true);
                      },
                      onPointerUp: (_) {
                        debugPrint("onPointerUp");
                        setState(() => _otherPressed = false);
                      },
                      onPointerCancel: (_) {
                        debugPrint("onPointerCancel");
                        setState(() => _otherPressed = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF5350), // Active Tab
                        ),
                        child: const Text(
                          "USER\nINFORMATION",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25, 
                          ),
                        ),
                      ),
                    ),
                  ),
                  // This is the small white space 
                  const SizedBox(width: 3), 
                  Expanded(
                    child: Listener(
                      onPointerDown: (_) {
                        debugPrint("onPointerDown other");
                        if (_otherPressed) {
                          debugPrint("other is pressed");

                          Navigator.pop(context);
                          return;
                        }

                        _loadInfo();

                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const MedicalInfoScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[200], // Inactive Tab
                        ),
                        child: const Text(
                          "MEDICAL\nINFORMATION",
                          textAlign: TextAlign.right, // Better alignment for the "seamless" look
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 25, // Adjusted so it doesn't overflow
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT AREA
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: InfoTile(label: "Full Name", value: fullName)),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: InfoTile(label: "Blood Type", value: bloodType)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: InfoTile(label: "Date of Birth", value: birthDate)),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: InfoTile(label: "Age", value: age <= 0 ? "" : "${age}")),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: InfoTile(label: "Primary Contact", value: phoneNumber, singleLine: true,)),
                        SizedBox(width: 12),
                        Expanded(flex: 1, child: InfoTile(label: "Relationship", value: relationship, singleLine: true)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoTile(label: "Address", value: fullAddress),
                  const SizedBox(height: 16),
                  InfoTile(label: "Pregnancy Status", value: pregnancyStatus),
                  const SizedBox(height: 16),
                  InfoTile(label: "Organ Donor", value: organDonorStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool? singleLine;

  const InfoTile({super.key, required this.label, required this.value, this.singleLine});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AutoSizeText(
            label,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 16, 
              fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE55A5A),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
            child: singleLine != null && singleLine! ? AutoSizeText(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
            : Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}