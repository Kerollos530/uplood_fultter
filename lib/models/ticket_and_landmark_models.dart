class TicketModel {
  final String ticketId;
  final String userId;
  final String sourceStationId;
  final String destinationStationId;
  final String sourceNameEn;
  final String destinationNameEn;
  final double price;
  final DateTime timestamp;
  final List<String> transportTypes;
  final int passengerIndex; // 1-based index (e.g. 1 for "Ticket 1 of 3")
  final int totalPassengers; // Total tickets in this batch (e.g. 3)

  TicketModel({
    required this.ticketId,
    required this.userId,
    required this.sourceStationId,
    required this.destinationStationId,
    required this.sourceNameEn,
    required this.destinationNameEn,
    required this.price,
    required this.timestamp,
    this.transportTypes = const ['Metro'],
    this.passengerIndex = 1,
    this.totalPassengers = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'sourceStationId': sourceStationId,
      'destinationStationId': destinationStationId,
      'sourceNameEn': sourceNameEn,
      'destinationNameEn': destinationNameEn,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'transportTypes': transportTypes,
      'passengerIndex': passengerIndex,
      'totalPassengers': totalPassengers,
    };
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      ticketId: json['ticketId'] ?? json['ticket_id'],
      userId: json['userId'] ?? json['user_id'],
      sourceStationId: json['sourceStationId'] ?? json['source_station_id'],
      destinationStationId:
          json['destinationStationId'] ?? json['destination_station_id'],
      sourceNameEn: json['sourceNameEn'] ?? json['source_name_en'],
      destinationNameEn:
          json['destinationNameEn'] ?? json['destination_name_en'],
      price: (json['price'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      transportTypes:
          (json['transportTypes'] ?? json['transport_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Metro'],
      passengerIndex: json['passengerIndex'] ?? 1,
      totalPassengers: json['totalPassengers'] ?? 1,
    );
  }

  String get qrString =>
      "SMART_TRANSIT|$ticketId|$userId|${timestamp.toIso8601String()}|$passengerIndex|$totalPassengers";
}

class LandmarkModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String imageUrl;
  final String nearestStationId;

  LandmarkModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.imageUrl,
    required this.nearestStationId,
  });
}
