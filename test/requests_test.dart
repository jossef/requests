import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('plain http get', () async {
      String body = await Requests.get("https://google.com");
      expect(body, isNotNull);
    });

    test('json http get list of objects', () async {
      dynamic body = await Requests.get("https://jsonplaceholder.typicode.com/posts", json: true);
      expect(body, isNotNull);
      expect(body, isList);
    });

    test('json http post', () async {
      var body = await Requests.post("https://jsonplaceholder.typicode.com/posts", body: {
        "userId": 10,
        "id": 91,
        "title": "aut amet sed",
        "body": "libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat",
      }, bodyEncoding: RequestBodyEncoding.FormURLEncoded);
      expect(body, isNotNull);
    });
    test('json http post as a form and as a JSON', () async {
      var res = await Requests.post("https://jsonplaceholder.typicode.com/posts", body: {
        "userId": 10,
        "id": 91,
        "title": "aut amet sed",
        "body": "libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat",
      }, bodyEncoding: RequestBodyEncoding.JSON, json: true);
      expect(res["userId"], 10);
    });

    test('json http get object', () async {
      dynamic body = await Requests.get("https://jsonplaceholder.typicode.com/posts/1", json: true);
      expect(body, isNotNull);
      expect(body, isMap);
    });

    test('remove cookies', () async {
      String url = "https://jsonplaceholder.typicode.com/posts/1";
      String hostname = Requests.getHostname(url);
      expect("jsonplaceholder.typicode.com", hostname);
      await Requests.clearStoredCookies(hostname);
      await Requests.setStoredCookies(hostname, {'session': 'bla'});
      var cookies = await Requests.getStoredCookies(hostname);
      expect(cookies.keys.length, 1);
      await Requests.clearStoredCookies(hostname);
      cookies = await Requests.getStoredCookies(hostname);
      expect(cookies.keys.length, 0);
    });
  });
}
