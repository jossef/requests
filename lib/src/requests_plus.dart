import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart';
import 'package:requests_plus/src/client/io_client.dart'
    if (dart.library.html) 'package:requests_plus/src/client/browser_client.dart';
import 'package:requests_plus/src/common.dart';
import 'package:requests_plus/src/cookie.dart';
import 'package:requests_plus/src/cookie_jar.dart';
import 'package:requests_plus/src/event.dart';
import 'package:requests_plus/src/response.dart';
import 'package:requests_plus/src/storage.dart';

// ignore: constant_identifier_names
enum RequestBodyEncoding { JSON, FormURLEncoded, PlainText, FormData }

// ignore: constant_identifier_names
enum HttpMethod { GET, PUT, PATCH, POST, DELETE, HEAD }

class RequestsPlus {
  const RequestsPlus();

  static final Event onError = Event();
  static const int defaultTimeoutSeconds = 10;
  static const RequestBodyEncoding defaultBodyEncoding =
      RequestBodyEncoding.FormURLEncoded;

  /// Gets the cookies of a [Response.headers] in the form of a [CookieJar].
  static CookieJar extractResponseCookies(
    Map<String, String> responseHeaders,
  ) {
    var result = CookieJar();
    final keys = responseHeaders.keys.map((e) => e.toLowerCase());

    if (keys.contains('set-cookie')) {
      final cookies = responseHeaders['set-cookie']!;
      result = CookieJar.parseCookiesString(cookies);
    }
    return result;
  }

  /// Get the [CookieJar] for the given [url] hostname, or an empty
  /// [CookieJar] if the hostname is not in the cache.
  static Future<CookieJar> getStoredCookies(String url) async {
    final hostname = Common.getHostname(url);
    final hostnameHash = Common.hashStringSHA256(hostname);
    final cookies = await Storage.get('cookies-$hostnameHash');

    return cookies ?? CookieJar();
  }

  /// Associates the [url] hostname with the given [cookies] into the cache.
  static Future setStoredCookies(String url, CookieJar cookies) async {
    final hostname = Common.getHostname(url);
    final hostnameHash = Common.hashStringSHA256(hostname);
    await Storage.set('cookies-$hostnameHash', cookies);
  }

  /// Removes the [url] hostname and its associated value, if present,
  /// from the cache.
  static Future clearStoredCookies(String url) async {
    final hostname = Common.getHostname(url);
    final hostnameHash = Common.hashStringSHA256(hostname);
    await Storage.delete('cookies-$hostnameHash');
  }

  /// Add a cookie with its [name] and [value] to the [url] hostname
  /// associated [CookieJar].
  static Future addCookie(String url, String name, String value) async {
    final cookieJar = await getStoredCookies(url);
    cookieJar[name] = Cookie(name, value);
    await setStoredCookies(url, cookieJar);
  }

  @Deprecated('Do not use this method, it is not needed anymore.')
  static String getHostname(String url) {
    return Common.getHostname(url);
  }

