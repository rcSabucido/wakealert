import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wakealert/models/contact.dart';
import 'package:wakealert/outbox/outbox_provider.dart';

class ContactService {
  static final String? _baseUrl = "${dotenv.env['API_URL']}/contacts/add";

  static void enqueueAddContact({
    required BuildContext context,
    required int clientUserId,
    required Contact contact
  }) {
    final repo = OutboxProvider.of(context);

    var map = contact.toMap();
    map["client_user_id"] = clientUserId;

    repo.enqueue(
      endpoint: '/contacts/add',
      method: 'POST',
      payload: map,
    );
  }

  static void enqueueDeleteContact({
    required BuildContext context,
    required int clientUserId,
    required Contact contact
  }) {
    final repo = OutboxProvider.of(context);

    var map = contact.toMap();
    map["client_user_id"] = clientUserId;

    repo.enqueue(
      endpoint: '/contacts/by_details',
      method: 'DELETE',
      payload: map,
    );
  }

  static void enqueueEditContactByDetails({
    required BuildContext context,
    required int clientUserId,
    required Contact originalContact,
    required Contact updatedContact
  }) {
    final repo = OutboxProvider.of(context);

    var map = {
      "original_contact": originalContact.toMap(),
      "update_contact": updatedContact.toMap()
    };

    repo.enqueue(
      endpoint: '/contacts/edit/${clientUserId}',
      method: 'POST',
      payload: map,
    );
  }


  static void enqueueClearAllPrimaryContacts({
    required BuildContext context,
    required int clientUserId
  }) {
    final repo = OutboxProvider.of(context);

    repo.enqueue(
      endpoint: '/contacts/${clientUserId}/primary/clear',
      method: 'PUT',
      payload: {},
    );
  }

  /// GET all contacts for a given mobile-user id.
  /// Returns List<Contact> parsed from the JSON array.
  static Future<List<Contact>> getContactsByClient(int clientUserId) async {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$apiUrl/contacts/client/$clientUserId');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to load contacts: ${resp.statusCode}');
    }

    debugPrint("body out: ${resp.body}");

    final List<dynamic> list = jsonDecode(resp.body)
        .where((c) => c["is_deleted"] == false)
        .toList();
    return list.map((json) => Contact.fromJson(json)).toList();
  }

  /// POST a new emergency contact.
  /// Returns the contact put in the database
  static Future<Contact> addContact({
    required int clientUserId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String relationshipName,
    required bool isPrimary,
  }) async {
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    var resp = await http.post(
      Uri.parse(_baseUrl!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_user_id': clientUserId,
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone_number': phoneNumber.trim(),
        'relationship': relationshipName.trim(),
        'is_primary': isPrimary,
      }),
    );

    if (resp.statusCode != 201) {
      throw Exception('Failed to add contact: ${resp.statusCode}');
    }

    return Contact.fromJson(jsonDecode(resp.body));
  }
}
