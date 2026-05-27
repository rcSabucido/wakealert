// psgc_client.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wakealert/services/psgc_parser.dart';

/// Immutable Region
class Region {
  final String regionPsgc;
  final String regionName;

  Region({required this.regionPsgc, required this.regionName});

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        regionPsgc: json['region_psgc'] as String,
        regionName: json['region_name'] as String,
      );
}

/// Immutable Province or Highly-Urbanized City
class ProvinceOrHuc {
  final String provinceOrHucPsgc;
  final String provinceOrHucName;
  final String regionPsgc;

  ProvinceOrHuc({
    required this.provinceOrHucPsgc,
    required this.provinceOrHucName,
    required this.regionPsgc,
  });

  factory ProvinceOrHuc.fromJson(Map<String, dynamic> json) =>
      ProvinceOrHuc(
        provinceOrHucPsgc: json['province_or_huc_psgc'] as String,
        provinceOrHucName: json['province_or_huc_name'] as String,
        regionPsgc: json['region_psgc'] as String,
      );
}

/// Immutable City or Municipality
class CityMun {
  final String cityMunPsgc;
  final String cityMunName;
  final String provinceOrHucPsgc;
  final String type; // "City" | "Municipality"

  CityMun({
    required this.cityMunPsgc,
    required this.cityMunName,
    required this.provinceOrHucPsgc,
    required this.type,
  });

  factory CityMun.fromJson(Map<String, dynamic> json) => CityMun(
        cityMunPsgc: json['city_mun_psgc'] as String,
        cityMunName: json['city_mun_name'] as String,
        provinceOrHucPsgc: json['province_or_huc_psgc'] as String,
        type: json['type'] as String,
      );
}

/// Immutable Barangay
class Barangay {
  final String barangayPsgc;
  final String barangayName;
  final String cityMunPsgc;

  Barangay({
    required this.barangayPsgc,
    required this.barangayName,
    required this.cityMunPsgc,
  });

  factory Barangay.fromJson(Map<String, dynamic> json) => Barangay(
        barangayPsgc: json['barangay_psgc'] as String,
        barangayName: json['barangay_name'] as String,
        cityMunPsgc: json['city_mun_psgc'] as String,
      );
}

/// Thin wrapper around the PSGC address endpoints
class PsgcClient {
  static final String? baseUrl = dotenv.env['API_URL'];
  final http.Client _client;

  PsgcClient({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<Region>> fetchRegions() async {
    final uri = Uri.parse('$baseUrl/addresses/regions');
    final resp = await _client.get(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) throw Exception('Failed to load regions');
    final list = jsonDecode(resp.body) as List;
    return list.map((e) => Region.fromJson(e)).toList();
  }

  Future<List<ProvinceOrHuc>> fetchProvinces(String regionPsgc) async {
    final uri = Uri.parse('$baseUrl/addresses/regions/$regionPsgc/provinces');
    final resp = await _client.get(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) throw Exception('Failed to load provinces');
    final list = jsonDecode(resp.body) as List;
    return list.map((e) => ProvinceOrHuc.fromJson(e)).toList();
  }

  Future<List<CityMun>> fetchCities(String provinceOrHucPsgc) async {
    final uri =
        Uri.parse('$baseUrl/addresses/provinces/$provinceOrHucPsgc/cities');
    final resp = await _client.get(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) throw Exception('Failed to load cities');
    final list = jsonDecode(resp.body) as List;
    return list.map((e) => CityMun.fromJson(e)).toList();
  }

  Future<List<Barangay>> fetchBarangays(String cityMunPsgc) async {
    final uri = Uri.parse('$baseUrl/addresses/cities/$cityMunPsgc/barangays');
    final resp = await _client.get(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) throw Exception('Failed to load barangays');
    final list = jsonDecode(resp.body) as List;
    return list.map((e) => Barangay.fromJson(e)).toList();
  }

  Future<String> fullAddress(
    String barangayPsgc,
  ) async {
    final regionCode      = PsgcParser.region(barangayPsgc);
    final provinceHucCode = PsgcParser.provinceOrHuc(barangayPsgc);
    final cityMunCode     = PsgcParser.cityOrMun(barangayPsgc);

    final regionF   = fetchRegions();
    final provinceF = fetchProvinces(regionCode);
    final cityF     = fetchCities(provinceHucCode);
    final barangayF = fetchBarangays(cityMunCode);

    final regions    = await regionF;
    final provinces  = await provinceF;
    final cities     = await cityF;
    final barangays  = await barangayF;

    final region   = regions.firstWhere((r) => r.regionPsgc == regionCode);
    final province = provinces.firstWhere((p) => p.provinceOrHucPsgc == provinceHucCode);
    final city     = cities.firstWhere((c) => c.cityMunPsgc == cityMunCode);
    final barangay = barangays.firstWhere((b) => b.barangayPsgc == barangayPsgc);

    return '${barangay.barangayName}, ${city.cityMunName}, ${province.provinceOrHucName}, ${region.regionName}';
}

  void close() => _client.close();
}