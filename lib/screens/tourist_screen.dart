import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/data/mock_data/mock_data.dart';
import 'package:smart_transit/state/app_state.dart';
import 'package:smart_transit/state/settings_provider.dart';

class TouristScreen extends ConsumerStatefulWidget {
  const TouristScreen({super.key});

  @override
  ConsumerState<TouristScreen> createState() => _TouristScreenState();
}

class _TouristScreenState extends ConsumerState<TouristScreen> {
  String _selectedCategory = 'All Places';

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(isArabicProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'سياحه',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/planner'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Which landmark to visit?',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryChip('All Places', Icons.place),
                const SizedBox(width: 8),
                _buildCategoryChip('Pharaonic', Icons.museum),
                const SizedBox(width: 8),
                _buildCategoryChip('Islamic', Icons.mosque),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: landmarks.length,
              itemBuilder: (context, index) {
                final landmark = landmarks[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Placeholder
                      Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              landmark.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "أقرب محطة: ${isArabic ? 'الشهداء' : 'Al-Shohadaa'}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? landmark.nameAr : landmark.nameEn,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              isArabic
                                  ? 'اسلامي • اسلامي'
                                  : 'Islamic • Islamic',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Find route logic
                                  final start = allStations.firstWhere(
                                    (s) => s.id == 'm3_adly',
                                  ); // Mock start
                                  final end = allStations.firstWhere(
                                    (s) => s.id == landmark.nearestStationId,
                                    orElse: () => allStations.first,
                                  );

                                  final route = await ref
                                      .read(routingServiceProvider)
                                      .findRoute(start.id, end.id);
                                  ref.read(routeResultProvider.notifier).state =
                                      route;
                                  if (context.mounted) {
                                    context.push('/route_result');
                                  }
                                },
                                icon: const Icon(
                                  Icons.directions_walk,
                                  size: 16,
                                ),
                                label: Text(
                                  isArabic
                                      ? "اذهب الان / 10 دقائق من المحطة"
                                      : "Go There / 10 mins from station",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1FAAF1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) Icon(icon, color: Colors.white, size: 16),
          if (isSelected) const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = label;
        });
      },
      selectedColor: const Color(0xFF1FAAF1),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      showCheckmark: false,
    );
  }
}
