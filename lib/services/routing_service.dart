import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/models/route_model.dart';
import 'package:smart_transit/data/mock_data/mock_data.dart';
import 'package:collection/collection.dart';

class RoutingService {
  // Dijkstra Implementation
  Future<RouteModel?> findRoute(String startId, String endId) async {
    // Simulate calc time
    await Future.delayed(const Duration(milliseconds: 500));

    if (startId == endId) return null;

    final distances = <String, double>{};
    final previous = <String, String>{};
    final queue = PriorityQueue<String>(
      (a, b) => (distances[a] ?? double.infinity).compareTo(
        distances[b] ?? double.infinity,
      ),
    );

    distances[startId] = 0;

    // Initialize
    for (var station in allStations) {
      if (station.id != startId) {
        distances[station.id] = double.infinity;
      }
    }
    queue.add(startId);

    while (queue.isNotEmpty) {
      final currentId = queue.removeFirst();

      if (currentId == endId) break;

      final currentDist = distances[currentId] ?? double.infinity;
      if (currentDist == double.infinity) break;

      final neighbors = stationConnections[currentId] ?? [];
      for (var neighbor in neighbors) {
        final alt = currentDist + neighbor.minutes;
        if (alt < (distances[neighbor.toId] ?? double.infinity)) {
          distances[neighbor.toId] = alt;
          previous[neighbor.toId] = currentId;
          // PriorityQueue doesn't support decreaseKey easily, so we just add it.
          // The old larger value will be popped later and ignored if we checked processed status, but here we just check distance logic.
          queue.add(neighbor.toId);
        }
      }
    }

    if (distances[endId] == double.infinity) {
      throw Exception('لا يوجد مسار متاح بين هاتين المحطتين');
    }

    // Reconstruct path
    final path = <String>[];
    String? current = endId;
    while (current != null) {
      path.insert(0, current);
      current = previous[current];
    }

    // Build RouteModel with Segments
    return _buildRouteFromPath(path);
  }

  RouteModel _buildRouteFromPath(List<String> pathIds) {
    List<SegmentModel> segments = [];
    double totalTime = 0;
    double totalCost = 0;

    for (int i = 0; i < pathIds.length - 1; i++) {
      String fromId = pathIds[i];
      String toId = pathIds[i + 1];

      // Find connection details
      var conns = stationConnections[fromId];
      var conn = conns?.firstWhere((c) => c.toId == toId);

      var fromStation = allStations.firstWhere((s) => s.id == fromId);
      var toStation = allStations.firstWhere((s) => s.id == toId);

      if (conn != null) {
        // Calculate cost per segment (Mock logic: 5 EGP base + 2 per min? Or simple zone logic)
        // Let's settle on: Metro=10, Lrt=20, Monorail=30, BRT=15
        // If transfer (line change), extra cost?
        // We will use a simplified cost model per hop for now effectively.
        double cost = 0;
        if (conn.type == TransitType.metro) {
          cost = 5;
        } else if (conn.type == TransitType.lrt) {
          cost = 10;
        } else if (conn.type == TransitType.monorail) {
          cost = 15;
        } else {
          cost = 5;
        }

        segments.add(
          SegmentModel(
            from: fromStation,
            to: toStation,
            durationMinutes: conn.minutes,
            mode: conn.type,
            cost: cost,
            lineName: conn.lineName,
          ),
        );
        totalTime += conn.minutes;
        totalCost += cost;
      }
    }

    // Cap cost per type?
    // Metro max 20, etc.
    // Simply sum for now as per "Mock" requirement.

    return RouteModel(
      segments: segments,
      totalCost: totalCost,
      totalDurationMinutes: totalTime,
      totalStops: segments.length,
    );
  }
}
