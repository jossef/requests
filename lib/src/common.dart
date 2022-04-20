import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_hive/stash_hive.dart';
import 'package:crypto/crypto.dart';

class Common {
  const Common();

  // The vault containing the cookies. Can be initialized before usage using `setCookieVault`,
  // otherwise it will be created using `createDefaultCookieVault`.
  static Vault<String>? vault;

  /// Add / Replace this [Vault] [value] for the specified [key].
  ///
  /// * [key]: the key
  /// * [value]: the value
  static Future<void> storageSet(String key, String value) async {
    final vault = getVault();
    await vault.put(key, value);
  }

  /// Returns the stash value for the specified [key]
  ///
  /// * [key]: the key
  ///
  /// Returns a [String]
  static Future<String?> storageGet(String key) async {
    final vault = getVault();
    return await vault.get(key);
  }

  /// Removes the mapping for a [key] from this [Vault] if it is present.
  ///
  /// * [key]: key whose mapping is to be removed from the [Vault]
  ///
  /// Returns `true` if the removal of the mapping for the specified [key] was successful.
  static Future<bool> storageRemove(String key) async {
    final vault = getVault();
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

  /// Gets or creates the cookie vault.
  static Vault<String> getVault() {
    return vault ?? (vault = createDefaultCookieVault());
  }

  /// Creates a default, plain-text Hive store and vault in the system temporary directory.
  static Vault<String> createDefaultCookieVault() {
    final path = Directory.systemTemp.path;
    final store = newHiveDefaultVaultStore(path: path);
    return store.vault<String>(
        name: 'cookieVault', eventListenerMode: EventListenerMode.synchronous);
  }

  /// Defines the cookie vault for this process.
  /// No-op if a cookie vault is already defined.
  static Vault<String> setCookieVault(Vault<String> newVault) {
    assert(vault == null, 'Cookie vault is already initialized');
    return vault ?? (vault = newVault);
  }
}
