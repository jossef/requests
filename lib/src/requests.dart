import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import 'package:logging/logging.dart';

import 'common.dart';
import 'event.dart';

enum RequestBodyEncoding { JSON, FormURLEncoded, PlainText }
enum HttpMethod { GET, PUT, PATCH, POST, DELETE, HEAD }

final Logger log = Logger('requests');

class Response {
  final http.Response _rawResponse;

  Response(this._rawResponse);

  int get statusCode => _rawResponse.statusCode;

  bool get hasError => (400 <= statusCode) && (statusCode < 600);

  bool get success => !hasError;

  Uri get url => _rawResponse.request.url;

  Map<String, String> get headers => _rawResponse.headers;

  String get contentType => _rawResponse.headers['content-type'];

  throwForStatus() {
    if (!success) {
      throw HTTPException(
          'Invalid HTTP status code $statusCode for url ${url}', this);
    }
  }

  raiseForStatus() {
    throwForStatus();
  }

  List<int> bytes() {
    return _rawResponse.bodyBytes;
  }

  String content() {
    return utf8.decode(bytes(), allowMalformed: true);
  }

  dynamic json() {
    return Common.fromJson(content());
  }
}

class HTTPException implements Exception {
  final String message;
  final Response response;

  HTTPException(this.message, this.response);
}

class Requests {
  const Requests();
  static final Event onError = Event();
  static const int DEFAULT_TIMEOUT_SECONDS = 10;
  static const RequestBodyEncoding DEFAULT_BODY_ENCODING = RequestBodyEncoding.FormURLEncoded;
  static Set _cookiesKeysToIgnore = Set.from([
   'samesite',
   'path',
   'domain',
   'max-age',
   'expires',
   'secure',
   'httponly'
  ]);

  static Map<String, String> extractResponseCookies(responseHeaders) {
    Map<String, String> cookies = {};
    for (var key in responseHeaders.keys) {
      if (Common.equalsIgnoreCase(key, 'set-cookie')) {
        String cookie = responseHeaders[key];
        cookie
            .split(';')
            .map((x) => Common.split(x.trim(), '=', max: 1))
            .where((x) => x.length == 2)
            .where((x) => !_cookiesKeysToIgnore.contains(x[0].toLowerCase()))
            .forEach((x) => cookies[x[0]] = x[1]);
        break;
      }
    }

    return cookies;
  }

  static Future<Map> _constructRequestHeaders(
      String hostname, Map<String, String> customHeaders) async {
    var cookies = await getStoredCookies(hostname);
    String cookie =
        cookies.keys.map((key) => '$key=${cookies[key]}').join('; ');
    Map<String, String> requestHeaders = Map();
    requestHeaders['cookie'] = cookie;
    if (customHeaders != null) {
      requestHeaders.addAll(customHeaders);
    }
    return requestHeaders;
  }

  static Future<Map<String, String>> getStoredCookies(String hostname) async {
    try {
      String hostnameHash = Common.hashStringSHA256(hostname);
      String cookiesJson = await Common.storageGet('cookies-$hostnameHash');
      var cookies = Common.fromJson(cookiesJson);
      if (cookies != null) {
        return Map.from(cookies);
      }
    } catch (e) {
      log.shout('problem reading stored cookies. fallback with empty cookies $e');
    }
    return Map<String, String>();
  }

  static Future setStoredCookies(
      String hostname, Map<String, String> cookies) async {
    String hostnameHash = Common.hashStringSHA256(hostname);
    String cookiesJson = Common.toJson(cookies);
    await Common.storageSet('cookies-$hostnameHash', cookiesJson);
  }

  static Future clearStoredCookies(String hostname) async {
    String hostnameHash = Common.hashStringSHA256(hostname);
    await Common.storageSet('cookies-$hostnameHash', null);
  }

  static String getHostname(String url) {
    var uri = Uri.parse(url);
    return '${uri.host}:${uri.port}';
  }

  static Future<Response> _handleHttpResponse(
      String hostname, http.Response rawResponse, bool persistCookies) async {
    if (persistCookies) {
      var responseCookies = extractResponseCookies(rawResponse.headers);
      if (responseCookies.isNotEmpty) {
        var storedCookies = await getStoredCookies(hostname);
        storedCookies.addAll(responseCookies);
        await setStoredCookies(hostname, storedCookies);
      }
    }
    var response = Response(rawResponse);

    if (response.hasError) {
      var errorEvent = {'response': response};
      onError.publish(errorEvent);
    }

    return response;
  }

