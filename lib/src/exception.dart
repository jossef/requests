import 'package:http/http.dart';

class HTTPException implements Exception {
  HTTPException(this.message, this.response);
  final String message;
  final Response response;
}

/// Error thrown when assigning an invalid key to a [Map].
class KeyError implements Exception {
  KeyError(this.message);
  final String message;
}
