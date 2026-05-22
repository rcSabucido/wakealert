class PsgcParser {
  static String region(String barangayPsgc) =>
      barangayPsgc.substring(0, 2); // RR

  static String provinceOrHuc(String barangayPsgc) =>
      barangayPsgc.substring(0, 5); // RRPPP

  static String cityOrMun(String barangayPsgc) =>
      barangayPsgc.substring(0, 7); // RRPPPMM
}