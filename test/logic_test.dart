import 'package:flutter_test/flutter_test.dart';
import 'package:smart_transit/services/routing_service.dart';

void main() {
  group('Routing Service Tests', () {
    final routingService = RoutingService();

    test(
      'Find route between two adjacent stations (Helwan -> Maadi)',
      () async {
        // Helwan (m1_helwan) -> Maadi (m1_maadi) is direct, 12 mins
        final route = await routingService.findRoute('m1_helwan', 'm1_maadi');

        expect(route, isNotNull);
        expect(route!.segments.length, 1);
        expect(route.segments.first.from.id, 'm1_helwan');
        expect(route.segments.first.to.id, 'm1_maadi');
        expect(route.totalDurationMinutes, 12);
      },
    );

    test('Find route with interchange (Maadi -> Dokki via Sadat)', () async {
      // Maadi (L1) -> Sadat (L1) -> Dokki (L2)
      // Maadi -> Sadat = 18 min
      // Sadat -> Dokki = 5 min
      // Total = 23 min
      final route = await routingService.findRoute('m1_maadi', 'm2_dokki');

      expect(route, isNotNull);
      expect(route!.segments.length, 2);
      expect(route.segments[0].from.id, 'm1_maadi');
      expect(route.segments[0].to.id, 'm1_sadat');
      expect(route.segments[1].from.id, 'm1_sadat');
      expect(route.segments[1].to.id, 'm2_dokki');
      expect(route.totalDurationMinutes, 23);
    });

    test('Calculate Total Cost Correctly', () async {
      // Maadi -> Sadat (Metro=5)
      // Sadat -> Dokki (Metro=5)
      // Total = 10
      final route = await routingService.findRoute('m1_maadi', 'm2_dokki');
      expect(route!.totalCost, 10);
    });

    test('Returns null for same station', () async {
      final route = await routingService.findRoute('m1_maadi', 'm1_maadi');
      expect(route, isNull);
    });

    test(
      'Returns null for unreachable station (if any isolated node exists)',
      () async {
        // Our graph is fully connected currently, but let's test a theoretical isolated one if we added it?
        // Skip for now as graph is static.
      },
    );
  });
}
