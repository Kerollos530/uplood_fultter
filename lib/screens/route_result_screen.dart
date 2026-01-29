import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/state/app_state.dart';
import 'package:smart_transit/state/settings_provider.dart';

// import 'package:smart_transit/widgets/station_label.dart';

import 'package:smart_transit/l10n/gen/app_localizations.dart';

class RouteResultScreen extends ConsumerWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeResultProvider);
    final isArabic = ref.watch(isArabicProvider);
    final l10n = AppLocalizations.of(context)!;

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
                    isFirst: false,
                    stationName: lastSeg.to.getLocalizedName(isArabic),
                    time: "Now + ${route.totalDurationMinutes}", // Mock time
                    lineColor: Colors.transparent, // No line after last node
                    transportType: "ARRIVE",
                    lineName: null,
                  );
                }

                final seg = route.segments[index];
                final isFirst = index == 0;
                // If this is NOT the first segment, it's a transfer from the previous one
                final isTransfer = !isFirst;

                return _buildTimelineNode(
                  isLast: false,
                  isFirst: isFirst,
                  isTransfer: isTransfer,
                  stationName: seg.from.getLocalizedName(isArabic),
                  time: "10:${index}0 ${isArabic ? 'ص' : 'AM'}", // Mock time
                  lineColor: _getColor(seg.mode),
                  details: seg.mode == TransitType.metro
                      ? "${isArabic ? 'الخط' : 'Line'} ${seg.from.lines.first}"
                      : seg.mode.name.toUpperCase(),
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
                child: Text(
                  l10n.buyTicket, // "شراء التذكره لهذا المسار"
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
    required bool isFirst,
    bool isTransfer = false,
    required String stationName,
    required String time,
    required Color lineColor,
    String? details,
    String? transportType,
    String? lineName,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          SizedBox(
            width: 65,
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          // Line & Dot
          Column(
            children: [
              // If it's a transfer, show a special icon above the dot?
              // Or the dot itself is the transfer point.
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isLast
                      ? Colors.red
                      : (isTransfer ? Colors.orange : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLast
                        ? Colors.red
                        : (isTransfer ? Colors.orange : lineColor),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isLast
                          ? Colors.white
                          : (isTransfer ? Colors.white : lineColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 3, color: lineColor.withAlpha(100)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transfer Label
                if (isTransfer)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.swap_calls, size: 12, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          "Change Line", // Could use l10n here if passed
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  stationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (details != null && !isLast)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          _getTransportIcon(transportType),
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          details,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransportIcon(String? type) {
    if (type == 'METRO') return Icons.subway;
    if (type == 'BUS' || type == 'BRT') return Icons.directions_bus;
    return Icons.train;
  }

  Color _getColor(TransitType type) {
    switch (type) {
      case TransitType.metro:
        return const Color(0xFFE30613); // Metro Red
      case TransitType.lrt:
        return const Color(0xFF009CA6); // LRT Teal
      case TransitType.monorail:
        return const Color(0xFF707372); // Monorail Grey
      case TransitType.brt:
        return const Color(0xFFF37021); // BRT Orange
    }
  }
}
