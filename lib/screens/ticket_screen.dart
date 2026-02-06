import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';
import 'package:smart_transit/widgets/app_card.dart';
import 'package:smart_transit/widgets/station_label.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';
import 'package:smart_transit/theme/app_theme.dart';
import 'package:smart_transit/theme/app_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/state/app_state.dart';

class TicketScreen extends ConsumerWidget {
  final TicketModel? ticketArg;
  const TicketScreen({super.key, this.ticketArg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stationRepo = ref.read(stationRepositoryProvider);

    // If ticketArg is null, we might need to get it from context.extra if GoRouter passed it.
    final TicketModel? ticket =
        ticketArg ?? GoRouterState.of(context).extra as TicketModel?;

    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.noTripsFound)),
      );
    }

    // Lookup stations using Repository
    final sourceStation = stationRepo.getStationByIdWithFallback(
      stationId: ticket.sourceStationId,
      fallbackNameEn: ticket.sourceNameEn,
      fallbackNameAr:
          ticket.sourceNameEn, // Assuming same for fallback if missing
      fallbackTransportType: ticket.transportTypes.isNotEmpty
          ? ticket.transportTypes.first
          : 'Metro',
    );

    final destStation = stationRepo.getStationByIdWithFallback(
      stationId: ticket.destinationStationId,
      fallbackNameEn: ticket.destinationNameEn,
      fallbackNameAr: ticket.destinationNameEn,
      fallbackTransportType: ticket.transportTypes.isNotEmpty
          ? ticket.transportTypes.last
          : 'Metro',
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ticketTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.pagePadding),
          child: Column(
            children: [
              // Success Header
              const SizedBox(height: AppLayout.spacingMedium), // Was 20
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppLayout.pagePadding),
                child: const Icon(Icons.check, size: 60, color: Colors.white),
              ),
              const SizedBox(height: AppLayout.spacingLarge),
              Text(
                l10n.successTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: AppLayout.spacingXLarge),

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
                    const Divider(height: AppLayout.spacingXLarge),
                    QrImageView(
                      data: ticket.qrString,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                    const SizedBox(height: AppLayout.spacingMedium),
                    Text(
                      ticket.ticketId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.5,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Date & Time
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
                              ticket.timestamp.toString().substring(0, 10),
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
                            Text(
                              '${ticket.timestamp.hour}:${ticket.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppLayout.spacingLarge),

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
                            horizontal: AppLayout.spacingMedium,
                            vertical: AppLayout.spacingSmall,
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
                    backgroundColor: AppTheme.primaryBlue,
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
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppLayout.radiusLarge,
                      ),
                    ),
                  ),
                  child: Text(
                    l10n.backToHome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
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
