## 4.1.0

- enhancement: fix typos
- fix: revert cast to FutureOr<http.StreamedResponse>
- feat: migrate shared_preferences to stash_hive
- feat: update dependencies
- feat: remove flutter dependency
- feat: remove deprecated dependencies and field in the pubspec.yaml file

## 4.0.0-nullsafety.0

- feat: migrate to null-safety

## 3.3.0

- feat: adding json, body to GET requests

## 3.2.0

- feat: dynamic type json 
- fix: incorrect parse of cookie value if has '=' in value
- fix: query parameters normalization to Map<String, String>
- fix: null checking warning on first run

## 3.1.0

- feature: added optional parameter `port` (also supporting inline url representation e.g. "http://foo.bar:1337")
- feature: added queryParameters support in get requests
- feature: created Github QA workflow to prevent pushes that breaks analyze or tests
- enhancement: changed http method strings into enum to avoid errors
- enhancement: improved type of arguments to prevent unexpected errors
- enhancement: added more validations on tests
- enhancement: executed flutter format to improve pub score
- fix: cookie matching incorrect variable + case insensitive

## 3.0.5

- fix: body in delete method 

## 3.0.4

- fix: added body in patch and delete methods 

## 3.0.3

- fix: parse json only if requested

## 3.0.1

- updated api with breaking changes

## 1.0.0

- Initial version