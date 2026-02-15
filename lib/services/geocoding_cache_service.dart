import 'dart:collection';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final geocodingCacheServiceProvider = Provider<GeocodingCacheService>((ref) {
  return GeocodingCacheService();
});

class CachedLocation {
  final LatLng coordinates;
  final DateTime timestamp;

  CachedLocation(this.coordinates, this.timestamp);
}

class GeocodingCacheService {
  static const int _maxSize = 50;
  static const Duration _ttl = Duration(minutes: 30);

  // LinkedHashMap maintains insertion order, allowing us to implement LRU
  final LinkedHashMap<String, CachedLocation> _cache = LinkedHashMap();

  /// Returns cached coordinates if they exist and are not expired.
  LatLng? get(String query) {
    final key = _normalize(query);
    final cached = _cache[key];

    if (cached == null) return null;

    // Check TTL
    if (DateTime.now().difference(cached.timestamp) > _ttl) {
      _cache.remove(key);
      return null;
    }

    // Refresh position in LRU (move to end)
    _cache.remove(key);
    _cache[key] = cached;

    return cached.coordinates;
  }

  /// Caches a new result.
  void put(String query, LatLng coordinates) {
    final key = _normalize(query);

    // Remove if exists to update position
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    }
    // Evict oldest if full
    else if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = CachedLocation(coordinates, DateTime.now());
  }

  String _normalize(String query) {
    return query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
