![banner-01](https://user-images.githubusercontent.com/40632486/159684962-ae198561-16dc-4216-9f26-b223e8d01df9.png)

[![Version](https://img.shields.io/pub/v/requests?include_prereleases)](https://pub.dev/packages/requests)
[![License](https://img.shields.io/github/license/jossef/requests)](https://github.com/jossef/requests)

a dart library to make HTTP requests (inspired by python [requests](https://github.com/psf/requests) module). It comes with JSON support and a lightweight implementation to store cookies like a browser.

### Cookies, huh?
Server side cookies (via response header `SET-COOKIE`) are stored using the assistance of [`quiver.cache`](https://pub.dev/documentation/quiver/latest/quiver.cache/quiver.cache-library.html). Stored cookies will be send seamlessly on the next http requests you make to the same domain (simple implementation, similar to a web browser).


## Install

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  requests: ^4.7.0
```

## Usage
Start by importing the library
```dart
import 'package:requests/requests.dart';
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
- `headers` - `Map<String, String>` of custom client headers to add in the request
- `timeoutSeconds` - default `10` seconds. after that period of time without server response an exception is thrown
- `persistCookies` - default `true`. if should respect server's command to persist cookie
- `verify` - default `true`. if the SSL verification enabled
- `withCredentials` - default `false`. for dart web to handle cookies, authorization headers, or TLS client certificates

> 💡 Only one optional argument can be used in a single request `body` or `json`
 
 
 ### Class Methods

- `.getHostname(url)` - returns the hostname of the given url
- `.clearStoredCookies(hostname)` - clears the stored cookies for the hostname
- `.setStoredCookies(hostname, CookieJar)` - set the stored cookies for the hostname
- `.getStoredCookies(hostname)` - returns a CookieJar of the stored cookies for the hostname
- `.addCookie(hostname, name, value)` - add a Cookie to the CookieJar associated to the hostname

 
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
String hostname = Requests.getHostname(url);
await Requests.clearStoredCookies(hostname);

// Set cookies using [CookieJar.parseCookiesString]
var cookies = CookieJar.parseCookiesString("name=value");
await Requests.setStoredCookies(hostname, cookies);

// Add single cookie using [CookieJar.parseCookiesString]
var cookieJar = await Requests.getStoredCookies(hostname);
cookieJar["name"] = Cookie("name", "value");
await Requests.setStoredCookies(hostname, cookieJar);

// Add a single cookie using [Requests.addCookie]
// Same as the above one but without exposing `cookies.dart`
Requests.addCookie(hostname, "name", "value");
```

More examples can be found in [example/](./example/).

<a href="https://www.freepik.com/free-photos-vectors/business">Business vector created by freepik - www.freepik.com</a>
