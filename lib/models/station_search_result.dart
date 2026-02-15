import 'package:smart_transit/models/station_model.dart';

class StationSearchResult {
  /// The best station found within the requested radius.
  /// Null if no station is within range.
  final StationModel? bestWithinRadius;

  /// The absolute nearest station found, regardless of distance.
  /// Useful for fallback UI ("No station near you, but X is 12km away").
  final StationModel? absoluteNearest;

  /// Distance in meters to the [absoluteNearest] station.
  final double distanceToNearestMeters;

  StationSearchResult({
    this.bestWithinRadius,
    this.absoluteNearest,
    required this.distanceToNearestMeters,
  });

  bool get hasValidStation => bestWithinRadius != null;
}
