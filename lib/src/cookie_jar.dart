import 'package:quiver/collection.dart';
import 'package:universal_io/io.dart';

/// A custom [Map] that will store a sort of [List] of unique [Cookie].
class CookieJar extends DelegatingMap<String, Cookie> {
  CookieJar();

  final Map<String, Cookie> _cookies = {};

  @override
  Map<String, Cookie> get delegate => _cookies;

  factory CookieJar.parseCookiesString(String cookiesString) {
    var cookies = CookieJar();

    for (final rawCookie in cookiesString.split(_regexSplitSetCookies)) {
      var cookie = Cookie.fromSetCookieValue(rawCookie);
      cookies[cookie.name] = cookie;
    }

    return cookies;
  }

  /// The regex pattern for splitting the set-cookie header.
  static final RegExp _regexSplitSetCookies = RegExp(
    r"""(?<!expires=\w{3}|"|')\s*,\s*(?!"|')""",
    caseSensitive: false,
  );
}
