import 'package:http/http.dart';
import 'package:universal_io/io.dart';

import 'package:requests/requests.dart';
import 'package:requests/src/common.dart';
import 'package:test/test.dart';

void _validateResponse(Response r) {
  expect(r.statusCode, isA<int>());
  expect(r.hasError, isA<bool>());
  expect(r.success, isA<bool>());
}

void main() {
  group('A group of tests', () {
    final String PLACEHOLDER_PROVIDER = 'https://reqres.in';

    test('plain http get', () async {
      var r = await Requests.get('https://google.com');
      r.raiseForStatus();
      dynamic body = r.content();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('plain http get with query parameters', () async {
      var r = await Requests.get('https://google.com',
          queryParameters: {'id': 1, 'name': null});
      r.raiseForStatus();
      dynamic body = r.content();
      expect(body, isNotNull);
      expect(r.url.toString(), contains('?id=1'));
      _validateResponse(r);
    });

    test('plain http get with port 80', () async {
      var r = await Requests.get('http://google.com', port: 80);
      r.raiseForStatus();
      _validateResponse(r);
      dynamic body = r.content();
      expect(body, isNotNull);
    });

    test('plain http get with port 8080', () async {
      var r =
          await Requests.get('http://portquiz.net:8080/', timeoutSeconds: 30);
      r.raiseForStatus();
    });

    test('json http get list of objects', () async {
      var r = await Requests.get('$PLACEHOLDER_PROVIDER/api/users');
      r.raiseForStatus();
      dynamic body = r.json();
      expect(body, isNotNull);
      expect(body['data'], isList);
      _validateResponse(r);
    });

    test('FormURLEncoded http post', () async {
      var r = await Requests.post('$PLACEHOLDER_PROVIDER/api/users',
          body: {
            'userId': 10,
            'id': 91,
            'title': 'aut amet sed',
            'body':
                'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
          },
          bodyEncoding: RequestBodyEncoding.FormURLEncoded);
      r.raiseForStatus();
      dynamic body = r.json();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('http post a list of object', () async {
      var r = await Requests.post('$PLACEHOLDER_PROVIDER/api/users', json: [
        {
          'userId': 10,
          'id': 91,
          'title': 'aut amet sed',
          'body':
              'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
        }
      ]);
      r.raiseForStatus();
      dynamic body = r.json();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('json http delete with request body', () async {
      var r = await Requests.delete(
        '$PLACEHOLDER_PROVIDER/api/users/10',
        json: {'something': 'something'},
      );
      r.raiseForStatus();
      _validateResponse(r);
    });

    test('json http post', () async {
      var r = await Requests.post('$PLACEHOLDER_PROVIDER/api/users', json: {
        'userId': 10,
        'id': 91,
        'title': 'aut amet sed',
        'body':
            'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
      });
      r.raiseForStatus();
      dynamic body = r.json();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('json http delete', () async {
      var r = await Requests.delete('$PLACEHOLDER_PROVIDER/api/users/10');
      r.raiseForStatus();
      _validateResponse(r);
    });

    test('json http post as a form and as a JSON', () async {
      var r = await Requests.post('$PLACEHOLDER_PROVIDER/api/users', json: {
        'userId': 10,
        'id': 91,
        'title': 'aut amet sed',
        'body':
            'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
      });
      r.raiseForStatus();
      dynamic body = r.json();
      expect(body['userId'], 10);
      _validateResponse(r);
    });

    test('json http get object', () async {
      var r = await Requests.get('$PLACEHOLDER_PROVIDER/api/users/2');
      r.raiseForStatus();
      dynamic body = r.json();
      expect(body, isNotNull);
      expect(body, isMap);
      _validateResponse(r);
    });

    test('remove cookies', () async {
      String url = '$PLACEHOLDER_PROVIDER/api/users/1';
      await Requests.clearStoredCookies(url);
      var cookies = CookieJar.parseCookiesString("session=bla");
      await Requests.setStoredCookies(url, cookies);
      cookies = await Requests.getStoredCookies(url);
      expect(cookies.keys.length, 1);
      await Requests.clearStoredCookies(url);
      cookies = await Requests.getStoredCookies(url);
      expect(cookies.keys.length, 0);
    });

    test('add cookies', () async {
      String url = 'http://example.com';
      await Requests.addCookie(url, 'name', 'value');
      var cookies = await Requests.getStoredCookies(url);
      expect(cookies.keys.length, 1);
      await Requests.addCookie(url, 'name', 'value');
      cookies = await Requests.getStoredCookies(url);
      expect(cookies.keys.length, 1);
      await Requests.addCookie(url, 'another-name', 'value');
      cookies = await Requests.getStoredCookies(url);
      expect(cookies.keys.length, 2);
      await Requests.clearStoredCookies(url);
      cookies = await Requests.getStoredCookies(url);
      expect(cookies.keys.length, 0);
    });

    test('response as Response object', () async {
      var r = await Requests.post('$PLACEHOLDER_PROVIDER/api/users',
          body: {'name': 'morpheus'});
      r.raiseForStatus();
      var content = r.content();
      var json = r.json();
      expect(content, isNotNull);
      expect(json, isNotNull);
      _validateResponse(r);
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
        await Requests.post('$PLACEHOLDER_PROVIDER/api/unknown/23',
            body: {}, json: {});
      } on ArgumentError catch (_) {
        return;
      }
      throw Exception('Expected request error');
    });

    test('ssl should fail due to expired certificate', () async {
      try {
        var r = await Requests.get('https://expired.badssl.com/');
        r.raiseForStatus();
      } on Exception catch (_) {
        return;
      }

      throw Exception('Expected ssl error');
    });

    test('ssl allow invalid', () async {
      var r = await Requests.get('https://expired.badssl.com/', verify: false);
      r.raiseForStatus();
    });

    test('cookie parsing', () {
      var headers = Map<String, String>();
      var cookiesString = """
        session=mySecret; path=/myPath,
        data=1=2=3=4; _ga=GA1.4..1563550573; ; ; ; textsize=NaN; tp_state=true; _ga=GA1.3..1563550573,
        __browsiUID=03b1cb22-d18d-05c3d7daff82600c044b1b4edd096e75,
        _cb_ls=1; _cb=CaBNIWCf-db-3i9ro; _chartbeat2=..414141414.1..1; AMUUID=%; _fbp=fb.2..,
        adblockerfound=true 
      """;
      headers['set-cookie'] = cookiesString;
      var cookies = Requests.extractResponseCookies(headers);

      expect(
        cookies["session"]!.toString(),
        "session=mySecret; Path=/mypath",
      );

      expect(
        cookies['data']!.toString(),
        "data=1=2=3=4",
      );

      expect(
        cookies['__browsiUID']!.toString(),
        '__browsiUID=03b1cb22-d18d-05c3d7daff82600c044b1b4edd096e75',
      );

      expect(
        cookies['_cb_ls']!.toString(),
        "_cb_ls=1",
      );

      expect(
        cookies['adblockerfound']!.toString(),
        "adblockerfound=true",
      );
    });

    test('from json', () {
      expect(Common.fromJson('{"a":1}'), {"a": 1});
      expect(Common.fromJson(null), null);
    });

    test('Common.getHostname', () {
      var url = PLACEHOLDER_PROVIDER;
      var host = Common.getHostname(url);
      expect(host, 'reqres.in');
      expect(Common.getHostname(host), 'reqres.in');
      expect(Common.getHostname('$host/?=test'), 'reqres.in');
      expect(Common.getHostname('$host:/?=test'), 'reqres.in');
      expect(Common.getHostname('$host:8080/?=test'), 'reqres.in');
    });
  });
}
