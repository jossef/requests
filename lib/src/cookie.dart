import 'package:requests_plus/src/exception.dart';

/// Object representation of a cookie.
class Cookie {
  Cookie(this._name, this._value);
  final String _name;
  final String _value;
  static final Map<String, Type> validAttributes = {
    'comment': String,
    'domain': String,
    'expires': String,
    'httponly': bool,
    'path': String,
    'max-age': String,
    'secure': bool,
    'samesite': String,
  };

  final _attributes = <String, dynamic>{};

  /// The name of this.
  String get name => _name;

  /// The value of this.
  String get value => _value;

  /// Constructs a request header.
  String output({String header = 'Set-Cookie'}) {
    var string = '$header: $name=$value';

    _attributes.forEach((key, value) {
      if (value.runtimeType == String && value.length == 0) {
        return;
      }

      if (value.runtimeType == bool && value == false) {
        return;
      }

      string += '; $key';
      if (value.runtimeType != bool) {
        string += '=$value';
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
      final attributeType = validAttributes[key.toLowerCase()];

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
    throw KeyError('Input key is not valid: $key.');
  }

  /// Same as [this.output()].
  @override
  String toString() {
    return output();
  }
}
