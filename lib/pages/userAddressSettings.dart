import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakealert/components/labeledDropdown.dart';
import 'package:wakealert/components/labeledTextBox.dart';
import 'package:wakealert/components/subsectionHeader.dart';
import 'package:wakealert/prefs_names.dart' as PrefsNames;

import 'package:wakealert/services/psgc_address_service.dart';
import 'package:wakealert/services/victim_service.dart';

final addressLineSeparator = "\u{259E}";

class UserAddressSettingsPage extends StatefulWidget {
  final VoidCallback onBack;

  const UserAddressSettingsPage({super.key, required this.onBack});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<UserAddressSettingsPage> createState() => _UserAddressSettingsPageState(onBack);
}

class _UserAddressSettingsPageState extends State<UserAddressSettingsPage> {
  late final VoidCallback onBack;

  final TextEditingController blkAndLotController = new TextEditingController();
  final TextEditingController streetController = new TextEditingController();
  final TextEditingController subdivisionController = new TextEditingController();

  List<Region>? regionList;
  List<ProvinceOrHuc>? provinceHucList;
  List<CityMun>? cityMunList;
  List<Barangay>? barangayList;

  String? barangayOption;
  String? cityMunOption;
  String? provinceHUCOption;
  String? regionOption;

  bool regionFetched = false;
  bool provinceHUCFetched = false;
  bool cityMunFetched = false;
  bool barangayFetched = false;

  _UserAddressSettingsPageState(this.onBack);

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() {
    SharedPreferences.getInstance().then((prefs) async {
      // hack
      final addressLineFull = prefs.getString(PrefsNames.ADDRESS_LINE)!.split(addressLineSeparator);
      if (addressLineFull.length == 3) {
        blkAndLotController.text = addressLineFull[0];
        streetController.text = addressLineFull[1];
        subdivisionController.text = addressLineFull[2];
      }

      String? barangay = prefs.getString(PrefsNames.BARANGAY);
      if (barangay != null && barangay.isNotEmpty) {
        final cityMun = prefs.getString(PrefsNames.CITY_MUN)!;
        final provinceHUC = prefs.getString(PrefsNames.PROVINCE_OR_HUC)!;
        final region = prefs.getString(PrefsNames.REGION)!;

        debugPrint("region: ${region}");
        debugPrint("provinceHUC: ${provinceHUC}");
        debugPrint("cityMun: ${cityMun}");
        debugPrint("barangay: ${barangay}");

        setState(() {
          barangayOption = barangay;
          cityMunOption = cityMun;
          provinceHUCOption = provinceHUC;
          regionOption = region;
        });

        await _loadRegions(false);
        await _loadProvinceHUC(region, false);
        await _loadCityMunicipality(provinceHUC, false);
        await _loadBarangay(cityMun);
      } else {
        await _loadRegions(true);
      }
    });
  }

  void onBackSave() {
    SharedPreferences.getInstance().then((prefs) {
      final addressLineList = [
        blkAndLotController.text,
        streetController.text,
        subdivisionController.text
      ];
      final fullAddressLine = addressLineList.join(addressLineSeparator);

      // hack
      prefs.setString(PrefsNames.ADDRESS_LINE, fullAddressLine);

      if (regionOption != null &&
          provinceHUCOption != null &&
          cityMunOption != null &&
          barangayOption != null)
      {
        prefs.setString(PrefsNames.REGION, regionOption!);
        prefs.setString(PrefsNames.PROVINCE_OR_HUC, provinceHUCOption!);
        prefs.setString(PrefsNames.CITY_MUN, cityMunOption!);
        prefs.setString(PrefsNames.BARANGAY, barangayOption!);


        VictimService.enqueueUpdateAddressLine(
          context: context,
          addressId: prefs.getInt(PrefsNames.ADDRESS_LINE_ID)!,
          barangayPsgc: barangayOption!,
          addressLine: fullAddressLine,
        );
      }

      onBack();
    });
  }

