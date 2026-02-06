import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/state/app_state.dart';
import 'package:smart_transit/state/settings_provider.dart';
import 'package:smart_transit/theme/app_layout.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _passengerCount = 1;
  bool _showSummary = false;

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(routeResultProvider);
    final isArabic = ref.watch(isArabicProvider);
    final l10n = AppLocalizations.of(context)!;

    if (route == null) {
      return const Scaffold(body: Center(child: Text("No route")));
    }

    final perTicketPrice = route.totalCost;
    final totalPrice = perTicketPrice * _passengerCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _showSummary
              ? l10n.details
              : l10n.price, // "Order Summary" / "Ticket Price"
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_showSummary) {
              setState(() => _showSummary = false);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Map Background with Route Info Card
          Expanded(
            child: Stack(
              children: [
                // Clean Map Placeholder
                Container(
                  color: Colors.blue[50],
                  child: Center(
                    child: Icon(Icons.map, size: 100, color: Colors.blue[100]),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  left: 20,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppLayout.radiusMedium,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppLayout.cardPadding),
                      child: Column(
                        children: [
                          _buildRouteRow(
                            Icons.my_location,
                            route.segments.first.from.getLocalizedName(
                              isArabic,
                            ),
                            l10n.fromStation,
                          ),
                          const Divider(height: AppLayout.spacingLarge),
                          _buildRouteRow(
                            Icons.location_on,
                            route.segments.last.to.getLocalizedName(isArabic),
                            l10n.toStation,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet
          Container(
            padding: const EdgeInsets.all(AppLayout.pagePadding),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppLayout.radiusLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: _showSummary
                ? _buildSummaryView(totalPrice, l10n)
                : _buildPassengerSelectionView(totalPrice, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerSelectionView(
    double totalPrice,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${l10n.passengers}\n${l10n.selectCount}", // "Passengers/Select Count"
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(AppLayout.radiusSmall),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (_passengerCount > 1) {
                        setState(() => _passengerCount--);
                      }
                    },
                  ),
                  Text(
                    "$_passengerCount",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF1FAAF1),
                    ),
                    onPressed: () {
                      if (_passengerCount < 10) {
                        setState(() => _passengerCount++);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.totalPrice, style: const TextStyle(color: Colors.grey)),
            Text(
              "$totalPrice EGP",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() => _showSummary = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1FAAF1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppLayout.radiusLarge),
              ),
            ),
            child: const Text(
              'Continue', // l10n.continue
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView(double totalPrice, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.tickets, style: const TextStyle(color: Colors.grey)),
            Text(
              "x$_passengerCount",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.spacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Class", style: TextStyle(color: Colors.grey)),
            Text(
              l10n.standardClass,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(height: AppLayout.spacingLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalPrice,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "$totalPrice EGP",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF1FAAF1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              context.push('/payment');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1FAAF1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              l10n.buyTicket,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteRow(IconData icon, String title, String sub) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(icon, color: const Color(0xFF1FAAF1)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
