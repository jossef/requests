## 1.0.0

- Initial version

## 3.0.1

- updated api with breaking changes

## 3.0.3

- fix: parse json only if requested

## 3.0.5

- fix: added body in patch and delete methods 

## 3.1.0

- BREAKING CHANGE: removed port from url. Added parameter port according to `Uri` best practices.
- feature: added queryParameter support in get requests
- feature: created Github QA workflow to prevent pushes that breaks analyze or tests
- enhancement: changed http method strings into enum to avoid errors
- enhancement: improved type of arguments to prevent unexpected errors
- enhancement: added more validations on tests
- enhancement: executed flutter format to improve pub score
- enhancement: changed some anti patterns.
