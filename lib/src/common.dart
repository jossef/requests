import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_hive/stash_hive.dart';
import 'package:crypto/crypto.dart';

class Common {
  const Common();

  // Temporary directory
  static final path = Directory.systemTemp.path;

  // Creates a store
  static final store = newHiveDefaultVaultStore(path: path);

  // Creates a vault from the previously created store
  static final vault = store.vault<String>(
    name: 'cookieVault',
    eventListenerMode: EventListenerMode.synchronous,
  );

  /// Add / Replace this [Vault] [value] for the specified [key].
  ///
  /// * [key]: the key
  /// * [value]: the value
  static Future<void> storageSet(String key, String value) async {
    await vault.put(key, value);
  }

  /// Returns the stash value for the specified [key]
  ///
  /// * [key]: the key
  ///
  /// Returns a [String]
  static Future<String?> storageGet(String key) async {
    return await vault.get(key);
  }

  /// Removes the mapping for a [key] from this [Vault] if it is present.
  ///
  /// * [key]: key whose mapping is to be removed from the [Vault]
  ///
  /// Returns `true` if the removal of the mapping for the specified [key] was successful.
  static Future<bool> storageRemove(String key) async {
    await vault.remove(key);
    return !await vault.containsKey(key);
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

  static List<String> split(String string, String separator, {int max = 0}) {
    var result = <String>[];

    if (separator.isEmpty) {
      result.add(string);
      return result;
    }

    while (true) {
      var index = string.indexOf(separator, 0);
      if (index == -1 || (max > 0 && result.length >= max)) {
        result.add(string);
        break;
      }

      result.add(string.substring(0, index));
      string = string.substring(index + separator.length);
    }

    return result;
  }
}