  Future<void> _loadRegions(bool newRegion) async {
    final client = PsgcClient();
    final regions = await client.fetchRegions();
    setState(() {
      regionList = regions;
      regionFetched = true;
      provinceHUCFetched = false;
      cityMunFetched = false;
      barangayFetched = false;

      if (newRegion) {
        provinceHUCOption = null;
        cityMunOption = null;
        barangayOption = null;
      }
      debugPrint("region fetched");
    });
  }

  Future<void> _loadProvinceHUC(String region, bool newProvinceHUC) async {
    final client = PsgcClient();
    final provinces = await client.fetchProvinces(region);
    setState(() {
      provinceHucList = provinces;
      provinceHUCFetched = true;
      cityMunFetched = false;
      barangayFetched = false;

      if (newProvinceHUC) {
        cityMunOption = null;
        barangayOption = null;
      }
      debugPrint("province or huc fetched");
    });
  }

  Future<void> _loadCityMunicipality(String provinceOrHuc, bool newCityMun) async {
    final client = PsgcClient();
    final cityMuns = await client.fetchCities(provinceOrHuc);
    setState(() {
      cityMunList = cityMuns;
      cityMunFetched = true;
      barangayFetched = false;

      if (newCityMun) {
        barangayOption = null;
      }
      debugPrint("city mun fetched");
    });
  }

  Future<void> _loadBarangay(String cityMun) async {
    final client = PsgcClient();
    final barangays = await client.fetchBarangays(cityMun);
    setState(() {
      barangayList = barangays;
      barangayFetched = true;
      debugPrint("barangays fetched");
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 32.0, left: 8.0, right: 8.0),
        child: ListView(
          children: [
            SubsectionHeader(
              title: "Address",
              onBack: onBackSave,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Text(
                "Address Information:",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: blkAndLotController,
                decoration: const InputDecoration(
                  labelText: 'Blk and Lot:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a valid block and lot';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: streetController,
                decoration: const InputDecoration(
                  labelText: 'Street (Optional):',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: subdivisionController,
                decoration: const InputDecoration(
                  labelText: 'Subdivision:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a valid subdivision';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: regionOption,
                decoration: const InputDecoration(
                  labelText: "Region",
                  hintText: "Select a region",
                  border: OutlineInputBorder(),
                ),
                items: regionList?.map((region) =>
                    DropdownMenuItem(
                      value: region.regionPsgc,
                      child: Text(region.regionName)))
                  .toList(),
                onChanged: !regionFetched ? null : (value) {
                  setState(() {
                    regionOption = value; 
                  });
                  if (value != null) {
                    _loadProvinceHUC(value, true);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a region";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: provinceHUCOption,
                decoration: const InputDecoration(
                  labelText: "Province or Highly Urbanized City",
                  hintText: "Select a province or HUC",
                  border: OutlineInputBorder(),
                ),
                items: provinceHucList?.map((provinceHuc) =>
                    DropdownMenuItem(
                      value: provinceHuc.provinceOrHucPsgc,
                      child: Text(provinceHuc.provinceOrHucName)))
                  .toList(),
                onChanged: !provinceHUCFetched ? null : (value) {
                  setState(() {
                    provinceHUCOption = value; 
                  });
                  if (value != null) {
                    _loadCityMunicipality(value, true);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a region";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: cityMunOption,
                decoration: const InputDecoration(
                  labelText: "Municipality or City",
                  hintText: "Select a municipality or city",
                  border: OutlineInputBorder(),
                ),
                items: cityMunList?.map((cityMun) =>
                    DropdownMenuItem(
                      value: cityMun.cityMunPsgc,
                      child: Text(cityMun.cityMunName)))
                  .toList(),
                onChanged: !cityMunFetched ? null : (value) {
                  setState(() {
                    cityMunOption = value; 
                  });
                  if (value != null) {
                    _loadBarangay(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a province, municipality or city";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: barangayOption,
                decoration: const InputDecoration(
                  labelText: "Barangay:",
                  hintText: "Select a barangay",
                  border: OutlineInputBorder(),
                ),
                items: barangayList?.map((barangay) =>
                    DropdownMenuItem(
                      value: barangay.barangayPsgc,
                      child: Text(barangay.barangayName)))
                  .toList(),
                onChanged: !barangayFetched ? null : (value) {
                  setState(() {
                    barangayOption = value; 
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a barangay";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
