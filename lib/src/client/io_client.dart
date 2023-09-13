import 'dart:io';

import 'package:http/http.dart' show Client;
import 'package:http/io_client.dart' show IOClient;

/// Creates a new platform appropriate client.
Client createClient({
  bool verify = true,
  bool withCredentials = false,
}) {
  final ioClient = HttpClient();
  if (!verify) {
    ioClient.badCertificateCallback = (_, __, ___) => true;
  }
  return IOClient(ioClient);
}
