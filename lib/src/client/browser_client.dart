import 'package:http/http.dart' show Client;
import 'package:http/browser_client.dart' show BrowserClient;

/// Creates a new platform appropriate client.
Client createClient({
  bool verify = true,
  bool withCredentials = false,
}) {
  var client = BrowserClient();
  if (withCredentials) {
    client.withCredentials = withCredentials;
  }
  return client;
}
