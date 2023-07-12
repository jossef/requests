import 'package:quiver/collection.dart';

import 'package:requests_plus/src/cookie.dart';

/// A custom [Map] that will store a sort of [List] of unique [Cookie].
class CookieJar extends DelegatingMap<String, Cookie> {
  final Map<String, Cookie> _cookies = {};

  @override
  Map<String, Cookie> get delegate => _cookies;

  /// Parses a string of cookies separated by commas into a [CookieJar].
  static CookieJar parseCookiesString(String cookiesString) {
    cookiesString = cookiesString.trim();

    var result = CookieJar();

    // Matches commas that separate cookies.
    // Commas shall not be between " or ' as it would be some json string.
    // We assume that there will be no commas inside keys or values.
    RegExp cookiesSplit = RegExp(
      r"""(?<!expires=\w{3}|"|')\s*,\s*(?!"|')""",
      caseSensitive: false,
    );

    // Separates the name, value and attributes of one cookie.
    // The attributes will still need to be parsed.
    RegExp cookieParse = RegExp(
      r"^(?<name>[^=]+)=(?<value>[^;]+);?(?<raw_attributes>.*)$",
    );

    // Matches the key / value pair of an attribute of a cookie.
    RegExp attributesParse = RegExp(
      r"(?<key>[^;=\s]+)(?:=(?<value>[^=;\n]+))?",
    );

    for (var rawCookie in cookiesString.split(cookiesSplit)) {
      var parsedCookie = cookieParse.firstMatch(rawCookie);
      if (parsedCookie != null) {
        var name = parsedCookie.namedGroup("name")!;
        var value = parsedCookie.namedGroup("value")!;
        var rawAttributes = parsedCookie.namedGroup("raw_attributes")!;

        var cookie = Cookie(name, value);

        for (var parsedAttribute in attributesParse.allMatches(rawAttributes)) {
          var attributeKey = parsedAttribute.namedGroup("key")!;
          var attributeValue = parsedAttribute.namedGroup("value");

          if (Cookie.validAttributes.containsKey(attributeKey.toLowerCase())) {
            cookie[attributeKey] = attributeValue ?? true;
          }
        }

        result[name] = cookie;
      }
    }

    return result;
  }
}
