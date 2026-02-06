import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/data/mock_data/mock_data.dart';

class StationRepository {
  /// Finds a station by its ID.
  /// If not found, returns a dummy station with the provided ID and defaults.
  StationModel getStationById(String stationId) {
    return allStations.firstWhere(
      (s) => s.id == stationId,
      orElse: () => StationModel(
        id: stationId,
        nameAr: 'Unknown',
        nameEn: 'Unknown',
        type: TransitType
            .metro, // Default type, logic can be updated to infer from ID if possible
        latitude: 0,
        longitude: 0,
        lines: ['Metro'],
      ),
    );
  }

  /// Get station by ID, with optional fallback names if not found (useful for TicketScreen)
  StationModel getStationByIdWithFallback({
    required String stationId,
    required String fallbackNameEn,
    required String fallbackNameAr,
    required String fallbackTransportType,
  }) {
    return allStations.firstWhere(
      (s) => s.id == stationId,
      orElse: () => StationModel(
        id: stationId,
        nameAr: fallbackNameAr,
        nameEn: fallbackNameEn,
        type: _parseTransitType(fallbackTransportType),
        latitude: 0,
        longitude: 0,
        lines: [fallbackTransportType],
      ),
    );
  }

  TransitType _parseTransitType(String typeStr) {
    try {
      return TransitType.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
      );
    } catch (_) {
      return TransitType.metro;
    }
  }
}
