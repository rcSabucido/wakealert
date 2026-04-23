import 'package:flutter/material.dart';
import 'package:wakealert/components/labeledDropdown.dart';

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
  final controller = TextEditingController();

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    LabeledDropdown<String>(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}