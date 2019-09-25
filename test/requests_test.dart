import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    const PLACEHOLDER_PROVIDER = 'https://reqres.in';
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('plain http get', () async {
      String body = await Requests.get("https://google.com");
      expect(body, isNotNull);
    });

    test('json http get list of objects', () async {
      dynamic body =
          await Requests.get("$PLACEHOLDER_PROVIDER/api/users", json: true);
      expect(body, isNotNull);
      expect(body['data'], isList);
    });

    test('json http post', () async {
      var body = await Requests.post("$PLACEHOLDER_PROVIDER/api/users",
          body: {
            "userId": 10,
            "id": 91,
            "title": "aut amet sed",
            "body":
                "libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat",
          },
          bodyEncoding: RequestBodyEncoding.FormURLEncoded);
      expect(body, isNotNull);
    });
    test('json http post as a form and as a JSON', () async {
      var res = await Requests.post("$PLACEHOLDER_PROVIDER/api/users",
          body: {
            "userId": 10,
            "id": 91,
            "title": "aut amet sed",
            "body":
                "libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat",
          },
          bodyEncoding: RequestBodyEncoding.JSON,
          json: true);
      expect(res["userId"], 10);
    });

    test('json http get object', () async {
      dynamic body =
          await Requests.get("$PLACEHOLDER_PROVIDER/api/users/2", json: true);
      expect(body, isNotNull);
      expect(body, isMap);
    });

    test('remove cookies', () async {
      String url = "$PLACEHOLDER_PROVIDER/api/users/1";
      String hostname = Requests.getHostname(url);
      expect("reqres.in", hostname);
      await Requests.clearStoredCookies(hostname);
      await Requests.setStoredCookies(hostname, {'session': 'bla'});
      var cookies = await Requests.getStoredCookies(hostname);
      expect(cookies.keys.length, 1);
      await Requests.clearStoredCookies(hostname);
      cookies = await Requests.getStoredCookies(hostname);
      expect(cookies.keys.length, 0);
    });

    test('response as Response object', () async {
      dynamic response = await Requests.post('$PLACEHOLDER_PROVIDER/api/users',
          body: {"name": "morpheus"}, json: true, dataOnly: false);
      expect(response.ok, isA<bool>());
      expect(response.data, isNotNull);
      expect(response.code, isA<int>());
    });

    test('throw error', () async {
      try {
        await Requests.get('$PLACEHOLDER_PROVIDER/api/unknown/23',
            shouldThrow: true);
      } catch (resp) {
        expect(resp, isA<Response>());
        expect(resp.ok, false);
        return;
      }
      throw Exception('Expected request error');
    });
  });
}
