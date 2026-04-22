import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakealert/pages/contactConfirmedView.dart';

class AddContactView extends StatefulWidget {
  const AddContactView({super.key});

  @override
  State<AddContactView> createState() => _AddContactViewState();
}
  
class _AddContactViewState extends State<AddContactView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRelationship;
  bool _isPrimary = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final newContact = {
        'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim(),
        'phone': _phoneController.text,
        'relationship': _selectedRelationship,
        'isPrimary': _isPrimary,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactConfirmedView(
            contactName: newContact['name'] as String,
            isEdit: false,
          ),
        ),
      ).then((result) {
        if (result == true) {
          Navigator.pop(context, newContact);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CONTACTS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter your\ncontact:',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name:',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name:',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number:',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        if (value.length < 7) {
                          return 'Phone number must be at least 7 digits';
                        }
                        if (value.length > 15) {
                          return 'Phone number must not exceed 15 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Relations:',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Family',
                          child: Text('Family'),
                        ),
                        DropdownMenuItem(
                          value: 'Friend',
                          child: Text('Friend'),
                        ),
                        DropdownMenuItem(
                          value: 'Partner',
                          child: Text('Partner'),
                        ),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedRelationship = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a relationship';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Set as Primary Contact'),
                      value: _isPrimary,
                      onChanged: (bool value) {
                        setState(() {
                          _isPrimary = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6961),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add Contact'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}