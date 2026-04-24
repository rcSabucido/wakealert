import 'package:flutter/material.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/labeledTextBox.dart';
import 'package:wakealert/components/subsectionHeader.dart';

class UserAddressSettingsPage extends StatefulWidget {
  final VoidCallback onBack;

  const UserAddressSettingsPage({super.key, required this.onBack});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<UserAddressSettingsPage> createState() => _UserAddressSettingsPageState(onBack);
}

class _UserAddressSettingsPageState extends State<UserAddressSettingsPage> {
  late final VoidCallback onBack;

  final TextEditingController blkAndLotController = new TextEditingController();
  final TextEditingController streetController = new TextEditingController();
  final TextEditingController subdivisionController = new TextEditingController();

  String? barangayOption;
  String? provinceOption;
  String? regionOption;

  _UserAddressSettingsPageState(this.onBack);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 32.0, left: 8.0, right: 8.0),
        child: ListView(
          children: [
            SubsectionHeader(
              title: "Address",
              onBack: onBack,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Text(
                "Address Information:",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: blkAndLotController,
                decoration: const InputDecoration(
                  labelText: 'Blk and Lot:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a valid block and lot';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: streetController,
                decoration: const InputDecoration(
                  labelText: 'Street (Optional):',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: subdivisionController,
                decoration: const InputDecoration(
                  labelText: 'Subdivision:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a valid subdivision';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: barangayOption,
                decoration: const InputDecoration(
                  labelText: "Barangay:",
                  hintText: "Select a barangay",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Barangay I", child: Text("Barangay I")),
                  DropdownMenuItem(value: "Barangay II", child: Text("Barangay II")),
                  DropdownMenuItem(value: "Barangay III", child: Text("Barangay III")),
                ],
                onChanged: (value) {
                  setState(() {
                    barangayOption = value;    
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a barangay";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: provinceOption,
                decoration: const InputDecoration(
                  labelText: "Province, Municipality or City",
                  hintText: "Select a province, municipality or city",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "City 1", child: Text("City 1")),
                  DropdownMenuItem(value: "City 2", child: Text("City 2")),
                  DropdownMenuItem(value: "City 3", child: Text("City 3")),
                ],
                onChanged: (value) {
                  setState(() {
                    provinceOption = value;    
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a province, municipality or city";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: regionOption,
                decoration: const InputDecoration(
                  labelText: "Region",
                  hintText: "Select a region",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Region 1", child: Text("Region 1")),
                  DropdownMenuItem(value: "Region 2", child: Text("Region 2")),
                  DropdownMenuItem(value: "Region 3", child: Text("Region 3")),
                ],
                onChanged: (value) {
                  setState(() {
                    regionOption = value;    
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a region";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
