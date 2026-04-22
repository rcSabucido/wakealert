import 'package:flutter/material.dart';

class EditContactView extends StatefulWidget {
  final Map<String, dynamic> contact;
  final int index;

  const EditContactView({super.key, required this.contact, required this.index});

  @override
  // State<EditContactView> createState() => _EditContactViewState();
}