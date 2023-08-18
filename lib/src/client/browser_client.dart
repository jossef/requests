import 'package:http/browser_client.dart' show BrowserClient;
import 'package:http/http.dart' show Client;

/// Creates a new platform appropriate client.
Client createClient({
  bool verify = true,
  bool withCredentials = false,
}) {
  final client = BrowserClient();
  if (withCredentials) {
    client.withCredentials = withCredentials;
  }
  return client;
}
