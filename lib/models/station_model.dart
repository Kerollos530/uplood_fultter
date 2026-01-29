enum TransitType { metro, lrt, monorail, brt }

class StationModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final TransitType type;
  final double latitude;
  final double longitude;
  final List<String> lines; // e.g., ["Line 1", "Line 2"]
  final bool isActive;

  StationModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.lines,
    this.isActive = true,
  });

  String getLocalizedName(bool isArabic) => isArabic ? nameAr : nameEn;
}
