import 'package:smart_transit/models/station_model.dart';

class SegmentModel {
  final StationModel from;
  final StationModel to;
  final double durationMinutes;
  final TransitType mode;
  final double cost;
  final String? lineName;

  SegmentModel({
    required this.from,
    required this.to,
    required this.durationMinutes,
    required this.mode,
    required this.cost,
    this.lineName,
  });
}

class RouteModel {
  final List<SegmentModel> segments;
  final double totalCost;
  final double totalDurationMinutes;
  final int totalStops;

  RouteModel({
    required this.segments,
    required this.totalCost,
    required this.totalDurationMinutes,
    required this.totalStops,
  });
}
