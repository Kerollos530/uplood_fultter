import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/state/app_state.dart';
import 'package:smart_transit/state/settings_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _passengerCount = 1;

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(routeResultProvider);
    final isArabic = ref.watch(isArabicProvider);

    if (route == null) {
      return const Scaffold(body: Center(child: Text("No route")));
    }

    final perTicketPrice = route.totalCost;
    final totalPrice = perTicketPrice * _passengerCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'سعر التذكرة',
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildRouteRow(
                            Icons.my_location,
                            route.segments.first.from.getLocalizedName(
                              isArabic,
                            ),
                            "محطة البداية",
                          ),
                          const Divider(height: 24),
                          _buildRouteRow(
                            Icons.location_on,
                            route.segments.last.to.getLocalizedName(isArabic),
                            "الوجهه",
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
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "الركاب\nحدد العدد",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(12),
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
                    const Text(
                      "Total Price\nالسعر الاجمالي",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      "$totalPrice EGP",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
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
                    child: const Text(
                      'شراء التذكرة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
