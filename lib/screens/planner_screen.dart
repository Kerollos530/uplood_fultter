import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/widgets/app_card.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/data/mock_data/mock_data.dart';
import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/state/app_state.dart';
import 'package:smart_transit/state/settings_provider.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:geolocator/geolocator.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  StationModel? _startStation;
  StationModel? _endStation;
  bool _isGettingLocation = false;
  final MapController _mapController = MapController();
  lat_lng.LatLng _currentCenter = const lat_lng.LatLng(
    30.0444,
    31.2357,
  ); // Cairo default
  lat_lng.LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    // Pre-populate for demo
    _startStation = allStations.firstWhere(
      (s) => s.id == 'm1_maadi',
      orElse: () => allStations.first,
    );
  }

  void _findRoute() async {
    if (_startStation == null) return;
    if (_endStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectDestination),
        ),
      );
      return;
    }

    try {
      ref.read(routeLoadingProvider.notifier).state = true;
      ref.read(routeErrorProvider.notifier).state = null;

      final route = await ref
          .read(routingServiceProvider)
          .findRoute(_startStation!.id, _endStation!.id);

      ref.read(routeResultProvider.notifier).state = route;

      if (mounted && route != null) {
        context.push('/route_result');
      }
    } catch (e) {
      ref.read(routeErrorProvider.notifier).state = e.toString().replaceAll(
        'Exception: ',
        '',
      );
    } finally {
      ref.read(routeLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    LocationPermission permission;

    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        setState(() => _isGettingLocation = false);
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() => _isGettingLocation = false);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
        setState(() => _isGettingLocation = false);
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final userLat = position.latitude;
      final userLng = position.longitude;

      // Find nearest station
      StationModel? nearest;
      double minDistance = double.infinity;

      for (final station in allStations) {
        final dist = Geolocator.distanceBetween(
          userLat,
          userLng,
          station.latitude,
          station.longitude,
        );
        if (dist < minDistance) {
          minDistance = dist;
          nearest = station;
        }
      }

      setState(() {
        _userLocation = lat_lng.LatLng(userLat, userLng);
        _currentCenter = _userLocation!;
        if (nearest != null) {
          _startStation = nearest;
        }
        _mapController.move(_currentCenter, 13.0);
        _isGettingLocation = false;
      });

      if (mounted && nearest != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location found: Nearest station is ${nearest.nameEn}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error finding location: $e')));
        setState(() => _isGettingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(isArabicProvider);
    final isLoading = ref.watch(routeLoadingProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<String?>(routeErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background Map (Placeholder Image or Container)
          // Background Map with Flutter Map
          Container(
            color: Colors.grey[300],
            width: double.infinity,
            height: double.infinity,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smart_transit',
                ),
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Header / Menu Icon
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Icon(Icons.menu),
            ),
          ),
          const Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Color(0xFF1FAAF1),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),

          // Draggable Search Panel
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.2, // Collapsed
            maxChildSize: 0.85, // Expanded
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // From Field
                        DropdownButtonFormField<StationModel>(
                          initialValue: _startStation,
                          decoration: InputDecoration(
                            labelText: l10n.from,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF2F2F2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.my_location,
                              color: Color(0xFF1FAAF1),
                            ),
                          ),
                          items: allStations
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.getLocalizedName(isArabic)),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _startStation = val),
                        ),
                        const SizedBox(height: 16),

                        // To Field
                        DropdownButtonFormField<StationModel>(
                          initialValue: _endStation,
                          decoration: InputDecoration(
                            labelText: l10n.to,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF2F2F2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                          ),
                          items: allStations
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.getLocalizedName(isArabic)),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _endStation = val),
                        ),
                        const SizedBox(height: 24),

                        // Search Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _findRoute,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1FAAF1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    l10n.searchRoute,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isGettingLocation ? null : _getCurrentLocation,
        backgroundColor: Colors.white,
        child: _isGettingLocation
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location, color: Color(0xFF1FAAF1)),
      ),
    );
  }
}
