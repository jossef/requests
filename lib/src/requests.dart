import 'dart:core';

import 'package:http/http.dart';
import 'package:universal_io/io.dart';

import 'package:requests/src/common.dart';
import 'package:requests/src/cookie_jar.dart';
import 'package:requests/src/event.dart';
import 'package:requests/src/response.dart';
import 'package:requests/src/storage.dart';
import 'package:requests/src/client/io_client.dart'
    if (dart.library.html) 'package:requests/src/client/browser_client.dart';

enum RequestBodyEncoding { JSON, FormURLEncoded, PlainText }

enum HttpMethod { GET, PUT, PATCH, POST, DELETE, HEAD }

class Requests {
  const Requests();
  static final Event onError = Event();
  static const int defaultTimeoutSeconds = 10;
  static const RequestBodyEncoding defaultBodyEncoding =
      RequestBodyEncoding.FormURLEncoded;

  /// Gets the cookies of a [Response.headers] in the form of a [CookieJar].
  static CookieJar extractResponseCookies(Map<String, String> responseHeaders) {
    var result = CookieJar();
    var keys = responseHeaders.keys.map((e) => e.toLowerCase());

    if (keys.contains("set-cookie")) {
      var cookies = responseHeaders["set-cookie"]!;
      result = CookieJar.parseCookiesString(cookies);
    }
    return result;
  }

  /// Get the [CookieJar] for the given [url] hostname, or an empty
  /// [CookieJar] if the hostname is not in the cache.
  static Future<CookieJar> getStoredCookies(String url) async {
    var hostname = Common.getHostname(url);
    var hostnameHash = Common.hashStringSHA256(hostname);
    var cookies = await Storage.get('cookies-$hostnameHash');

    return cookies ?? CookieJar();
  }

  /// Associates the [url] hostname with the given [cookies] into the cache.
  static Future setStoredCookies(String url, CookieJar cookies) async {
    var hostname = Common.getHostname(url);
    var hostnameHash = Common.hashStringSHA256(hostname);
    await Storage.set('cookies-$hostnameHash', cookies);
  }

  /// Removes the [url] hostname and its associated value, if present,
  /// from the cache.
  static Future clearStoredCookies(String url) async {
    var hostname = Common.getHostname(url);
    var hostnameHash = Common.hashStringSHA256(hostname);
    await Storage.delete('cookies-$hostnameHash');
  }

  /// Add a cookie with its [name] and [value] to the [url] hostname
  /// associated [CookieJar].
  static Future addCookie(String url, String name, String value) async {
    var cookieJar = await getStoredCookies(url);
    cookieJar[name] = Cookie(name, value);
    await setStoredCookies(url, cookieJar);
  }

  @Deprecated("Do not use this method, it is not needed anymore.")
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
    );
  }

  static Future<Map<String, String>> _constructRequestHeaders(
      String url, Map<String, String>? customHeaders) async {
    var requestHeaders = <String, String>{};

    var cookies = (await getStoredCookies(url)).values;
    var cookie = cookies.map((e) => '${e.name}=${e.value}').join("; ");

    requestHeaders['cookie'] = cookie;

    if (customHeaders != null) {
      requestHeaders.addAll(customHeaders);
    }

    return requestHeaders;
  }

  static Future<Response> _handleHttpResponse(
      String url, Response response, bool persistCookies) async {
    if (persistCookies) {
      var responseCookies = extractResponseCookies(response.headers);
      if (responseCookies.isNotEmpty) {
        var storedCookies = await getStoredCookies(url);
        storedCookies.addAll(responseCookies);
        await setStoredCookies(url, storedCookies);
      }
    }

    if (response.hasError) {
      var errorEvent = {'response': response};
      onError.publish(errorEvent);
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
    Map<String, String>? headers,
    int timeoutSeconds = defaultTimeoutSeconds,
    bool persistCookies = true,
    bool verify = true,
    bool withCredentials = false,
  }) async {
    Client client;

    if (!verify || withCredentials) {
      client = createClient(
        verify: verify,
        withCredentials: withCredentials,
      );
    } else {
      // The default client validates SSL certificates and fail if invalid
      client = Client();
    }

    var uri = Uri.parse(url);

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ArgumentError(
          "invalid url, must start with 'http://' or 'https://' scheme (e.g. 'http://example.com')");
    }

    headers = await _constructRequestHeaders(url, headers);
    String? requestBody;

    if (body != null && json != null) {
      throw ArgumentError('cannot use both "json" and "body" choose only one.');
    }

    if (queryParameters != null) {
      var stringQueryParameters = <String, dynamic>{};

      queryParameters.forEach((key, value) => stringQueryParameters[key] =
          value is List
              ? (value.map((e) => e?.toString()))
              : value?.toString());

      uri = uri.replace(queryParameters: stringQueryParameters);
    }

    if (port != null) {
      uri = uri.replace(port: port);
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
      }

      if (!Common.hasKeyIgnoreCase(headers, 'content-type')) {
        headers['content-type'] = contentTypeHeader;
      }
    }

    late Future future;

    switch (method) {
      case HttpMethod.GET:
        future = client.get(uri, headers: headers);
        break;
      case HttpMethod.PUT:
        future = client.put(uri, body: requestBody, headers: headers);
        break;
      case HttpMethod.DELETE:
        final request = Request('DELETE', uri);
        request.headers.addAll(headers);

        if (requestBody != null) {
          request.body = requestBody;
        }

        future = client.send(request);
        break;
      case HttpMethod.POST:
        future = client.post(uri, body: requestBody, headers: headers);
        break;
      case HttpMethod.HEAD:
        future = client.head(uri, headers: headers);
        break;
      case HttpMethod.PATCH:
        future = client.patch(uri, body: requestBody, headers: headers);
        break;
    }

    var response = await future.timeout(Duration(seconds: timeoutSeconds));

    if (response is StreamedResponse) {
      response = await Response.fromStream(response);
    }

    return await _handleHttpResponse(url, response, persistCookies);
  }
}
