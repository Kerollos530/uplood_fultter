import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as native;
import 'package:smart_transit/services/geocoding_cache_service.dart';
import 'package:dio/dio.dart';

// Provider that returns the active repository implementation.
// In a real app, this could switch based on flags or configuration.
final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  final cacheService = ref.watch(geocodingCacheServiceProvider);
  return NativeGeocodingRepository(cache: cacheService);
});

abstract class GeocodingRepository {
  Future<LatLng?> getCoordinates(String query, {String? locale});
}

class NativeGeocodingRepository implements GeocodingRepository {
  final GeocodingCacheService _cache;

  NativeGeocodingRepository({required GeocodingCacheService cache})
    : _cache = cache;

  @override
  Future<LatLng?> getCoordinates(String query, {String? locale}) async {
    // 1. Check Cache (Cache key should probably include locale if strictly necessary, but usually query is enough if unique)
    // For now, let's keep simple query key, assuming query text differs by language usually.
    final cached = _cache.get(query);
    if (cached != null) {
      debugPrint('Geocoding Cache Hit for: "\$query"');
      return cached;
    }

    debugPrint(
      'Geocoding Cache Miss for: "\$query" (locale: \$locale). Calling API...',
    );

    // 2. Call Native Implementation
    try {
      if (locale != null) {
        await native.setLocaleIdentifier(locale);
      }
      List<native.Location> locations = await native.locationFromAddress(query);

      debugPrint(
        '[NativeGeocoder] Found ${locations.length} results for "$query" (locale: $locale)',
      );
      for (var i = 0; i < locations.length; i++) {
        final loc = locations[i];
        debugPrint(
          '  Result $i: Lat=${loc.latitude}, Lng=${loc.longitude}, Timestamp=${loc.timestamp}',
        );
      }

      if (locations.isNotEmpty) {
        final loc = locations.first;
        final result = LatLng(loc.latitude, loc.longitude);

        // 3. Update Cache
        _cache.put(query, result);
        debugPrint('Geocoding Success: $result');
        return result;
      } else {
        debugPrint('Geocoding returned empty list for "$query"');
      }
    } catch (e) {
      debugPrint('Native Geocoding Error for "$query": $e');
    }

    // 3. Fallback to Nominatim (OSM)
    // If native failed or returned no results, try Nominatim.
    // This is crucial for Web/Windows where native plugins might be limited.
    debugPrint(
      '[Geocoding] Native failed or empty. Trying Nominatim fallback...',
    );
    try {
      final nominatimResult = await _fetchFromNominatim(query, locale: locale);
      if (nominatimResult != null) {
        _cache.put(query, nominatimResult);
        debugPrint('[Geocoding] Nominatim Success: $nominatimResult');
        return nominatimResult;
      }
    } catch (e) {
      debugPrint('[Geocoding] Nominatim Error: $e');
    }

    return null;
  }

  Future<LatLng?> _fetchFromNominatim(String query, {String? locale}) async {
    try {
      // Nominatim API: https://nominatim.org/release-docs/develop/api/Search/
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 1,
          'addressdetails': 1,
          if (locale != null) 'accept-language': locale,
        },
        // IMPORTANT: improved user agent as per Nominatim usage policy
        options: Options(headers: {'User-Agent': 'SmartTransitApp/1.0'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        if (data.isNotEmpty) {
          final item = data.first;
          final lat = double.tryParse(item['lat'].toString());
          final lon = double.tryParse(item['lon'].toString());

          if (lat != null && lon != null) {
            debugPrint('[Nominatim] Found: ${item['display_name']}');
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      debugPrint('[Nominatim] Request Failed: $e');
    }
    return null;
  }
}

// TODO: Implement GooglePlacesGeocodingRepository
// class GooglePlacesGeocodingRepository implements GeocodingRepository { ... }
