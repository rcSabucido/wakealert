import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: const Size(double.infinity, 120), 
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6961),
            ),
            child: Center(
              child: Text(
                "CONTACTS",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                )
              )
            )
          )
        )
      )
      )
    );
  }
}
