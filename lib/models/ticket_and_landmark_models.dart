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

  TicketModel({
    required this.ticketId,
    required this.userId,
    required this.sourceStationId,
    required this.destinationStationId,
    required this.sourceNameEn,
    required this.destinationNameEn,
    required this.price,
    required this.timestamp,
    this.transportTypes = const [
      'Metro',
    ], // Default to Metro for backward compatibility
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
    };
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      ticketId: json['ticketId'],
      userId: json['userId'],
      sourceStationId: json['sourceStationId'],
      destinationStationId: json['destinationStationId'],
      sourceNameEn: json['sourceNameEn'],
      destinationNameEn: json['destinationNameEn'],
      price: (json['price'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      transportTypes:
          (json['transportTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Metro'],
    );
  }

  String get qrString =>
      "SMART_TRANSIT|$ticketId|$userId|${timestamp.toIso8601String()}";
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
