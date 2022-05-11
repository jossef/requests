part of 'response.dart';

class HTTPException implements Exception {
  final String message;
  final Response response;

  HTTPException(this.message, this.response);
}
