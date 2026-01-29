import 'package:flutter/material.dart';

class StationLabel extends StatelessWidget {
  final String stationName;
  final String? transportType;
  final String? lineName;
  final bool isArabic;

  const StationLabel({
    super.key,
    required this.stationName,
    this.transportType,
    this.lineName,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on transport type
    Color badgeColor = Colors.grey;
    String typeText = transportType ?? '';

    // Normalize type text for comparison if needed, or just display as is
    if (typeText.toLowerCase().contains('metro')) {
      badgeColor = Colors.blue;
    } else if (typeText.toLowerCase().contains('lrt')) {
      badgeColor = Colors.green;
    } else if (typeText.toLowerCase().contains('brt')) {
      badgeColor = Colors.orange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              stationName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (transportType != null && transportType!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '($transportType)',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (transportType != null && transportType!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transportType!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (lineName != null && lineName!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Text(
                  lineName!,
                  style: TextStyle(color: Colors.grey[800], fontSize: 10),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
