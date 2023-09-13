import 'package:quiver/collection.dart';

import 'package:requests/src/cookie.dart';

/// A custom [Map] that will store a sort of [List] of unique [Cookie].
class CookieJar extends DelegatingMap<String, Cookie> {
  final Map<String, Cookie> _cookies = {};

  @override
  Map<String, Cookie> get delegate => _cookies;

  /// Parses a string of cookies separated by commas into a [CookieJar].
  static CookieJar parseCookiesString(String cookiesString) {
    final result = CookieJar();

    // Matches commas that separate cookies.
    // Commas shall not be between " or ' as it would be some json string.
    // We assume that there will be no commas inside keys or values.
    final cookiesSplit = RegExp(
      r"""(?<!expires=\w{3}|"|')\s*,\s*(?!"|')""",
      caseSensitive: false,
    );

    // Separates the name, value and attributes of one cookie.
    // The attributes will still need to be parsed.
    final cookieParse = RegExp(
      r'^(?<name>[^=]+)=(?<value>[^;]+);?(?<raw_attributes>.*)$',
    );

    // Matches the key / value pair of an attribute of a cookie.
    final attributesParse = RegExp(
      r'(?<key>[^;=\s]+)(?:=(?<value>[^=;\n]+))?',
    );

    for (final rawCookie in cookiesString.trim().split(cookiesSplit)) {
      final parsedCookie = cookieParse.firstMatch(rawCookie);
      if (parsedCookie != null) {
        final name = parsedCookie.namedGroup('name')!;
        final value = parsedCookie.namedGroup('value')!;
        final rawAttributes = parsedCookie.namedGroup('raw_attributes')!;

        final cookie = Cookie(name, value);

        for (final parsedAttribute
            in attributesParse.allMatches(rawAttributes)) {
          final attributeKey = parsedAttribute.namedGroup('key')!;
          final attributeValue = parsedAttribute.namedGroup('value');

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
