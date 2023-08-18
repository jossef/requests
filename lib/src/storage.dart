import 'package:quiver/cache.dart';

import 'package:requests/src/cookie_jar.dart';

class Storage {
  /// The cache containing the cookies semi-persistently.
  static MapCache<String, CookieJar> cache = MapCache();

  /// Add this key/value pair to the [cache].
  ///
  /// If a key of other is already in this [cache], its value is overwritten.
  static Future<void> set(String key, CookieJar value) async {
    await cache.set(key, value);
  }

  /// The value for the given [key], or `null` if [key] is not in the [cache].
  static Future<CookieJar?> get(String key) async {
    return cache.get(key);
  }

  /// Removes [key] and its associated value, if present, from the [cache].
  ///
  /// Returns `true` if the key/value pair was successfully removed,
  /// `false` otherwise.
  static Future<bool> delete(String key) async {
    await cache.invalidate(key);
    return await cache.get(key) == null;
  }
}