  static Future<Response> head(String url,
      {Map<String, String> headers,
      Map<String, dynamic> queryParameters,
      int port,
      RequestBodyEncoding bodyEncoding = DEFAULT_BODY_ENCODING,
      int timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      bool persistCookies = true,
      bool verify = true}) {
    return _httpRequest(HttpMethod.HEAD, url,
        bodyEncoding: bodyEncoding,
        queryParameters: queryParameters,
        port: port,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> get(String url,
      {Map<String, String> headers,
      Map<String, dynamic> queryParameters,
      int port,
      dynamic json,
      dynamic body,
      RequestBodyEncoding bodyEncoding = DEFAULT_BODY_ENCODING,
      int timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      bool persistCookies = true,
      bool verify = true}) {
    return _httpRequest(HttpMethod.GET, url,
        bodyEncoding: bodyEncoding,
        queryParameters: queryParameters,
        port: port,
        json: json,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> patch(String url,
      {Map<String, String> headers,
      int port,
      dynamic json,
      dynamic body,
      Map<String, dynamic> queryParameters,
      RequestBodyEncoding bodyEncoding = DEFAULT_BODY_ENCODING,
      int timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      bool persistCookies = true,
      bool verify = true}) {
    return _httpRequest(HttpMethod.PATCH, url,
        bodyEncoding: bodyEncoding,
        port: port,
        json: json,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> delete(String url,
      {Map<String, String> headers,
      dynamic json,
      dynamic body,
      Map<String, dynamic> queryParameters,
      int port,
      RequestBodyEncoding bodyEncoding = DEFAULT_BODY_ENCODING,
      int timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      bool persistCookies = true,
      bool verify = true}) {
    return _httpRequest(HttpMethod.DELETE, url,
        bodyEncoding: bodyEncoding,
        port: port,
        json: json,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> post(String url,
      {dynamic json,
      int port,
      dynamic body,
      Map<String, dynamic> queryParameters,
      RequestBodyEncoding bodyEncoding = DEFAULT_BODY_ENCODING,
      Map<String, String> headers,
      int timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      bool persistCookies = true,
      bool verify = true}) {
    return _httpRequest(HttpMethod.POST, url,
        bodyEncoding: bodyEncoding,
        json: json,
        port: port,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> put(
    String url, {
    int port,
    dynamic json,
    dynamic body,
    Map<String, dynamic> queryParameters,
    RequestBodyEncoding bodyEncoding = DEFAULT_BODY_ENCODING,
    Map<String, String> headers,
    int timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
    bool persistCookies = true,
    bool verify = true,
  }) {
    return _httpRequest(
      HttpMethod.PUT,
      url,
      port: port,
      bodyEncoding: bodyEncoding,
      json: json,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      timeoutSeconds: timeoutSeconds,
      persistCookies: persistCookies,
      verify: verify,
    );
  }

  static Future<Response> _httpRequest(HttpMethod method, String url,
      {
        dynamic json,
        dynamic body,
        RequestBodyEncoding bodyEncoding = DEFAULT_BODY_ENCODING,
        Map<String, dynamic> queryParameters,
        int port,
        Map<String, String> headers,
        int timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
        bool persistCookies = true,
        bool verify = true
      }) async {
    http.Client client;
    if (!verify) {
      // Ignore SSL errors
      var ioClient = HttpClient();
      ioClient.badCertificateCallback = (_, __, ___) => true;
      client = io_client.IOClient(ioClient);
    } else {
      // The default client validates SSL certificates and fail if invalid
      client = http.Client();
    }

    var uri = Uri.parse(url);

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ArgumentError(
          "invalid url, must start with 'http://' or 'https://' sheme (e.g. 'http://example.com')");
    }

    String hostname = getHostname(url);
    headers = await _constructRequestHeaders(hostname, headers);
    String requestBody;

    if (body != null && json != null) {
      throw ArgumentError('cannot use both "json" and "body" choose only one.');
    }

    if (queryParameters != null) {
      Map<String, String> stringQueryParameters = Map();
      queryParameters.forEach((key, value) => stringQueryParameters[key] = value?.toString());
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
      String contentTypeHeader;

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

      if (contentTypeHeader != null &&
          !Common.hasKeyIgnoreCase(headers, 'content-type')) {
        headers['content-type'] = contentTypeHeader;
      }
    }

    Future future;

    switch (method) {
      case HttpMethod.GET:
        future = client.get(uri, headers: headers);
        break;
      case HttpMethod.PUT:
        future = client.put(uri, body: requestBody, headers: headers);
        break;
      case HttpMethod.DELETE:
        final request = http.Request('DELETE', uri);
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

    if (response is http.StreamedResponse) {
      response = await http.Response.fromStream(response);
    }

    return await _handleHttpResponse(hostname, response, persistCookies);
  }
}
