import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import 'package:logging/logging.dart';
import 'dart:convert';
import 'dart:core';
import 'common.dart';
import 'event.dart';
import 'dart:io';

enum RequestBodyEncoding { JSON, FormURLEncoded }

final Logger log = Logger('requests');

class Response {
  final http.Response _rawResponse;

  Response(this._rawResponse);

  get statusCode => _rawResponse.statusCode;

  get hasError => (400 <= statusCode) && (statusCode < 600);

  get success => !hasError;

  get url => _rawResponse.request.url;

  throwForStatus() {
    if (!success) {
      throw HTTPException(
          "Invalid HTTP status code $statusCode for url ${url}", this);
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
  static const String HTTP_METHOD_GET = "get";
  static const String HTTP_METHOD_PUT = "put";
  static const String HTTP_METHOD_PATCH = "patch";
  static const String HTTP_METHOD_DELETE = "delete";
  static const String HTTP_METHOD_POST = "post";
  static const String HTTP_METHOD_HEAD = "head";
  static const int DEFAULT_TIMEOUT_SECONDS = 10;

  static const RequestBodyEncoding DEFAULT_BODY_ENCODING =
      RequestBodyEncoding.FormURLEncoded;

  static Set _cookiesKeysToIgnore = Set.from([
    "SameSite",
    "Path",
    "Domain",
    "Max-Age",
    "Expires",
    "Secure",
    "HttpOnly"
  ]);

  static Map<String, String> _extractResponseCookies(responseHeaders) {
    Map<String, String> cookies = {};
    for (var key in responseHeaders.keys) {
      if (Common.equalsIgnoreCase(key, 'set-cookie')) {
        String cookie = responseHeaders[key];
        cookie.split(",").forEach((String one) {
          cookie
              .split(";")
              .map((x) => x.trim().split("="))
              .where((x) => x.length == 2)
              .where((x) => !_cookiesKeysToIgnore.contains(x[0]))
              .forEach((x) => cookies[x[0]] = x[1]);
        });
        break;
      }
    }

    return cookies;
  }

  static Future<Map> _constructRequestHeaders(
      String hostname, Map<String, String> customHeaders) async {
    var cookies = await getStoredCookies(hostname);
    String cookie =
        cookies.keys.map((key) => "$key=${cookies[key]}").join("; ");
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
      return Map<String, String>.from(cookies);
    } catch (e) {
      log.shout(
          "problem reading stored cookies. fallback with empty cookies $e");
      return Map<String, String>();
    }
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
    return "${uri.host}:${uri.port}";
  }

  static Future<Response> _handleHttpResponse(
      String hostname, http.Response rawResponse, bool persistCookies) async {
    if (persistCookies) {
      var responseCookies = _extractResponseCookies(rawResponse.headers);
      if (responseCookies.isNotEmpty) {
        var storedCookies = await getStoredCookies(hostname);
        storedCookies.addAll(responseCookies);
        await setStoredCookies(hostname, storedCookies);
      }
    }
    var response = Response(rawResponse);

    if (response.hasError) {
      var errorEvent = {"response": response};
      onError.publish(errorEvent);
    }

    return response;
  }

  static Future<Response> head(String url,
      {headers,
      bodyEncoding = DEFAULT_BODY_ENCODING,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      persistCookies = true,
      verify = true}) {
    return _httpRequest(HTTP_METHOD_HEAD, url,
        bodyEncoding: bodyEncoding,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> get(String url,
      {headers,
      bodyEncoding = DEFAULT_BODY_ENCODING,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      persistCookies = true,
      verify = true}) {
    return _httpRequest(HTTP_METHOD_GET, url,
        bodyEncoding: bodyEncoding,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> patch(String url,
      {headers,
      bodyEncoding = DEFAULT_BODY_ENCODING,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      persistCookies = true,
      verify = true}) {
    return _httpRequest(HTTP_METHOD_PATCH, url,
        bodyEncoding: bodyEncoding,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> delete(String url,
      {headers,
      bodyEncoding = DEFAULT_BODY_ENCODING,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      persistCookies = true,
      verify = true}) {
    return _httpRequest(HTTP_METHOD_DELETE, url,
        bodyEncoding: bodyEncoding,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> post(String url,
      {json,
      body,
      bodyEncoding = DEFAULT_BODY_ENCODING,
      headers,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      persistCookies = true,
      verify = true}) {
    return _httpRequest(HTTP_METHOD_POST, url,
        bodyEncoding: bodyEncoding,
        json: json,
        body: body,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> put(String url,
      {json,
      body,
      bodyEncoding = DEFAULT_BODY_ENCODING,
      headers,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      persistCookies = true,
      verify = true}) {
    return _httpRequest(HTTP_METHOD_PUT, url,
        bodyEncoding: bodyEncoding,
        json: json,
        body: body,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        persistCookies: persistCookies,
        verify: verify);
  }

  static Future<Response> _httpRequest(String method, String url,
      {json,
      body,
      bodyEncoding = DEFAULT_BODY_ENCODING,
      headers,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      persistCookies = true,
      verify = true}) async {
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
    String bodyString = "";

    if (body != null && json != null) {
      throw ArgumentError('cannot use both "json" and "body" choose only one.');
    }

    if (json != null) {
      body = json;
      bodyEncoding = RequestBodyEncoding.JSON;
    }

    if (body != null) {
      String contentTypeHeader;
      bodyString = body;
      if (body is String) {
        contentTypeHeader = "text/plain";
      } else if (body is Map || body is List) {
        if (bodyEncoding == RequestBodyEncoding.JSON) {
          bodyString = Common.toJson(body);
          contentTypeHeader = "application/json";
        } else if (bodyEncoding == RequestBodyEncoding.FormURLEncoded) {
          contentTypeHeader = "application/x-www-form-urlencoded";
        } else {
          throw Exception('unsupported bodyEncoding "$bodyEncoding"');
        }
      }

      if (contentTypeHeader != null &&
          !Common.hasKeyIgnoreCase(headers, "content-type")) {
        headers["content-type"] = contentTypeHeader;
      }
    }

    method = method.toLowerCase();
    Future future;
    switch (method) {
      case HTTP_METHOD_GET:
        future = client.get(uri, headers: headers);
        break;
      case HTTP_METHOD_PUT:
        future = client.put(uri, body: bodyString, headers: headers);
        break;
      case HTTP_METHOD_DELETE:
        future = client.delete(uri, headers: headers);
        break;
      case HTTP_METHOD_POST:
        future = client.post(uri, body: bodyString, headers: headers);
        break;
      case HTTP_METHOD_HEAD:
        future = client.head(uri, headers: headers);
        break;
      case HTTP_METHOD_PATCH:
        future = client.patch(uri, body: bodyString, headers: headers);
        break;
      default:
        throw Exception('unsupported http method "$method"');
    }

    var response = await future.timeout(Duration(seconds: timeoutSeconds));
    return await _handleHttpResponse(hostname, response, persistCookies);
  }
}
