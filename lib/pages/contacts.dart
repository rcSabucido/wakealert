import 'package:flutter/material.dart';
import 'package:wakealert/pages/addContactView.dart';
import 'package:wakealert/pages/editContactView.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late final List<Map<String, dynamic>> _contacts = [
    {
      'name': 'Emergency Hotline',
      'phone': '911',
      'relationship': 'Emergency',
      'isPrimary': false,
    },
    {
      'name': 'Jane Smith',
      'phone': '555-0456',
      'relationship': 'Friend',
      'isPrimary': true,
    },
    {
      'name': 'Emily Brown',
      'phone': '555-0789',
      'relationship': 'Partner',
      'isPrimary': false,
    },
  ];

  void _setPrimaryContact(Map<String, dynamic> newContact) {
    setState(() {
      if (newContact['isPrimary'] == true) {
        for (var contact in _contacts) {
          if (contact['isPrimary'] == true && contact != _contacts[0]) {
            contact['isPrimary'] = false;
            break;
          }
        }
        _contacts.insert(1, newContact);
      } else {
        _contacts.add(newContact);
      }
    });
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  void _updateContact(int index, Map<String, dynamic> updatedContact) {
    setState(() {
      if (updatedContact['isPrimary'] == true) {
        for (var i = 0; i < _contacts.length; i++) {
          if (_contacts[i]['isPrimary'] == true && i != 0 && i != index) {
            _contacts[i]['isPrimary'] = false;
            break;
          }
        }
        _contacts.removeAt(index);
        _contacts.insert(1, updatedContact);
      } else {
        _contacts[index] = updatedContact;
      }
    });
  }

  void _showContactOptions(BuildContext context, Map<String, dynamic> contact, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact['name'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditContactView(
                          contact: contact,
                          contactIndex: index,
                        ),
                      ),
                    );
                    if (result != null) {
                      final updatedContact = result as Map<String, dynamic>;
                      _updateContact(index, updatedContact);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${updatedContact['name']} updated'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteContact(index);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${contact['name']} deleted'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
      ),
      body: _contacts.isEmpty
        ? const Center(
          child: Text('No contacts yet.'),
        )
        : ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: _contacts.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final contact = _contacts[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: index == 0 
                ? null
                : (contact['isPrimary'] as bool? ?? false)
                  ? null
                  : Colors.grey[300],
                child: index == 0
                ? const Icon(Icons.emergency)
                : (contact['isPrimary'] as bool? ?? false)
                  ? const Text('P', style: TextStyle(color: Color(0xFFFF1111)))
                  : const Text('S'),
              ),
              title: Text(contact['name']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact['phone']!),
                  Text(
                    contact['relationship']!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    )
                  )
                ],
              ),
              trailing: index == 0 
              ? null
              : IconButton(
                  onPressed: () => _showContactOptions(context, contact, index),
                  icon: const Icon(Icons.more_vert),
                ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddContactView(),
              ),
            ).then((newContact) {
              if (newContact != null) {
                _setPrimaryContact(newContact);
              }
            });
          },
          backgroundColor: const Color(0xFFFF6961),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
    );
  }
}
