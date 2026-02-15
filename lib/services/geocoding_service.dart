import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/data/repositories/geocoding_repository.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  final repository = ref.watch(geocodingRepositoryProvider);
  return GeocodingService(repository);
});

class GeocodingService {
  final GeocodingRepository _repository;

  GeocodingService(this._repository);

  Future<LatLng?> getCoordinatesFromAddress(
    String address, {
    String? locale,
  }) async {
    return await _repository.getCoordinates(address, locale: locale);
  }
}
