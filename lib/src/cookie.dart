import 'package:universal_io/io.dart';

extension CookieExtension on Cookie {
  /// Constructs a request header.
  String output({String header = "Set-Cookie"}) {
    return "$header: " + toString();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'expires': expires?.toIso8601String(),
        'maxAge': maxAge,
        'domain': domain,
        'path': path,
        'secure': secure,
        'httpOnly': httpOnly,
      };

  Cookie fromJson(Map<String, dynamic> json) {
    var cookie = Cookie(json['name'], json['value']);
    cookie.expires =
        json['expires'] != null ? DateTime.parse(json['expires']) : null;
    cookie.maxAge = json['maxAge'];
    cookie.domain = json['domain'];
    cookie.path = json['path'];
    cookie.secure = json['secure'];
    cookie.httpOnly = json['httpOnly'];
    return cookie;
  }
}
