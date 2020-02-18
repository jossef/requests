import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:test/test.dart";

void main() {
  group('A group of tests', () {
    const PLACEHOLDER_PROVIDER = 'https://reqres.in';
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('plain http get', () async {
      var r = await Requests.get("https://google.com");
      r.raiseForStatus();
      dynamic body = r.content();
      expect(body, isNotNull);
    });

    test('json http get list of objects', () async {
      dynamic r = await Requests.get("$PLACEHOLDER_PROVIDER/api/users");
      r.raiseForStatus();

      dynamic body = r.json();

      expect(body, isNotNull);
      expect(body['data'], isList);
    });

    test('FormURLEncoded http post', () async {
      var r = await Requests.post("$PLACEHOLDER_PROVIDER/api/users",
          body: {
            "userId": 10,
            "id": 91,
            "title": "aut amet sed",
            "body": "libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat",
          },
          bodyEncoding: RequestBodyEncoding.FormURLEncoded);

      r.raiseForStatus();

      dynamic body = r.json();
      expect(body, isNotNull);
    });

    test('json http post', () async {
      var r = await Requests.post("$PLACEHOLDER_PROVIDER/api/users", json: {
        "userId": 10,
        "id": 91,
        "title": "aut amet sed",
        "body": "libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat",
      });

      r.raiseForStatus();

      dynamic body = r.json();
      expect(body, isNotNull);
    });

    test('json http delete', () async {
      var r = await Requests.delete("$PLACEHOLDER_PROVIDER/api/users/10");
      r.raiseForStatus();
    });

    test('json http post as a form and as a JSON', () async {
      var r = await Requests.post("$PLACEHOLDER_PROVIDER/api/users",
          json: {
            "userId": 10,
            "id": 91,
            "title": "aut amet sed",
            "body": "libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat",
          });
      r.raiseForStatus();

      dynamic body = r.json();
      expect(body["userId"], 10);
    });

    test('json http get object', () async {
      var r = await Requests.get("$PLACEHOLDER_PROVIDER/api/users/2");
      r.raiseForStatus();

      dynamic body = r.json();
      expect(body, isNotNull);
      expect(body, isMap);
    });

    test('remove cookies', () async {
      String url = "$PLACEHOLDER_PROVIDER/api/users/1";
      String hostname = Requests.getHostname(url);
      expect("reqres.in:443", hostname);
      await Requests.clearStoredCookies(hostname);
      await Requests.setStoredCookies(hostname, {'session': 'bla'});
      var cookies = await Requests.getStoredCookies(hostname);
      expect(cookies.keys.length, 1);
      await Requests.clearStoredCookies(hostname);
      cookies = await Requests.getStoredCookies(hostname);
      expect(cookies.keys.length, 0);
    });

    test('response as Response object', () async {
      var r = await Requests.post('$PLACEHOLDER_PROVIDER/api/users', body: {"name": "morpheus"});
      r.raiseForStatus();
      var content = r.content();
      var json = r.json();

      expect(r.success, isA<bool>());
      expect(content, isNotNull);
      expect(json, isNotNull);
      expect(r.statusCode, isA<int>());
    });

    test('throw error', () async {
      try {
        var r = await Requests.get('$PLACEHOLDER_PROVIDER/api/unknown/23');
        r.raiseForStatus();
      } on HTTPException catch (e) {
        expect(e.response, isA<Response>());
        expect(e.response.success, false);
        return;
      }
      throw Exception('Expected request error');
    });

    test('throw if both json and body used', () async {
      try {
        await Requests.post('$PLACEHOLDER_PROVIDER/api/unknown/23', body: {}, json: {});
      } on ArgumentError catch (e) {
        return;
      }
      throw Exception('Expected request error');
    });

    test('ssl should fail due to expired certificate', () async {
      try {
        var r = await Requests.get('https://expired.badssl.com/');
        r.raiseForStatus();
      } on Exception catch (e) {
        return;
      }

      throw Exception('Expected ssl error');
    });

    test('ssl allow invalid', () async {
      var r = await Requests.get('https://expired.badssl.com/', verify: false);
      r.raiseForStatus();
    });

    test('http test custom port', () async {
      var r = await Requests.get('http://portquiz.net:8080/');
      r.raiseForStatus();
    });
  });
}
