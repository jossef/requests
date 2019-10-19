import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'dart:convert';
import 'dart:core';
import 'common.dart';
import 'event.dart';

enum RequestBodyEncoding { JSON, FormURLEncoded }

final Logger log = Logger('requests');

class Response {
  final dynamic _data;
  final int _code;
  final bool _ok;
  Response(this._data, this._code, this._ok);
  get data => _data;
  get ok => _ok;
  get code => _code;
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
    return uri.host;
  }

  static Future<dynamic> _handleHttpResponse(
      String url,
      String hostname,
      http.Response response,
      bool json,
      bool persistCookies,
      shouldThrow,
      dataOnly) async {
    int statusCode = response.statusCode;
    bool hasClientOrServerError = (400 <= statusCode) && (statusCode < 600);
    dynamic responseContent = "";
    dynamic parseException;

    try {
      responseContent = utf8.decode(response.bodyBytes, allowMalformed: true);
    } catch (e) {
      parseException = e;
    }

    if (json) responseContent = Common.fromJson(responseContent);

    if (hasClientOrServerError && shouldThrow) {
      var errorEvent = {
        "statusCode": statusCode,
        "url": url,
        "response": responseContent
      };
      onError.publish(errorEvent);
      throw Response(responseContent, statusCode, !hasClientOrServerError);
    }

    if (parseException != null) {
      throw parseException;
    }

    if (persistCookies) {
      var responseCookies = _extractResponseCookies(response.headers);
      if (responseCookies.isNotEmpty) {
        var storedCookies = await getStoredCookies(hostname);
        storedCookies.addAll(responseCookies);
        await setStoredCookies(hostname, storedCookies);
      }
    }

    return dataOnly
        ? responseContent
        : Response(responseContent, statusCode, hasClientOrServerError);
  }

  static Future<dynamic> head(String url,
      {headers,
      bodyEncoding,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      json = false,
      persistCookies = true,
      shouldThrow = true,
      dataOnly = true}) {
    return _httpRequest(HTTP_METHOD_HEAD, url,
        bodyEncoding: bodyEncoding,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        json: json,
        persistCookies: persistCookies,
        shouldThrow: shouldThrow,
        dataOnly: dataOnly);
  }

  static Future<dynamic> get(String url,
      {headers,
      bodyEncoding,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      json = false,
      persistCookies = true,
      shouldThrow = true,
      dataOnly = true}) {
    return _httpRequest(HTTP_METHOD_GET, url,
        bodyEncoding: bodyEncoding,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        json: json,
        persistCookies: persistCookies,
        shouldThrow: shouldThrow,
        dataOnly: dataOnly);
  }

  static Future<dynamic> patch(String url,
      {headers,
      bodyEncoding,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      json = false,
      persistCookies = true,
      shouldThrow = true,
      dataOnly = true}) {
    return _httpRequest(HTTP_METHOD_PATCH, url,
        bodyEncoding: bodyEncoding,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        json: json,
        persistCookies: persistCookies,
        shouldThrow: shouldThrow,
        dataOnly: dataOnly);
  }

  static Future<dynamic> delete(String url,
      {headers,
      bodyEncoding,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      json = false,
      persistCookies = true,
      shouldThrow = true,
      dataOnly = true}) {
    return _httpRequest(HTTP_METHOD_DELETE, url,
        bodyEncoding: bodyEncoding,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        json: json,
        persistCookies: persistCookies,
        shouldThrow: shouldThrow,
        dataOnly: dataOnly);
  }

  static Future<dynamic> post(String url,
      {body,
      bodyEncoding,
      headers,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      json = false,
      persistCookies = true,
      shouldThrow = true,
      dataOnly = true}) {
    return _httpRequest(HTTP_METHOD_POST, url,
        bodyEncoding: bodyEncoding,
        body: body,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        json: json,
        persistCookies: persistCookies,
        shouldThrow: shouldThrow,
        dataOnly: dataOnly);
  }

  static Future<dynamic> put(String url,
      {body,
      bodyEncoding,
      headers,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      json = false,
      persistCookies = true,
      shouldThrow = true,
      dataOnly = true}) {
    return _httpRequest(HTTP_METHOD_PUT, url,
        bodyEncoding: bodyEncoding,
        body: body,
        headers: headers,
        timeoutSeconds: timeoutSeconds,
        json: json,
        persistCookies: persistCookies,
        shouldThrow: shouldThrow,
        dataOnly: dataOnly);
  }

  static Future<dynamic> _httpRequest(String method, String url,
      {body,
      bodyEncoding = RequestBodyEncoding.FormURLEncoded,
      headers,
      timeoutSeconds = DEFAULT_TIMEOUT_SECONDS,
      json = false,
      persistCookies = true,
      shouldThrow = true,
      dataOnly = true}) async {
    var client = http.Client();
    var uri = Uri.parse(url);
    String hostname = uri.host;
    headers = await _constructRequestHeaders(hostname, headers);
    String bodyString = "";

    if (body != null) {
      String contentTypeHeader;
      if (body is String) {
        bodyString = body;
        contentTypeHeader = "text/plain";
      } else if (body is Map || body is List) {
        bodyString = Common.toJson(body);

        if (bodyEncoding == RequestBodyEncoding.JSON) {
          contentTypeHeader = "application/json";
        } else if (bodyEncoding == RequestBodyEncoding.FormURLEncoded) {
          contentTypeHeader = "application/x-www-form-urlencoded";
        }

        // BC Break
        // contentTypeHeader = "application/json";
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
        throw Exception('unsupported http method $method"');
    }

    var response = await future.timeout(Duration(seconds: timeoutSeconds));
    return await _handleHttpResponse(
        url, hostname, response, json, persistCookies, shouldThrow, dataOnly);
  }
}
