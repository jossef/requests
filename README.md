# flutter http json with cookies

a flutter library that helps with http requests and stored cookies (inspired by python's [requests](https://github.com/psf/requests) module).

server side cookies (via response header `SET-COOKIE`) are stored using the assistance of `shared_preferences`. Stored cookies will be send seamlessly on the next http requests you make to the same domain (simple implementation, similar to a web browser)


## Install

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  requests: ^3.0.1
```

## Usage

in your Dart code, you can use:

```dart
import 'package:requests/requests.dart';
```


HTTP get, body as plain text

```dart
String body = await Requests.get("https://mydomain.com");
```

HTTP get, body as parsed json

```dart
dynamic body = await Requests.get("https://mydomain.com/api/v1/foo", json: true);
```

HTTP post, body is map or a list (being sent as application/x-www-form-urlencoded, until stated otherwise in `bodyEncoding` parameter), result is json

```dart
dynamic body = await Requests.post("https://mydomain.com/api/v1/foo", json: true, body: {"foo":"bar"} );
```

HTTP delete

```dart
await Requests.delete("https://mydomain.com/api/v1/foo/123");
```