  static Future<Response> head(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    int? port,
    RequestBodyEncoding bodyEncoding = defaultBodyEncoding,
    int timeoutSeconds = defaultTimeoutSeconds,
    bool persistCookies = true,
    bool verify = true,
    bool withCredentials = false,
    String corsProxyUrl = '',
    bool followRedirects = true,
    String? userName,
    String? password,
  }) {
    return _httpRequest(
      HttpMethod.HEAD,
      url,
      bodyEncoding: bodyEncoding,
      queryParameters: queryParameters,
      port: port,
      headers: headers ?? const <String, String>{},
      timeoutSeconds: timeoutSeconds,
      persistCookies: persistCookies,
      verify: verify,
      withCredentials: withCredentials,
      corsProxyUrl: corsProxyUrl,
      followRedirects: followRedirects,
      userName: userName,
      password: password,
    );
  }

  static Future<Response> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    int? port,
    dynamic json,
    dynamic body,
    RequestBodyEncoding bodyEncoding = defaultBodyEncoding,
    int timeoutSeconds = defaultTimeoutSeconds,
    bool persistCookies = true,
    bool verify = true,
    bool withCredentials = false,
    String corsProxyUrl = '',
    bool followRedirects = true,
    String? userName,
    String? password,
  }) {
    return _httpRequest(
      HttpMethod.GET,
      url,
      bodyEncoding: bodyEncoding,
      queryParameters: queryParameters,
      port: port,
      json: json,
      body: body,
      headers: headers ?? const <String, String>{},
      timeoutSeconds: timeoutSeconds,
      persistCookies: persistCookies,
      verify: verify,
      withCredentials: withCredentials,
      corsProxyUrl: corsProxyUrl,
      followRedirects: followRedirects,
      userName: userName,
      password: password,
    );
  }

  static Future<Response> patch(
    String url, {
    Map<String, String>? headers,
    int? port,
    dynamic json,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    RequestBodyEncoding bodyEncoding = defaultBodyEncoding,
    int timeoutSeconds = defaultTimeoutSeconds,
    bool persistCookies = true,
    bool verify = true,
    bool withCredentials = false,
    String corsProxyUrl = '',
    bool followRedirects = true,
    String? userName,
    String? password,
  }) {
    return _httpRequest(
      HttpMethod.PATCH,
      url,
      bodyEncoding: bodyEncoding,
      port: port,
      json: json,
      body: body,
      queryParameters: queryParameters,
      headers: headers ?? <String, String>{},
      timeoutSeconds: timeoutSeconds,
      persistCookies: persistCookies,
      verify: verify,
      withCredentials: withCredentials,
      corsProxyUrl: corsProxyUrl,
      followRedirects: followRedirects,
      userName: userName,
      password: password,
    );
  }

  static Future<Response> delete(
    String url, {
    Map<String, String>? headers,
    dynamic json,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    int? port,
    RequestBodyEncoding bodyEncoding = defaultBodyEncoding,
    int timeoutSeconds = defaultTimeoutSeconds,
    bool persistCookies = true,
    bool verify = true,
    bool withCredentials = false,
    String corsProxyUrl = '',
    bool followRedirects = true,
    String? userName,
    String? password,
  }) {
    return _httpRequest(
      HttpMethod.DELETE,
      url,
      bodyEncoding: bodyEncoding,
      port: port,
      json: json,
      body: body,
      queryParameters: queryParameters,
      headers: headers ?? const <String, String>{},
      timeoutSeconds: timeoutSeconds,
      persistCookies: persistCookies,
      verify: verify,
      withCredentials: withCredentials,
      corsProxyUrl: corsProxyUrl,
      followRedirects: followRedirects,
      userName: userName,
      password: password,
    );
  }

  static Future<Response> post(
    String url, {
    dynamic json,
    int? port,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    RequestBodyEncoding bodyEncoding = defaultBodyEncoding,
    Map<String, String>? headers,
    int timeoutSeconds = defaultTimeoutSeconds,
    bool persistCookies = true,
    bool verify = true,
    bool withCredentials = false,
    String corsProxyUrl = '',
    bool followRedirects = true,
    String? userName,
    String? password,
  }) {
    return _httpRequest(
      HttpMethod.POST,
      url,
      bodyEncoding: bodyEncoding,
      json: json,
      port: port,
      body: body,
      queryParameters: queryParameters,
      headers: headers ?? <String, String>{},
      timeoutSeconds: timeoutSeconds,
      persistCookies: persistCookies,
      verify: verify,
      withCredentials: withCredentials,
      corsProxyUrl: corsProxyUrl,
      followRedirects: followRedirects,
      userName: userName,
      password: password,
    );
  }

  static Future<Response> put(
    String url, {
    int? port,
    dynamic json,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    RequestBodyEncoding bodyEncoding = defaultBodyEncoding,
    Map<String, String>? headers,
    int timeoutSeconds = defaultTimeoutSeconds,
    bool persistCookies = true,
    bool verify = true,
    bool withCredentials = false,
    String corsProxyUrl = '',
    bool followRedirects = true,
    String? userName,
    String? password,
  }) {
    return _httpRequest(
      HttpMethod.PUT,
      url,
      port: port,
      bodyEncoding: bodyEncoding,
      json: json,
      body: body,
      queryParameters: queryParameters,
      headers: headers ?? const <String, String>{},
      timeoutSeconds: timeoutSeconds,
      persistCookies: persistCookies,
      verify: verify,
      withCredentials: withCredentials,
      corsProxyUrl: corsProxyUrl,
      followRedirects: followRedirects,
      userName: userName,
      password: password,
    );
  }

  static Future<Map<String, String>> _constructRequestHeaders(
    String url,
    Map<String, String>? customHeaders,
    String corsProxyUrl,
    String? username,
    String? password,
  ) async {
    final requestHeaders = <String, String>{};

    final cookies = (await getStoredCookies(url)).values;
    final cookie = cookies.map((e) => '${e.name}=${e.value}').join('; ');

    final cookieHeader =
        (corsProxyUrl.isNotEmpty) ? 'cookie-proxied' : 'cookie';
    requestHeaders[cookieHeader] = cookie;

    if (customHeaders != null) {
      requestHeaders.addAll(customHeaders);
    }

    if (!requestHeaders.containsKey('authorization') &&
        username != null &&
        password != null) {
      requestHeaders['authorization'] =
          "Basic ${base64Encode(utf8.encode('$username:$password'))}";
    }

    return requestHeaders;
  }

  static Future<Response> _handleHttpResponse(
    String url,
    Response response,
    bool persistCookies,
    String corsProxyUrl,
    bool followRedirects,
    HttpMethod method,
    dynamic json,
    dynamic body,
    RequestBodyEncoding bodyEncoding,
    Map<String, dynamic>? queryParameters,
    int? port,
    Map<String, String> headers,
    int timeoutSeconds,
    bool verify,
    bool withCredentials,
    String? userName,
    String? password,
  ) async {
    if (response.headers.containsKey('set-cookie-proxied')) {
      if (response.headers.containsKey('set-cookie')) {
        response.headers['set-cookie'] =
            "${response.headers["set-cookie"]!}; ${response.headers["set-cookie-proxied"]!}";
      } else {
        response.headers['set-cookie'] =
            response.headers['set-cookie-proxied']!;
      }
      response.headers.remove('set-cookie-proxied');
    }

    if (persistCookies) {
      final responseCookies = extractResponseCookies(response.headers);
      if (responseCookies.isNotEmpty) {
        final storedCookies = await getStoredCookies(url);
        storedCookies.addAll(responseCookies);
        await setStoredCookies(url, storedCookies);
      }
    }

    if (response.hasError) {
      final errorEvent = {'response': response};
      onError.publish(errorEvent);
    }

    //handle redirects
    if (followRedirects && response.isRedirect) {
      if (response.headers.containsKey('location-proxied')) {
        response.headers['location'] = response.headers['location-proxied']!;
        response.headers.remove('location-proxied');
      }
      var uri = Uri.parse(response.headers['location']!);
      if (uri.scheme.isEmpty) uri = uri.replace(scheme: Uri.parse(url).scheme);
      if (uri.host.isEmpty) uri = uri.replace(host: Uri.parse(url).host);
      return _httpRequest(
        method,
        '${uri.scheme}://${uri.host}${uri.path}',
        port: uri.port,
        queryParameters: uri.queryParameters,
        bodyEncoding: bodyEncoding,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify,
        withCredentials: withCredentials,
        corsProxyUrl: corsProxyUrl,
        followRedirects: followRedirects,
        userName: userName,
        password: password,
      );
    }

    return response;
  }

  static Future<Response> _httpRequest(
    HttpMethod method,
    String url, {
    dynamic json,
    dynamic body,
    RequestBodyEncoding bodyEncoding = defaultBodyEncoding,
    Map<String, dynamic>? queryParameters,
    int? port,
    Map<String, String> headers = const {},
    int timeoutSeconds = defaultTimeoutSeconds,
    bool persistCookies = true,
    bool verify = true,
    bool withCredentials = false,
    String corsProxyUrl = '',
    bool followRedirects = true,
    String? userName,
    String? password,
  }) async {
    Client client;

    assert(
      (userName == null && password == null) ||
          (userName != null && password != null),
      'username and password must be used together or none',
    );
    if (!verify || withCredentials) {
      client = createClient(
        verify: verify,
        withCredentials: withCredentials,
      );
    } else {
      // The default client validates SSL certificates and fail if invalid
      client = Client();
    }

    var uri = Uri.parse(((corsProxyUrl.isNotEmpty) ? corsProxyUrl : '') + url);

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ArgumentError(
        "invalid url, must start with 'http://' or 'https://' scheme (e.g. 'http://example.com')",
      );
    }

    if (corsProxyUrl.isNotEmpty) {
      headers['follow-redirects'] = followRedirects.toString();
    }
    headers = await _constructRequestHeaders(
      url,
      headers,
      corsProxyUrl,
      userName,
      password,
    );
    String? requestBody;

    if (body != null && json != null) {
      throw ArgumentError('cannot use both "json" and "body" choose only one.');
    }

    if (queryParameters != null) {
      final stringQueryParameters = <String, dynamic>{};

      queryParameters.forEach(
        (key, value) => stringQueryParameters[key] = value is List
            ? (value.map((e) => e?.toString()))
            : value?.toString(),
      );

      uri = uri.replace(queryParameters: stringQueryParameters);
    }

    if (port != null) {
      if (corsProxyUrl.isNotEmpty) {
        final destination = Uri.parse(url)..replace(port: port);
        uri = Uri.parse(corsProxyUrl + destination.toString());
      } else {
        uri = uri.replace(port: port);
      }
    }

    if (json != null) {
      body = json;
      bodyEncoding = RequestBodyEncoding.JSON;
    }

    if (body != null) {
      String? contentTypeHeader;

      switch (bodyEncoding) {
        case RequestBodyEncoding.JSON:
          requestBody = Common.toJson(body);
          contentTypeHeader = 'application/json';
          break;
        case RequestBodyEncoding.FormURLEncoded:
          requestBody = Common.encodeMap(body);
          contentTypeHeader = 'application/x-www-form-urlencoded';
          break;
        case RequestBodyEncoding.PlainText:
          requestBody = body;
          contentTypeHeader = 'text/plain';
          break;
        case RequestBodyEncoding.FormData:
          final boundary = Common.generateBoundary();
          requestBody = Common.encodeFormData(body, boundary);
          contentTypeHeader = 'multipart/form-data; boundary=$boundary';
          break;
      }

      if (!Common.hasKeyIgnoreCase(headers, 'content-type')) {
        headers['content-type'] = contentTypeHeader;
      }
    }

    final request = Request(
      method.toString().split('.').last,
      uri,
    )
      ..followRedirects = false //followRedirects
      ..headers.addAll(headers); //little hack to get rid of HttpMethod.
    if ([HttpMethod.POST, HttpMethod.PUT, HttpMethod.PATCH, HttpMethod.DELETE]
            .contains(method) &&
        requestBody != null) {
      request.body = requestBody;
    }

    final streamedResponse =
        await client.send(request).timeout(Duration(seconds: timeoutSeconds));
    final response = await Response.fromStream(streamedResponse);

    return _handleHttpResponse(
      url,
      response,
      persistCookies,
      corsProxyUrl,
      followRedirects,
      method,
      json,
      body,
      bodyEncoding,
      queryParameters,
      port,
      headers,
      timeoutSeconds,
      verify,
      withCredentials,
      userName,
      password,
    );
  }
}
