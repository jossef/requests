# flutter http json with cookies

a flutter library to do modern http requests with cookies(inspired by python's [requests](https://github.com/requests/requests) module).

server side cookies (via response header `SET-COOKIE`) are stored using the assistance of `shared_preferences`. Stored cookies will be send seemlessly on the next http requests you make to the same domain (simple implementation, similar to a web browser)


## Install

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  requests: ^1.0.2
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

HTTP post, body is json, result is json

```dart
dynamic body = await Requests.post("https://mydomain.com/api/v1/foo", json: true, body: {"foo":"bar"} );
```

HTTP delete

```dart
await Requests.delete("https://mydomain.com/api/v1/foo/123");
```
