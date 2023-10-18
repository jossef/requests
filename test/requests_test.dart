import 'package:http/http.dart';

import 'package:requests_plus/requests_plus.dart';
import 'package:requests_plus/src/common.dart';
import 'package:test/test.dart';

void _validateResponse(Response r) {
  expect(r.statusCode, isA<int>());
  expect(r.hasError, isA<bool>());
  expect(r.success, isA<bool>());
}

void main() {
  group('A group of tests', () {
    const placeholderProvider = 'https://reqres.in';

    test('plain http get', () async {
      final r = await RequestsPlus.get('https://google.com');
      r.raiseForStatus();
      final dynamic body = r.content();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('plain http get with query parameters', () async {
      final r = await RequestsPlus.get(
        'https://google.com',
        queryParameters: {'id': 1, 'name': null},
      );
      r.raiseForStatus();
      final dynamic body = r.content();
      expect(body, isNotNull);
      expect(r.url.toString(), contains('?id=1'));
      _validateResponse(r);
    });

    test('plain http get with port 80', () async {
      final r = await RequestsPlus.get('http://google.com', port: 80);
      r.raiseForStatus();
      _validateResponse(r);
      final dynamic body = r.content();
      expect(body, isNotNull);
    });

    test('plain http get with port 8080', () async {
      final r = await RequestsPlus.get(
        'http://portquiz.net:8080/',
        timeoutSeconds: 30,
      );
      r.raiseForStatus();
    });

    test('json http get list of objects', () async {
      final r = await RequestsPlus.get('$placeholderProvider/api/users');
      r.raiseForStatus();
      final dynamic body = r.json();
      expect(body, isNotNull);
      expect(body['data'], isList);
      _validateResponse(r);
    });

    test('FormURLEncoded http post', () async {
      final r = await RequestsPlus.post(
        '$placeholderProvider/api/users',
        body: {
          'userId': 10,
          'id': 91,
          'title': 'aut amet sed',
          'body':
              'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
        },
      );
      r.raiseForStatus();
      final body = r.json();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('http get with auth', () async {
      final r = await RequestsPlus.get(
        'https://authenticationtest.com/HTTPAuth/',
        userName: 'user',
        password: 'pass',
      );
      r.raiseForStatus();
      expect(r.body.contains('Login Success'), true);
      _validateResponse(r);
    });

    test('http post a list of object', () async {
      final r = await RequestsPlus.post(
        '$placeholderProvider/api/users',
        json: [
          {
            'userId': 10,
            'id': 91,
            'title': 'aut amet sed',
            'body':
                'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
          },
        ],
      );
      r.raiseForStatus();
      final dynamic body = r.json();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('http post a list of object', () async {
      final r = await RequestsPlus.post(
        '$placeholderProvider/api/users',
        json: [
          {
            'userId': 10,
            'id': 91,
            'title': 'aut amet sed',
            'body':
                'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
          }
        ],
      );
      r.raiseForStatus();
      final dynamic body = r.json();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('json http delete with request body', () async {
      final r = await RequestsPlus.delete(
        '$placeholderProvider/api/users/10',
        json: {'something': 'something'},
      );
      r.raiseForStatus();
      _validateResponse(r);
    });

    test('json http post', () async {
      final r = await RequestsPlus.post(
        '$placeholderProvider/api/users',
        json: {
          'userId': 10,
          'id': 91,
          'title': 'aut amet sed',
          'body':
              'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
        },
      );
      r.raiseForStatus();
      final dynamic body = r.json();
      expect(body, isNotNull);
      _validateResponse(r);
    });

    test('json http delete', () async {
      final r = await RequestsPlus.delete('$placeholderProvider/api/users/10');
      r.raiseForStatus();
      _validateResponse(r);
    });

    test('json http post as a form and as a JSON', () async {
      final r = await RequestsPlus.post(
        '$placeholderProvider/api/users',
        json: {
          'userId': 10,
          'id': 91,
          'title': 'aut amet sed',
          'body':
              'libero voluptate eveniet aperiam sed\nsunt placeat suscipit molestias\nsimilique fugit nam natus\nexpedita consequatur consequatur dolores quia eos et placeat',
        },
      );
      r.raiseForStatus();
      final dynamic body = r.json();
      expect(body['userId'], 10);
      _validateResponse(r);
    });

    test(
      'json http get object',
      () async {
        final r = await RequestsPlus.get('$placeholderProvider/api/users/2');
        r.raiseForStatus();
        final dynamic body = r.json();
        expect(body, isNotNull);
        expect(body, isMap);
        _validateResponse(r);
      },
    );

    test('remove cookies', () async {
      const url = '$placeholderProvider/api/users/1';
      await RequestsPlus.clearStoredCookies(url);
      var cookies = CookieJar.parseCookiesString('session=bla');
      await RequestsPlus.setStoredCookies(url, cookies);
      cookies = await RequestsPlus.getStoredCookies(url);
      expect(cookies.keys.length, 1);
      await RequestsPlus.clearStoredCookies(url);
      cookies = await RequestsPlus.getStoredCookies(url);
      expect(cookies.keys.length, 0);
    });

    test('add cookies', () async {
      const url = 'http://example.com';
      await RequestsPlus.addCookie(url, 'name', 'value');
      var cookies = await RequestsPlus.getStoredCookies(url);
      expect(cookies.keys.length, 1);
      await RequestsPlus.addCookie(url, 'name', 'value');
      cookies = await RequestsPlus.getStoredCookies(url);
      expect(cookies.keys.length, 1);
      await RequestsPlus.addCookie(url, 'another name', 'value');
      cookies = await RequestsPlus.getStoredCookies(url);
      expect(cookies.keys.length, 2);
      await RequestsPlus.clearStoredCookies(url);
      cookies = await RequestsPlus.getStoredCookies(url);
      expect(cookies.keys.length, 0);
    });

    test('response as Response object', () async {
      final r = await RequestsPlus.post(
        '$placeholderProvider/api/users',
        body: {'name': 'morpheus'},
      );
      r.raiseForStatus();
      final content = r.content();
      final json = r.json();
      expect(content, isNotNull);
      expect(json, isNotNull);
      _validateResponse(r);
    });

    test('throw error', () async {
      try {
        final r = await RequestsPlus.get('$placeholderProvider/api/unknown/23');
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
        await RequestsPlus.post(
          '$placeholderProvider/api/unknown/23',
          body: {},
          json: {},
        );
      } catch (_) {
        return;
      }
      throw Exception('Expected request error');
    });

    test('ssl should fail due to expired certificate', () async {
      try {
        final r = await RequestsPlus.get('https://expired.badssl.com/');
        r.raiseForStatus();
      } on Exception catch (_) {
        return;
      }

      throw Exception('Expected ssl error');
    });

    test('ssl allow invalid', () async {
      final r =
          await RequestsPlus.get('https://expired.badssl.com/', verify: false);
      r.raiseForStatus();
    });

    test('multiple Set-Cookie response header', () async {
      final r = await RequestsPlus.get('http://samesitetest.com/cookies/set');
      final cookies = RequestsPlus.extractResponseCookies(r.headers);

      expect(
        cookies['StrictCookie']!.output(),
        'Set-Cookie: StrictCookie=Cookie set with SameSite=Strict; path=/; httponly; samesite=strict',
      );
      expect(
        cookies['LaxCookie']!.output(),
        'Set-Cookie: LaxCookie=Cookie set with SameSite=Lax; path=/; httponly; samesite=lax',
      );
      expect(
        cookies['SecureNoneCookie']!.output(),
        'Set-Cookie: SecureNoneCookie=Cookie set with SameSite=None and Secure; path=/; secure; httponly; samesite=none',
      );
      expect(
        cookies['NoneCookie']!.output(),
        'Set-Cookie: NoneCookie=Cookie set with SameSite=None; path=/; httponly; samesite=none',
      );
      expect(
        cookies['DefaultCookie']!.output(),
        'Set-Cookie: DefaultCookie=Cookie set without a SameSite attribute; path=/; httponly',
      );
    });

    test('cookie parsing', () async {
      final headers = <String, String>{};
      const cookiesString = '''
        session=mySecret; path=/myPath; expires=Xxx, x-x-x x:x:x XXX,
        data=1=2=3=4; _ga=GA1.4..1563550573; ; ; ; textsize=NaN; tp_state=true; _ga=GA1.3..1563550573,
        __browsiUID=03b1cb22-d18d-&{"bt":"Browser","os":"Windows","osv":"10.0","m":"Desktop|Emulator","v":"Unknown","b":"Chrome","p":2},
        _cb_ls=1; _cb=CaBNIWCf-db-3i9ro; _chartbeat2=..414141414.1..1; AMUUID=%; _fbp=fb.2..,
        adblockerfound=true 
      ''';
      headers['set-cookie'] = cookiesString;
      final cookies = RequestsPlus.extractResponseCookies(headers);

      expect(
        cookies['session']!.output(),
        'Set-Cookie: session=mySecret; path=/myPath; expires=Xxx, x-x-x x:x:x XXX',
      );

      expect(
        cookies['data']!.output(),
        'Set-Cookie: data=1=2=3=4',
      );

      expect(
        cookies['__browsiUID']!.output(),
        'Set-Cookie: __browsiUID=03b1cb22-d18d-&{"bt":"Browser","os":"Windows","osv":"10.0","m":"Desktop|Emulator","v":"Unknown","b":"Chrome","p":2}',
      );

      expect(
        cookies['_cb_ls']!.output(),
        'Set-Cookie: _cb_ls=1',
      );

      expect(
        cookies['adblockerfound']!.output(),
        'Set-Cookie: adblockerfound=true',
      );
    });

    test('from json', () async {
      expect(Common.fromJson('{"a":1}'), {'a': 1});
      expect(Common.fromJson(null), null);
    });

    test('Common.getHostname', () {
      const url = placeholderProvider;
      final host = Common.getHostname(url);
      expect(host, 'reqres.in');
      expect(Common.getHostname(host), 'reqres.in');
      expect(Common.getHostname('$host/?=test'), 'reqres.in');
      expect(Common.getHostname('$host:/?=test'), 'reqres.in');
      expect(Common.getHostname('$host:8080/?=test'), 'reqres.in');
    });

    test('Common.encodeFormData', () {
      final data = {
        'some Data': 'some Value',
        'another Data': 'another Value',
        'third Data': 'third Value',
      };
      final host = Common.encodeFormData(data, Common.generateBoundary());
      final splited = host.split('\r\n');
      expect(splited[1], 'Content-Disposition: form-data; name="some Data"');
      expect(splited[3], 'some Value');
      expect(splited[5], 'Content-Disposition: form-data; name="another Data"');
      expect(splited[7], 'another Value');
      expect(splited[9], 'Content-Disposition: form-data; name="third Data"');
      expect(splited[11], 'third Value');
      expect(splited[0] == splited[4] && splited[4] == splited[8], true);
      expect(splited[0].replaceAll('-', ''), splited[12].replaceAll('-', ''));
    });
  });
}
