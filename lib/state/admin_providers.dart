import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/data/mock_data/mock_data.dart';

// --- STATIONS STATE ---

final adminLoadingProvider = StateProvider<bool>((ref) => false);
final adminErrorProvider = StateProvider<String?>((ref) => null);

class AdminStationsNotifier extends StateNotifier<List<StationModel>> {
  final Ref _ref;

  AdminStationsNotifier(this._ref)
    : super([...allStations]); // Initialize with mock data copy

  Future<void> updateStation(StationModel updatedStation) async {
    _ref.read(adminLoadingProvider.notifier).state = true;
    _ref.read(adminErrorProvider.notifier).state = null;
    await Future.delayed(const Duration(seconds: 1)); // Simulate api
    state = [
      for (final station in state)
        if (station.id == updatedStation.id) updatedStation else station,
    ];
    _ref.read(adminLoadingProvider.notifier).state = false;
  }

  Future<void> toggleStationStatus(String stationId) async {
    _ref.read(adminLoadingProvider.notifier).state = true;
    await Future.delayed(const Duration(milliseconds: 500));
    state = [
      for (final station in state)
        if (station.id == stationId)
          StationModel(
            id: station.id,
            nameAr: station.nameAr,
            nameEn: station.nameEn,
            type: station.type,
            latitude: station.latitude,
            longitude: station.longitude,
            lines: station.lines,
            isActive: !station.isActive,
          )
        else
          station,
    ];
    _ref.read(adminLoadingProvider.notifier).state = false;
  }
}

final adminStationsProvider =
    StateNotifierProvider<AdminStationsNotifier, List<StationModel>>((ref) {
      return AdminStationsNotifier(ref);
    });

// --- PRICING STATE ---

class PricingModel {
  final double basePrice;
  final double pricePerZone;
  final double premiumMultiplier;

  PricingModel({
    required this.basePrice,
    required this.pricePerZone,
    required this.premiumMultiplier,
  });

  PricingModel copyWith({
    double? basePrice,
    double? pricePerZone,
    double? premiumMultiplier,
  }) {
    return PricingModel(
      basePrice: basePrice ?? this.basePrice,
      pricePerZone: pricePerZone ?? this.pricePerZone,
      premiumMultiplier: premiumMultiplier ?? this.premiumMultiplier,
    );
  }
}

class AdminPricingNotifier extends StateNotifier<PricingModel> {
  final Ref _ref;

  AdminPricingNotifier(this._ref)
    : super(
        PricingModel(basePrice: 5.0, pricePerZone: 2.0, premiumMultiplier: 1.5),
      );

  Future<void> updatePricing(PricingModel newPricing) async {
    _ref.read(adminLoadingProvider.notifier).state = true;
    _ref.read(adminErrorProvider.notifier).state = null;
    await Future.delayed(const Duration(seconds: 1)); // Simulate
    state = newPricing;
    _ref.read(adminLoadingProvider.notifier).state = false;
  }
}

final adminPricingProvider =
    StateNotifierProvider<AdminPricingNotifier, PricingModel>((ref) {
      return AdminPricingNotifier(ref);
    });
