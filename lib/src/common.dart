import 'dart:async';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:crypto/crypto.dart';
import 'package:quiver/cache.dart';

class Common {
  const Common();

  /// The cache containing the cookies semi-persistently.
  static MapCache<String, String> cache = MapCache();

  /// Add / Replace this [Vault] [value] for the specified [key].
  ///
  /// * [key]: the key
  /// * [value]: the value
  static Future<void> storageSet(String key, String value) async {
    await cache.set(key, value);
  }

  /// Returns the stash value for the specified [key]
  ///
  /// * [key]: the key
  ///
  /// Returns a [String]
  static Future<String?> storageGet(String key) async {
    return await cache.get(key);
  }

  /// Removes the mapping for a [key] from this [Vault] if it is present.
  ///
  /// * [key]: key whose mapping is to be removed from the [Vault]
  ///
  /// Returns `true` if the removal of the mapping for the specified [key] was successful.
  static Future<bool> storageRemove(String key) async {
    await cache.invalidate(key);
    return await cache.get(key) == null;
  }

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
}
