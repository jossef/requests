![banner-01](https://raw.githubusercontent.com/onyx-lyon1/requests_plus/master/logo/social-01.png)

[![Version](https://img.shields.io/pub/v/requests_plus?include_prereleases)](https://pub.dev/packages/requests_plus)
[![License](https://img.shields.io/github/license/jossef/requests)](https://github.com/onyx-lyon1/requests_plus)

## 🚀 requests-plus

A powerful Dart library for making HTTP requests, based on the popular [requests](https://github.com/psf/requests) module from Python. This is a fork of the original "requests" project with additional features and enhancements.

### 🌟 New Features

- **Form Data Support**: Send data in the form of `multipart/form-data` using the `RequestBodyEncoding.FormData` option in the `bodyEncoding` parameter.
- **HTTP Authentification support**: Easily send HTTP authentification headers using the `userName` and `password` parameters. (Basic Authentification only)
- **CORS Proxy**: Easily bypass CORS restrictions by utilizing the [dart_cors-proxy](https://github.com/onyx-lyon1/dart_cors-proxy) proxy. Simply specify the `corsProxyUrl` parameter with the URL of the proxy.

> **Note**: This fork builds upon the functionality of the original "requests" library, adding these new features to empower your HTTP requests.

### 🍪 Cookies, huh?
Server side cookies (via response header `SET-COOKIE`) are stored using the assistance of [`quiver.cache`](https://pub.dev/documentation/quiver/latest/quiver.cache/quiver.cache-library.html). Stored cookies will be send seamlessly on the next http requests you make to the same domain (simple implementation, similar to a web browser).


## ✨ Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  requests: ^4.8.2
```

## Usage
Start by importing the library
```dart
import 'package:requests/requests_plus.dart';
```

Let's make a simple HTTP request

```dart
var r = await Requests.get('https://google.com');
r.raiseForStatus();
String body = r.content();
```

### the `Response` object
just like in python's request module, the `Response` object has this functionality

- `r.throwForStatus()` - will throw an exception if the response `statusCode` is not a great success.
- `r.raiseForStatus()` - same as `throwForStatus`
- `r.statusCode` - the response status code
- `r.url` - the url in the request 
- `r.headers` - the response headers 
- `r.success` - a boolean. `true` indicates that the request was a great success 
- `r.hasError` - a boolean. `true` indicates that the request was not a great success 
- `r.bytes()` - return the body in the response as a list of bytes 
- `r.content()` - return the body in the response as a string
- `r.json()` - recodes the body in the response and returns the result (dynamic type)


### Optional Arguments

- `json` - a `dynamic` object that will be json encoded and then be set as the request's body
- `body` - a raw string to be used as the request's body
- `bodyEncoding` - default `RequestBodyEncoding.FormURLEncoded`. will set the `content-type` header
- `headers` - `Map<String, String>` of custom client headers to add in the request (will override all default headers)
- `timeoutSeconds` - default `10` seconds. after that period of time without server response an exception is thrown
- `persistCookies` - default `true`. if should respect server's command to persist cookie
- `verify` - default `true`. if the SSL verification enabled
- `withCredentials` - default `false`. for dart web to handle cookies, authorization headers, or TLS client certificates
- `userName` - default `null`. for HTTP basic authentification
- `password` - default `null`. for HTTP basic authentification

> **Note**:
> Only one optional argument can be used in a single request `body` or `json`

### Class Methods

- `.clearStoredCookies(url)` - clears the stored cookies for the url
- `.setStoredCookies(url, CookieJar)` - set the stored cookies for the url
- `.getStoredCookies(url)` - returns a CookieJar of the stored cookies for the url
- `.addCookie(url, name, value)` - add a Cookie to the CookieJar associated to the url

 
## Examples
 
HTTP post, body encoded as application/x-www-form-urlencoded, parse response as json

```dart
var r = await Requests.post(
  'https://reqres.in/api/users',
  body: {
    'userId': 10,
    'id': 91,
    'title': 'aut amet sed',
  },
  bodyEncoding: RequestBodyEncoding.FormURLEncoded);

r.raiseForStatus();
dynamic json = r.json();
print(json!['id']);
```

---

HTTP delete

```dart
var r = await Requests.delete('https://reqres.in/api/users/10');
r.raiseForStatus();
```

---

Ignore SSL self-signed certificate

```dart
var r = await Requests.get('https://expired.badssl.com/', verify: false);
r.raiseForStatus();
``` 

---

Play with stored cookies

```dart
String url = "https://example.com";
await Requests.clearStoredCookies(url);

// Set cookies using [CookieJar.parseCookiesString]
var cookies = CookieJar.parseCookiesString("name=value");
await Requests.setStoredCookies(url, cookies);

// Add single cookie using [CookieJar.parseCookiesString]
var cookieJar = await Requests.getStoredCookies(url);
cookieJar["name"] = Cookie("name", "value");
await Requests.setStoredCookies(url, cookieJar);

// Add a single cookie using [Requests.addCookie]
// Same as the above one but without exposing `cookies.dart`
Requests.addCookie(url, "name", "value");
```

More examples can be found in [example/](./example/).

<a href="https://www.freepik.com/free-photos-vectors/business">Business vector created by freepik - www.freepik.com</a>
