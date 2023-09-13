# Changelog

## [4.8.1](https://github.com/jossef/requests/tree/4.8.1) (2023-08-18)

- Migration to Dart 3
- Update dependencies and analysis_options

## [4.8.0-alpha.0](https://github.com/jossef/requests/tree/4.8.0-alpha.0) (2022-10-14)

[Full Changelog](https://github.com/jossef/requests/compare/4.7.0...4.8.0-alpha.0)

**Closed issues:**

- Cookie values incorrectly parsed [\#85](https://github.com/jossef/requests/issues/85)

**Merged pull requests:**

- refactor: create files for each theme [\#86](https://github.com/jossef/requests/pull/86) ([sehnryr](https://github.com/sehnryr))
- feat: deprecate `getHostname` [\#78](https://github.com/jossef/requests/pull/78) ([sehnryr](https://github.com/sehnryr))

## [4.7.0](https://github.com/jossef/requests/tree/4.7.0) (2022-09-26)

[Full Changelog](https://github.com/jossef/requests/compare/4.6.0...4.7.0)

**Fixed bugs:**

- \[URGENT\] 4.6.0 breaks building mobile-only apps [\#81](https://github.com/jossef/requests/issues/81)

**Merged pull requests:**

- fix: previous breaking release [\#82](https://github.com/jossef/requests/pull/82) ([sehnryr](https://github.com/sehnryr))

## [4.6.0](https://github.com/jossef/requests/tree/4.6.0) (2022-09-26)

[Full Changelog](https://github.com/jossef/requests/compare/4.5.0...4.6.0)

**Closed issues:**

- CookieJar is not exposed [\#79](https://github.com/jossef/requests/issues/79)

**Merged pull requests:**

- feat: add `withCredentials` parameter [\#80](https://github.com/jossef/requests/pull/80) ([sehnryr](https://github.com/sehnryr))

## [4.5.0](https://github.com/jossef/requests/tree/4.5.0) (2022-09-02)

[Full Changelog](https://github.com/jossef/requests/compare/4.4.1...4.5.0)

## [4.4.1](https://github.com/jossef/requests/tree/4.4.1) (2022-06-16)

[Full Changelog](https://github.com/jossef/requests/compare/4.4.0...4.4.1)

**Fixed bugs:**

- Flutter Web not working \(HttpClient not found\) [\#71](https://github.com/jossef/requests/issues/71)

**Merged pull requests:**

- revert buggy web support [\#73](https://github.com/jossef/requests/pull/73) ([MarcoDiGioia](https://github.com/MarcoDiGioia))

## [4.4.0](https://github.com/jossef/requests/tree/4.4.0) (2022-06-16)

[Full Changelog](https://github.com/jossef/requests/compare/4.3.0...4.4.0)

**Implemented enhancements:**

- create function to manually add cookies [\#76](https://github.com/jossef/requests/issues/76)
- add flutter web support  [\#31](https://github.com/jossef/requests/issues/31)

**Closed issues:**

- cookies not found within the same hostname [\#75](https://github.com/jossef/requests/issues/75)
- setstoredcookies using cookiejar [\#74](https://github.com/jossef/requests/issues/74)

**Merged pull requests:**

- feat: add `addCookie` method [\#77](https://github.com/jossef/requests/pull/77) ([sehnryr](https://github.com/sehnryr))

## [4.3.0](https://github.com/jossef/requests/tree/4.3.0) (2022-05-11)

[Full Changelog](https://github.com/jossef/requests/compare/4.2.1...4.3.0)

**Fixed bugs:**

- cookies secure has sticked to next key [\#44](https://github.com/jossef/requests/issues/44)

**Merged pull requests:**

- feat: separate `Response` & support web [\#70](https://github.com/jossef/requests/pull/70) ([sehnryr](https://github.com/sehnryr))
- feat: better support for cookies [\#69](https://github.com/jossef/requests/pull/69) ([sehnryr](https://github.com/sehnryr))
- feat: replace `stash_hive` with `quiver.cache` [\#68](https://github.com/jossef/requests/pull/68) ([sehnryr](https://github.com/sehnryr))

## [4.2.1](https://github.com/jossef/requests/tree/4.2.1) (2022-05-10)

[Full Changelog](https://github.com/jossef/requests/compare/4.2.0...4.2.1)

**Fixed bugs:**

- cannot retrieve multiple 'set-cookies' [\#64](https://github.com/jossef/requests/issues/64)

**Closed issues:**

- replace shared\_preferences with something suitable for sensitive data [\#1](https://github.com/jossef/requests/issues/1)

**Merged pull requests:**

- fix: QA workflow [\#67](https://github.com/jossef/requests/pull/67) ([sehnryr](https://github.com/sehnryr))
- refactor: remove unsuitable logger [\#66](https://github.com/jossef/requests/pull/66) ([sehnryr](https://github.com/sehnryr))

## [4.2.0](https://github.com/jossef/requests/tree/4.2.0) (2022-05-04)

[Full Changelog](https://github.com/jossef/requests/compare/4.1.0...4.2.0)

**Implemented enhancements:**

- Allow passing cipher to Hive store [\#62](https://github.com/jossef/requests/issues/62)

**Closed issues:**

- failed to install null safety version [\#59](https://github.com/jossef/requests/issues/59)
- Dependencies updates [\#52](https://github.com/jossef/requests/issues/52)
- How to make login validation on Website using this plugin? [\#42](https://github.com/jossef/requests/issues/42)
- Drop flutter dependency ? [\#37](https://github.com/jossef/requests/issues/37)

**Merged pull requests:**

- fix & refactor: allow defining a custom cookie vault [\#65](https://github.com/jossef/requests/pull/65) ([sehnryr](https://github.com/sehnryr))
- feat: adding code of conduct [\#61](https://github.com/jossef/requests/pull/61) ([sehnryr](https://github.com/sehnryr))
- feat: adding issue templates [\#60](https://github.com/jossef/requests/pull/60) ([sehnryr](https://github.com/sehnryr))
- Updated cookie parsing algorithm [\#47](https://github.com/jossef/requests/pull/47) ([GabrielTavernini](https://github.com/GabrielTavernini))

## [4.1.0](https://github.com/jossef/requests/tree/4.1.0) (2022-03-22)

[Full Changelog](https://github.com/jossef/requests/compare/4.0.0-nullsafety.0...4.1.0)

**Merged pull requests:**

- Migrate shared\_preferences to stash\_hive, dependencies upgrade and various fixes and improvements [\#58](https://github.com/jossef/requests/pull/58) ([sehnryr](https://github.com/sehnryr))

## [4.0.0-nullsafety.0](https://github.com/jossef/requests/tree/4.0.0-nullsafety.0) (2022-03-14)

[Full Changelog](https://github.com/jossef/requests/compare/3.3.0...4.0.0-nullsafety.0)

**Closed issues:**

- Unable to catch TimeoutException when using flutter retry package [\#49](https://github.com/jossef/requests/issues/49)
- 422 error doesn't throw exception [\#45](https://github.com/jossef/requests/issues/45)
- Bug since i update requests 3.1.0 to 3.3.0 [\#41](https://github.com/jossef/requests/issues/41)
- Is this lib has a support of  remember\_me token system ? [\#39](https://github.com/jossef/requests/issues/39)
- no longer handling list of strings as a single queryParam [\#38](https://github.com/jossef/requests/issues/38)

**Merged pull requests:**

- Migrate to null-safety [\#56](https://github.com/jossef/requests/pull/56) ([ianmaciel](https://github.com/ianmaciel))
- Dependancies updates and various fixes [\#53](https://github.com/jossef/requests/pull/53) ([tlkops](https://github.com/tlkops))
- Update shared\_preferences requirement to 0.5.11, which supports Windows [\#46](https://github.com/jossef/requests/pull/46) ([LeHoangLong](https://github.com/LeHoangLong))
- Issue \#38 Fixed. Now array type queryParams are supported. [\#43](https://github.com/jossef/requests/pull/43) ([baskar007](https://github.com/baskar007))

## [3.3.0](https://github.com/jossef/requests/tree/3.3.0) (2020-05-30)

[Full Changelog](https://github.com/jossef/requests/compare/3.2.0...3.3.0)

**Merged pull requests:**

- add json data to GET request body [\#36](https://github.com/jossef/requests/pull/36) ([obuhovsergai](https://github.com/obuhovsergai))

## [3.2.0](https://github.com/jossef/requests/tree/3.2.0) (2020-05-23)

[Full Changelog](https://github.com/jossef/requests/compare/3.1.0...3.2.0)

**Implemented enhancements:**

- query params typing [\#27](https://github.com/jossef/requests/issues/27)

**Fixed bugs:**

- \_extractCookies when cookie has an equal sign [\#26](https://github.com/jossef/requests/issues/26)
- About \_extractResponseCookies  [\#16](https://github.com/jossef/requests/issues/16)

**Closed issues:**

- crash in getStoredCookies, calling fromJson with null [\#34](https://github.com/jossef/requests/issues/34)
- please make the response headers more easily accessible [\#30](https://github.com/jossef/requests/issues/30)
- Send a List in a POST request [\#28](https://github.com/jossef/requests/issues/28)

**Merged pull requests:**

- Added the new properties "headers" and "contentType" to "Response"-Object. [\#35](https://github.com/jossef/requests/pull/35) ([imdatsolak](https://github.com/imdatsolak))
- Use single quotes instead of double quotes wherever appropriate [\#33](https://github.com/jossef/requests/pull/33) ([anirudh24seven](https://github.com/anirudh24seven))
- Updated cookie extraction to account for cookies ending in == [\#29](https://github.com/jossef/requests/pull/29) ([FilledStacks](https://github.com/FilledStacks))

## [3.1.0](https://github.com/jossef/requests/tree/3.1.0) (2020-03-11)

[Full Changelog](https://github.com/jossef/requests/compare/3.0.5...3.1.0)

**Closed issues:**

- Cookie not follow ignore set correctly [\#23](https://github.com/jossef/requests/issues/23)

**Merged pull requests:**

- Added queryParameters support and moved port to Uri. [\#25](https://github.com/jossef/requests/pull/25) ([rafaelcmm](https://github.com/rafaelcmm))
- apply ignore case for servers return lower case cookies [\#24](https://github.com/jossef/requests/pull/24) ([eggate](https://github.com/eggate))

## [3.0.5](https://github.com/jossef/requests/tree/3.0.5) (2020-02-24)

[Full Changelog](https://github.com/jossef/requests/compare/3.0.4...3.0.5)

**Merged pull requests:**

- added functionality to send delete Requests with a Request Body [\#22](https://github.com/jossef/requests/pull/22) ([frederikpietzko](https://github.com/frederikpietzko))

## [3.0.4](https://github.com/jossef/requests/tree/3.0.4) (2020-02-18)

[Full Changelog](https://github.com/jossef/requests/compare/3.0.3...3.0.4)

**Closed issues:**

- How to add body in patch request [\#19](https://github.com/jossef/requests/issues/19)
- How to add body in delete request [\#18](https://github.com/jossef/requests/issues/18)

**Merged pull requests:**

- added body parameter to PATCH request since it is supported by the dart http client [\#20](https://github.com/jossef/requests/pull/20) ([frederikpietzko](https://github.com/frederikpietzko))

## [3.0.3](https://github.com/jossef/requests/tree/3.0.3) (2019-11-09)

[Full Changelog](https://github.com/jossef/requests/compare/3.0.1...3.0.3)

**Closed issues:**

- Fix body on request, convert to json only when needed [\#14](https://github.com/jossef/requests/issues/14)
- Dart command get error [\#12](https://github.com/jossef/requests/issues/12)

**Merged pull requests:**

- Fix body on request, convert to json only when needed [\#13](https://github.com/jossef/requests/pull/13) ([juvs](https://github.com/juvs))

## [3.0.1](https://github.com/jossef/requests/tree/3.0.1) (2019-10-20)

[Full Changelog](https://github.com/jossef/requests/compare/2.0.1...3.0.1)

**Closed issues:**

- Error Object on Server Side Error [\#9](https://github.com/jossef/requests/issues/9)
- Requests on localhost with custom port won'work [\#8](https://github.com/jossef/requests/issues/8)
- SSL handshake error on self-signed cert [\#7](https://github.com/jossef/requests/issues/7)
- Please upgrade shared\_preferences version [\#5](https://github.com/jossef/requests/issues/5)

**Merged pull requests:**

- Error Object, remove unnecessary `new` keywords, format code [\#10](https://github.com/jossef/requests/pull/10) ([RickStanley](https://github.com/RickStanley))

## [2.0.1](https://github.com/jossef/requests/tree/2.0.1) (2019-05-05)

[Full Changelog](https://github.com/jossef/requests/compare/1.0.2...2.0.1)

**Implemented enhancements:**

- support "application/x-www-form-urlencoded" [\#4](https://github.com/jossef/requests/issues/4)

**Merged pull requests:**

- Added bodyEncoding support, multiple cookies in one Set-cookie support [\#6](https://github.com/jossef/requests/pull/6) ([genesiscz](https://github.com/genesiscz))

## [1.0.2](https://github.com/jossef/requests/tree/1.0.2) (2019-02-17)

[Full Changelog](https://github.com/jossef/requests/compare/2cc0a8b110af79ac0139c3fe058f7f867a746d4f...1.0.2)

**Closed issues:**

- peristsCookies parameter not passed from methods to \_httpRequest [\#3](https://github.com/jossef/requests/issues/3)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
