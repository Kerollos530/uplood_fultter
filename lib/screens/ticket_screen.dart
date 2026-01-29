import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';
import 'package:smart_transit/widgets/app_card.dart';
import 'package:smart_transit/widgets/station_label.dart'; // Import reusable widget
import 'package:smart_transit/data/mock_data/mock_data.dart'; // Import for station lookup
import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';

class TicketScreen extends StatelessWidget {
  final TicketModel? ticketArg;
  const TicketScreen({super.key, this.ticketArg});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // If ticketArg is null, we might need to get it from context.extra if GoRouter passed it.
    final TicketModel? ticket =
        ticketArg ?? GoRouterState.of(context).extra as TicketModel?;

    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.noTripsFound)),
      );
    }

    // Lookup station details from ID to get proper Line info if needed
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ticketTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Success Header
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1FAAF1),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x401FAAF1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: const Icon(Icons.check, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.successTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),

              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.ticketTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Divider(height: 32),
                    QrImageView(
                      data: ticket.qrString,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ticket.ticketId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.5,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Date & Time (Mocked for UI polish as requested)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.date,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Today, ${DateTime.now().toString().substring(0, 10)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.time,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Text(
                              '14:30 PM', // Mock time
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: StationLabel(
                            stationName: ticket.sourceNameEn,
                            transportType: sourceStation.type.name
                                .toUpperCase(),
                            lineName: sourceStation.lines.isNotEmpty
                                ? sourceStation.lines.first
                                : null,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),
                          child: Icon(Icons.arrow_forward, color: Colors.grey),
                        ),
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Download Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Mock download action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading ticket...')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: Text(l10n.downloadTicket),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FAAF1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Back To Home Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.go('/planner'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1FAAF1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    l10n.backToHome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1FAAF1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
