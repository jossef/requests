import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class Common {
  const Common();

  static storageSet(String key, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(key, value);
  }

  static storageGet(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key);
  }

  static bool equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  static String toJson(dynamic object) {
    var encoder = JsonEncoder.withIndent("     ");
    return encoder.convert(object);
  }

  static dynamic fromJson(String jsonString) {
    return json.decode(jsonString);
  }

  static bool hasKeyIgnoreCase(Map map, String key) {
    return map.keys.any((x) => equalsIgnoreCase(x, key));
  }

  static String toHexString(List data) {
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
      return "${k}=${v}";
    }).join("&");
  }
}
