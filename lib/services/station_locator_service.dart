import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_transit/models/station_search_result.dart';
import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/data/mock_data/mock_data.dart';

final stationLocatorServiceProvider = Provider<StationLocatorService>((ref) {
  return StationLocatorService();
});

class StationLocatorService {
  /// Finds the nearest station within a given radius (default 5km).
  ///
  /// [target] - The user's target destination coordinates
  /// [allowedTypes] - List of transit types to consider (Metro, Monorail, etc.)
  /// [radiusKm] - Maximum distance in Kilometers
  Future<StationSearchResult> findNearestStation({
    required LatLng target,
    required List<TransitType> allowedTypes,
    double radiusKm = 5.0,
  }) async {
    // Use compute (Isolate) to avoid blocking UI thread during calculation
    return await compute(
      _findNearestStationIsolate,
      _StationSearchRequest(
        target: target,
        allStations: allStations, // Passing static data, might be large
        allowedTypes: allowedTypes,
        radiusKm: radiusKm,
      ),
    );
  }
}

/// Helper class to transfer data to Isolate
class _StationSearchRequest {
  final LatLng target;
  final List<StationModel> allStations;
  final List<TransitType> allowedTypes;
  final double radiusKm;

  _StationSearchRequest({
    required this.target,
    required this.allStations,
    required this.allowedTypes,
    required this.radiusKm,
  });
}

/// Top-level function for isolate
StationSearchResult _findNearestStationIsolate(_StationSearchRequest request) {
  StationModel? bestWithinRadius;
  StationModel? absoluteNearest;
  double minDistanceMeters = double.infinity;
  final radiusMeters = request.radiusKm * 1000;

  // 1. Filter by allowed types
  final candidates = request.allStations.where((station) {
    return request.allowedTypes.contains(station.type);
  });

  // 2. Spatial Calculation
  for (final station in candidates) {
    final distance = Geolocator.distanceBetween(
      request.target.latitude,
      request.target.longitude,
      station.latitude,
      station.longitude,
    );

    // Update absolute nearest (regardless of radius)
    if (distance < minDistanceMeters) {
      minDistanceMeters = distance;
      absoluteNearest = station;
    }

    // Check if within radius
    // We want the closest one within radius, effectively the same as absoluteNearest if minDistance < radius
  }

  if (minDistanceMeters <= radiusMeters) {
    bestWithinRadius = absoluteNearest;
  }

  return StationSearchResult(
    bestWithinRadius: bestWithinRadius,
    absoluteNearest: absoluteNearest,
    distanceToNearestMeters: minDistanceMeters,
  );
}
