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

  /// PUT – clears the `is_primary` flag for **all** contacts that belong to the given user.
  /// Returns the http.Response so the caller can inspect status / body.
  static Future<void> clearAllPrimaryContacts({
    required int clientUserId,
  }) async {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$apiUrl/contacts/$clientUserId/primary/clear');
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}), // empty body; endpoint expects no payload
    );

    if (resp.statusCode != 204) {
      throw Exception('Failed to clear all primary contacts: ${resp.statusCode}, ${resp.body}');
    }
  }

  /// DELETE a single contact.
  /// Throws an exception if the server does NOT return 204.
  static Future<void> deleteContact({
    required int clientUserId,
    required int contactId,
  }) async {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }

    final uri = Uri.parse('$apiUrl/contacts/$clientUserId/$contactId');
    final resp = await http.delete(uri);

    if (resp.statusCode != 204) {
      throw Exception(
        'Failed to delete contact $contactId (user $clientUserId): ${resp.statusCode} – ${resp.body}',
      );
    }
  }

  /// PUT (update) an existing contact.
  /// [contact] – the Contact object with the new values (its `id` is used as contact_id)
  /// [clientUserId] – the mobile-user id that owns the contact
  /// Returns the Contact updated in the database
  static Future<Contact> updateContact({
    required Contact contact,
    required int clientUserId,
  }) async {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      throw AssertionError('API_URL not found in .env');
    }
    if (contact.id == null) {
      throw ArgumentError('Contact.id must not be null for update');
    }

    debugPrint("updated contact: ${contact}");

    final uri = Uri.parse('$apiUrl/contacts/edit/$clientUserId/${contact.id}');
    var resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': contact.firstName,
        'last_name': contact.lastName,
        'phone_number': contact.phoneNumber,
        'relationship': contact.relationship.name,
        'is_primary': contact.isPrimary,
      })
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Failed to update contact: ${resp.statusCode}, ${resp.body}');
    }

    return Contact.fromJson(jsonDecode(resp.body));

  }
}
