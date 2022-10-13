import 'package:http/http.dart';

class HTTPException implements Exception {
  final String message;
  final Response response;

  HTTPException(this.message, this.response);
}

/// Error thrown when assigning an invalid key to a [Map].
class KeyError implements Exception {
  final String message;

  KeyError(this.message);
}
