import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/state/app_state.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';
import 'package:smart_transit/widgets/station_label.dart'; // Reusable widget
import 'package:smart_transit/data/mock_data/mock_data.dart'; // For details
import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.history), centerTitle: true),
      body: history.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final ticket = history[index];
                return _buildTripCard(context, ticket);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_subway_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTripsFound,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startJourney,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/planner'),
            icon: const Icon(Icons.add),
            label: Text(l10n.planTrip),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TicketModel ticket) {
    // Basic date formatting
    final dateStr =
        "${ticket.timestamp.year}-${ticket.timestamp.month.toString().padLeft(2, '0')}-${ticket.timestamp.day.toString().padLeft(2, '0')} ${ticket.timestamp.hour.toString().padLeft(2, '0')}:${ticket.timestamp.minute.toString().padLeft(2, '0')}";

    // Lookup station details if possible
    final sourceStation = allStations.firstWhere(
      (s) => s.id == ticket.sourceStationId,
      orElse: () => StationModel(
        id: ticket.sourceStationId,
        nameAr: ticket.sourceNameEn,
        nameEn: ticket.sourceNameEn,
        type: TransitType.metro,
        latitude: 0,
        longitude: 0,
        lines: [
          ticket.transportTypes.isNotEmpty
              ? ticket.transportTypes.first
              : 'Metro',
        ],
      ),
    );

    final destStation = allStations.firstWhere(
      (s) => s.id == ticket.destinationStationId,
      orElse: () => StationModel(
        id: ticket.destinationStationId,
        nameAr: ticket.destinationNameEn,
        nameEn: ticket.destinationNameEn,
        type: TransitType.metro,
        latitude: 0,
        longitude: 0,
        lines: [
          ticket.transportTypes.isNotEmpty
              ? ticket.transportTypes.last
              : 'Metro',
        ],
      ),
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/ticket', extra: ticket),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    '${ticket.price} EGP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(
                      Icons.circle_outlined,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StationLabel(
                      stationName: ticket.sourceNameEn,
                      transportType: sourceStation.type.name.toUpperCase(),
                      lineName: sourceStation.lines.isNotEmpty
                          ? sourceStation.lines.first
                          : null,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 7),
                height: 16,
                width: 2,
                color: Colors.grey[300],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(Icons.location_on, size: 16, color: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StationLabel(
                      stationName: ticket.destinationNameEn,
                      transportType: destStation.type.name.toUpperCase(),
                      lineName: destStation.lines.isNotEmpty
                          ? destStation.lines.first
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
