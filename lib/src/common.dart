import 'dart:convert';

import 'package:hex/hex.dart';
import 'package:crypto/crypto.dart';

/// A collection of common methods.
class Common {
  const Common();

  /// Checks if the script is running in the dart vm.
  static bool isDartVM =
      Uri.base.scheme == 'file' && Uri.base.path.endsWith('/');

  static bool equalsIgnoreCase(String? string1, String? string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  static String toJson(dynamic object) {
    var encoder = JsonEncoder.withIndent('     ');
    return encoder.convert(object);
  }

  static dynamic fromJson(String? jsonString) {
    if (jsonString == null) {
      return null;
    }
    return json.decode(jsonString);
  }

  static bool hasKeyIgnoreCase(Map map, String key) {
    return map.keys.any((x) => equalsIgnoreCase(x, key));
  }

  static String toHexString(List<int> data) {
    return HEX.encode(data);
  }

  static List fromHexString(String hexString) {
    return HEX.decode(hexString);
  }

  static String hashStringSHA256(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return toHexString(digest.bytes);
  }

  static String encodeMap(Map data) {
    return data.keys.map((key) {
      var k = Uri.encodeComponent(key.toString());
      var v = Uri.encodeComponent(data[key].toString());
      return '$k=$v';
    }).join('&');
  }

  /// Get the hostname of a [url].
  static String getHostname(String url) {
    var uri = Uri.parse(url);
    // If the url is already a hostname, return it.
    // Get the first part of the split in case the hostname
    // contains a path.
    if (uri.path.isNotEmpty && url.startsWith(uri.path)) {
      return url.split(RegExp(r'[#?/]'))[0];
    }
    return uri.host.isNotEmpty ? uri.host : uri.scheme;
  }
}
