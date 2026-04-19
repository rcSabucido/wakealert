import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late final List<Map<String, String>> _contacts = [
    {
      'name': 'John Doe',
      'phone': '555-0123',
      'relationship': 'Family'
    },
    {
      'name': 'Jane Smith',
      'phone': '555-0456',
      'relationship': 'Friend'
    },
    {
      'name': 'Emily Brown',
      'phone': '555-0789',
      'relationship': 'Partner'
    },
  ];

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
              leading: const CircleAvatar(
                child: Icon(Icons.person),
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
              trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            );
          },
        ),
    );
  }
}
