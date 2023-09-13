import 'dart:convert' as c;

import 'package:http/http.dart';

import 'package:requests/src/exception.dart';

extension ResponseExtension on Response {
  bool get hasError => (400 <= statusCode) && (statusCode < 600);

  bool get success => !hasError;

  Uri? get url => request?.url;

  String? get contentType => headers['content-type'];

  List<int> bytes() => bodyBytes;

  String content() => c.utf8.decode(bytes(), allowMalformed: true);

  dynamic json() => c.json.decode(content());

  void throwForStatus() {
    if (hasError) {
      throw HTTPException(
        'Invalid HTTP status code $statusCode for url $url',
        this,
      );
    }
  }

  void raiseForStatus() {
    throwForStatus();
  }
}
