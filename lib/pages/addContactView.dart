// Placeholder – replace with the real file that exports Contact & RelationshipType
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/models/contact.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakealert/outbox/outbox_provider.dart';
import 'package:wakealert/outbox/outbox_repository.dart';
import 'package:wakealert/pages/contactConfirmedView.dart';
import 'package:wakealert/prefs_names.dart' as PrefsNames;
import 'package:wakealert/services/contact_service.dart';

class AddContactView extends StatefulWidget {
  const AddContactView({super.key});

  @override
  State<AddContactView> createState() => _AddContactViewState();
}

class _AddContactViewState extends State<AddContactView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _phoneController     = TextEditingController();

  RelationshipType? _selectedRelationship;
  bool _isPrimary = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /* --------------------------------------------------------------- */
  void _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    final newContact = Contact(
      firstName:   _firstNameController.text.trim(),
      lastName:    _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      relationship:_selectedRelationship!,
      isPrimary:   _isPrimary,
    );

    /*
    final newContact = await ContactService.addContact(
      clientUserId:     prefs.getInt(PrefsNames.MOBILE_USER_ID)!,
      firstName:        _firstNameController.text.trim(),
      lastName:         _lastNameController.text.trim(),
      phoneNumber:      _phoneController.text.trim(),
      relationshipName: _selectedRelationship!.name,
      isPrimary:        _isPrimary,
    );
    */

    final prefs = await SharedPreferences.getInstance();

    ContactService.enqueueAddContact(
      context:      context, 
      clientUserId: prefs.getInt(PrefsNames.MOBILE_USER_ID)!,
      contact:      newContact
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactConfirmedView(
          contactName: newContact.fullName(),
          isEdit: false,
        ),
      ),
    ).then((confirmed) {
      if (confirmed == true) Navigator.pop(context, newContact);
    });
  }
  /* --------------------------------------------------------------- */

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                  fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    /* ----------  First Name  ---------- */
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name:',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    /* ----------  Last Name  ---------- */
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name:',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    /* ----------  Phone  ---------- */
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Phone Number:',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 7 || v.length > 15) return '7-15 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /* ----------  Relationship  ---------- */
                    DropdownButtonFormField<RelationshipType>(
                      value: _selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Relations:',
                        border: OutlineInputBorder(),
                      ),
                      items: RelationshipType.values
                          .where((t) => t != RelationshipType.Emergency)
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedRelationship = v;
                      }),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    /* ----------  Primary switch  ---------- */
                    SwitchListTile(
                      title: const Text('Set as Primary Contact'),
                      value: _isPrimary,
                      onChanged: (v) => setState(() => _isPrimary = v),
                    ),
                    const SizedBox(height: 24),

                    /* ----------  Save button  ---------- */
                    ElevatedButton(
                      onPressed: _saveContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6961),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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