import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/state/app_state.dart';
import 'package:smart_transit/state/settings_provider.dart';

import 'package:smart_transit/widgets/station_label.dart';

class RouteResultScreen extends ConsumerWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeResultProvider);
    final isArabic = ref.watch(isArabicProvider);

    if (route == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Details')),
        body: const Center(child: Text("No route data")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'تفاصيل الرحلة',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Info Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.access_time,
                  '${route.totalDurationMinutes}',
                  'وقت (بالدقائق)',
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildInfoItem(
                  Icons.attach_money,
                  '${route.totalCost}',
                  'جنيه',
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount:
                  route.segments.length + 1, // +1 for the end node visuals
              itemBuilder: (context, index) {
                // Simplified Timeline View
                // For a real app, this would iterate stations.
                // Here we iterate segments and show from -> to.
                // Design shows: Start Station -> (Line) -> End Station.

                if (index == route.segments.length) {
                  // Final Destination Node
                  final lastSeg = route.segments.last;
                  return _buildTimelineNode(
                    isLast: true,
                    stationName: lastSeg.to.getLocalizedName(isArabic),
                    time: "Now + ${route.totalDurationMinutes}", // Mock time
                    lineColor: _getColor(lastSeg.mode),
                    transportType: lastSeg.mode.name.toUpperCase(),
                    lineName: lastSeg.to.lines.isNotEmpty
                        ? lastSeg.to.lines.first
                        : null,
                  );
                }

                final seg = route.segments[index];
                return _buildTimelineNode(
                  isLast: false,
                  stationName: seg.from.getLocalizedName(isArabic),
                  time: "10:00 ص", // Mock time
                  lineColor: _getColor(seg.mode),
                  details: "الخط الاول (اتجاه حلوان)", // Mock details
                  transportType: seg.mode.name.toUpperCase(),
                  lineName: seg.from.lines.isNotEmpty
                      ? seg.from.lines.first
                      : null,
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.push('/booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1FAAF1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'شراء التذكره لهذا المسار',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1FAAF1)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildTimelineNode({
    required bool isLast,
    required String stationName,
    required String time,
    required Color lineColor,
    String? details,
    String? transportType, // Add this
    String? lineName, // Add this
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Line & Dot
          Column(
            children: [
              Icon(
                isLast ? Icons.location_on : Icons.circle_outlined,
                color: lineColor,
                size: 20,
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StationLabel(
                  stationName: stationName,
                  transportType: transportType,
                  lineName: lineName,
                ),
                if (details != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    child: Text(
                      details,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                if (isLast) const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(TransitType type) {
    switch (type) {
      case TransitType.metro:
        return Colors.red;
      case TransitType.lrt:
        return Colors.green;
      case TransitType.monorail:
        return Colors.purple;
      case TransitType.brt:
        return Colors.orange;
    }
  }
}
