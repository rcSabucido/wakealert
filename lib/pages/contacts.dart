import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/pages/addContactView.dart';
import 'package:wakealert/pages/editContactView.dart';

import 'package:wakealert/models/contact.dart';

import 'package:wakealert/prefs_names.dart' as PrefsNames;
import 'package:wakealert/services/contact_service.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  /* ----------  state  ---------- */
  final List<Contact> _contacts = [
    Contact(
      firstName: 'Emergency',
      lastName: 'Hotline',
      phoneNumber: '911',
      relationship: RelationshipType.Emergency,
      isPrimary: false,
    ),
  ];

  /* ----------  life-cycle  ---------- */
  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  /* ----------  persistence  ---------- */
  void _loadContacts() {
    SharedPreferences.getInstance().then((prefs) {
      _loadContactsState(prefs);
    });
  }

  void _loadContactsState(SharedPreferences prefs) async {
    debugPrint("Contacts sharedprefs loaded");

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

    final emergency = _contacts.first.copyWith();

    // keep emergency contact at index 0
    setState(() {
      _contacts
        ..clear()
        ..add(emergency) // emergency
        ..addAll(loaded.where((c) => c.relationship != RelationshipType.Emergency));
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _contacts
        .where((c) => c.relationship != RelationshipType.Emergency)
        .map((c) => c.toMap())
        .toList();
    await prefs.setString(PrefsNames.CONTACTS, json.encode(payload));
  }

  /* ----------  CRUD helpers  ---------- */
  void _addContact(Contact newContact) {
    setState(() {
      // ensure only one primary
      if (newContact.isPrimary) {
        _contacts
            .where((c) => c.isPrimary)
            .forEach((c) => c = c.copyWith(isPrimary: false));
      }

      // insert right after emergency contact if primary, else append
      final insertIndex = newContact.isPrimary ? 1 : _contacts.length;
      _contacts.insert(insertIndex, newContact);
    });
    _saveContacts();
  }

  void _updateContact(int index, Contact updated) {
    if (index == 0) return; // emergency contact immutable

    setState(() {
      // demote previous primary
      if (updated.isPrimary) {
        for (int i = 0; i < _contacts.length; i++) {
          if (i != index && _contacts[i].isPrimary) {
            _contacts[i] = _contacts[i].copyWith(isPrimary: false);
          }
        }
      }

      // move to position 1 if now primary
      if (updated.isPrimary && index != 1) {
        _contacts
          ..removeAt(index)
          ..insert(1, updated);
      } else {
        _contacts[index] = updated;
      }
    });
    _saveContacts();
  }

  Future<void> _deleteContact(int index) async {
    if (index == 0) return;

    final prefs = await SharedPreferences.getInstance();

    try {
      await ContactService.deleteContact(clientUserId: prefs.getInt(PrefsNames.MOBILE_USER_ID)!, contactId: _contacts[index].id!);
    } catch (e) {
      debugPrint('Failed to delete contact: ${e}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete contact: ${e}')),
      );
    }

    setState(() => _contacts.removeAt(index));
    _saveContacts();
  }

  /* ----------  UI helpers  ---------- */
  void _showContactOptions(BuildContext context, Contact contact, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE35D56),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.fullName(),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  debugPrint("Contact to edit: ${contact}");

                  final result = await Navigator.push<Contact>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditContactView(
                        contact: contact,
                        contactIndex: index,
                      ),
                    ),
                  );
                  if (result != null) _updateContact(index, result);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6961),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                ),
                child: const Text('Edit', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteContact(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${contact.fullName()} deleted')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6961),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Delete',
                    style: TextStyle(fontSize: 16, color: Color(0xFFFF6961))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ----------  build  ---------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 120),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              height: 100,
              decoration: const BoxDecoration(color: Color(0xFFFF6961)),
              child: const Center(
                child: Text(
                  'CONTACTS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('No contacts yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _contacts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final c = _contacts[index];
                final isEmergency = c.relationship == RelationshipType.Emergency;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isEmergency ? null : (c.isPrimary ? null : Colors.grey[300]),
                    child: isEmergency
                        ? const Icon(Icons.emergency, size: 20)
                        : Text(c.isPrimary ? 'P' : 'S',
                            style: const TextStyle(color: Color(0xFFFF1111))),
                  ),
                  title: Text(c.fullName()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.phoneNumber),
                      Text(
                        c.relationship.name,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: isEmergency
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showContactOptions(context, c, index),
                        ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newContact = await Navigator.push<Contact>(
            context,
            MaterialPageRoute(builder: (_) => const AddContactView()),
          );
          if (newContact != null) _addContact(newContact);
        },
        backgroundColor: const Color(0xFFFF6961),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}