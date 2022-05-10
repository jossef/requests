import 'package:quiver/collection.dart';

/// Error thrown when assigning an invalid key to a [Map].
class KeyError implements Exception {
  final String message;

  KeyError(this.message);
}

/// Object representation of a cookie.
class Cookie {
  final String _name;
  final String _value;
  static final Map<String, Type> validAttributes = {
    "comment": String,
    "domain": String,
    "expires": String,
    "httponly": bool,
    "path": String,
    "max-age": String,
    "secure": bool,
    "samesite": String,
  };

  final _attributes = <String, dynamic>{};

  Cookie(this._name, this._value);

  /// The name of [this].
  String get name => _name;

  /// The value of [this].
  String get value => _value;

  /// Constructs a request header.
  String output({String header = "Set-Cookie"}) {
    String string = "$header: $name=$value";

    _attributes.forEach((key, value) {
      if (value.runtimeType == String && value.length == 0) {
        return;
      }

      if (value.runtimeType == bool && value == false) {
        return;
      }

      string += "; $key";
      if (value.runtimeType != bool) {
        string += "=$value";
      }
    });

    return string;
  }

  /// Removes [key] and its associated [value], if present, from the attributes.
  String remove(String key) {
    return _attributes.remove(key);
  }

  /// The value for the given [key], or `null` if [key] is not
  /// in the attributes.
  String? operator [](String key) {
    return _attributes[key.toLowerCase()];
  }

  /// Associates the [key] with the given [value].
  ///
  /// Throws a [KeyError] if the key isn't a valid attribute,
  /// see [this.validAttributes].
  void operator []=(String key, dynamic value) {
    if (validAttributes.containsKey(key.toLowerCase())) {
      var attributeType = validAttributes[key.toLowerCase()];

      switch (attributeType) {
        case bool:
        case String:
          if (value.runtimeType == attributeType) {
            _attributes[key.toLowerCase()] = value;
          }
          return;
        default:
      }
    }
    throw KeyError("Input key is not valid: $key.");
  }

  /// Same as [this.output()].
  @override
  String toString() {
    return output();
  }
}

/// A custom [Map] that will store a sort of [List] of unique [Cookie].
class CookieJar extends DelegatingMap<String, Cookie> {
  final Map<String, Cookie> _cookies = {};

  @override
  Map<String, Cookie> get delegate => _cookies;

  /// Parses a string of cookies separated by commas into a [CookieJar].
  static CookieJar parseCookiesString(String cookiesString) {
    cookiesString = cookiesString.trim();

    var result = CookieJar();

    RegExp cookiesSplit = RegExp(
      r"""(?<!expires=\w{3}|"|')\s*,\s*(?!"|')""",
      caseSensitive: false,
    );

    RegExp cookieParse = RegExp(
      r"^(?<name>[^=]+)=(?<value>[^;]+);?(?<raw_attributes>.*)$",
    );

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
