import 'dart:convert';

enum RelationshipType { Parent, Child, Partner, Friend, Family, Emergency }

class Contact {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final RelationshipType relationship;
  final bool isPrimary;

  Contact({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.relationship,
    required this.isPrimary,
  });

  // -------------------------------------------------
  // JSON serialization helpers
  // -------------------------------------------------
  static RelationshipType _relationshipFromJson(String value) =>
      RelationshipType.values.firstWhere((e) => e.name == value);

  static String _relationshipName(RelationshipType type) => type.name;

  // -------------------------------------------------
  // From JSON
  // -------------------------------------------------
  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phoneNumber: json['phoneNumber'] as String,
        relationship: _relationshipFromJson(json['relationship'] as String),
        isPrimary: json['isPrimary'] as bool,
      );

  factory Contact.fromJsonString(String source) =>
      Contact.fromJson(json.decode(source) as Map<String, dynamic>);

  // -------------------------------------------------
  // To JSON
  // -------------------------------------------------
  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'relationship': _relationshipName(relationship),
        'isPrimary': isPrimary,
      };

  String toJsonString() => json.encode(toMap());

  String fullName() => "${firstName} ${lastName}";

  Contact copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    RelationshipType? relationship,
    bool? isPrimary,
  }) => 
    Contact(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
    );

  // -------------------------------------------------
  // Pretty toString
  // -------------------------------------------------
  @override
  String toString() =>
      '$firstName $lastName ($relationship) - $phoneNumber${isPrimary ? ' [PRIMARY]' : ''}';
}