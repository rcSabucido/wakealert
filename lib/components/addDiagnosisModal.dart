import 'package:flutter/material.dart';
import 'package:wakealert/components/fullWidthButton.dart';
import 'package:wakealert/components/labeledDatePicker.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/labeledTextBox.dart';

class AddDiagnosisModal extends StatefulWidget {
  final List<String> items;
  final String? selected;
  final void Function(String) onChanged;

  const AddDiagnosisModal({super.key,
    required this.items,
    required this.selected,
    required this.onChanged});

  @override
  State<AddDiagnosisModal> createState() => _AddDiagnosisModalState();
}

class _AddDiagnosisModalState extends State<AddDiagnosisModal> {
  late List<String> items;
  late String? selected;
  late void Function(String) onChanged;
  final diagnosisDateController = TextEditingController();
  final hospitalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    items = List.from(widget.items);
    onChanged = widget.onChanged;
    selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text("Add Diagnosis",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LabeledDropdown<String>(
                      label: "Last Diagnosis:",
                      value: selected,
                      backgroundColor: Colors.white,
                      items: [
                        for (var str in items)
                          DropdownMenuItem(value: str, child: Text(str)),
                      ],
                      onChanged: (value) {
                        onChanged(value!);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LabeledDatePicker(
                      label: "Diagnosis Date:",
                      controller: diagnosisDateController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LabeledTextBox(
                      label: "Hospital:",
                      controller: hospitalController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 8.0),
                    child: FullWidthButton(
                      text: "Save",
                      color: const Color(0xFFCC5959),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 8.0),
                    child: FullWidthButton(
                      text: "Cancel",
                      color: Colors.grey,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}