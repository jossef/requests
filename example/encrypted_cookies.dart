import 'package:hive/hive.dart';
import 'package:requests/requests.dart';

void main(List<String> args) async {
  // Generate a secure encryption key.
  final List<int> encryptionKey = Hive.generateSecureKey();

  final HiveAesCipher encryptionCipher = HiveAesCipher(encryptionKey);

  // Initialize [Requests] with a custom encrypted vault that will be stored
  // in the working directory.
  Requests.init(
    path: '.',
    vaultName: 'customvault',
    encryptionCipher: encryptionCipher,
  );

  String url = 'https://github.com/';
  String hostname = Requests.getHostname(url);

  // Get the cookies from `github.com`.
  Response response = await Requests.get(url);

  // Do something with [response]...

  var cookies = await Requests.getStoredCookies(hostname);
  print(cookies);

  // Play with [cookies]...
}
