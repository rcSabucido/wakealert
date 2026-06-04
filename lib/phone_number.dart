import 'package:flutter_libphonenumber/flutter_libphonenumber.dart' as Flutterlibphonenumber;

class PhoneNumber {
  static Future<String?> format(
    String rawInput, {
    String defaultRegion = 'PH',
  }) async {
    String cleaned = rawInput.replaceAll(RegExp(r'[\s\-()]'), '');

    if (cleaned.isEmpty) return null;

    try {
      String normalized;

      if (cleaned.startsWith('+')) {
        normalized = cleaned;
      } else if (cleaned.startsWith('0')) {
        normalized = '+63${cleaned.substring(1)}';
      } else if (cleaned.length > 10) {
        normalized = '+$cleaned';
      } else {
        normalized = cleaned;
      }

      final result = await Flutterlibphonenumber.parse(
        normalized,
        region: defaultRegion,
      );

      return result['international'].replaceAll(" ", "");
    } catch (e) {
      return null;
    }
  }
}