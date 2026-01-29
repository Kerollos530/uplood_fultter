import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';

// --- STATIONS ---
final List<StationModel> allStations = [
  // --- METRO LINE 1 (Blue) ---
  StationModel(
    id: 'm1_helwan',
    nameAr: 'حلوان',
    nameEn: 'Helwan',
    type: TransitType.metro,
    latitude: 29.849,
    longitude: 31.334,
    lines: ['Line 1'],
  ),
  StationModel(
    id: 'm1_maadi',
    nameAr: 'المعادي',
    nameEn: 'Maadi',
    type: TransitType.metro,
    latitude: 29.960,
    longitude: 31.248,
    lines: ['Line 1'],
  ),
  StationModel(
    id: 'm1_sadat',
    nameAr: 'السادات',
    nameEn: 'Sadat',
    type: TransitType.metro,
    latitude: 30.044,
    longitude: 31.235,
    lines: ['Line 1', 'Line 2'],
  ), // Interchange
  StationModel(
    id: 'm1_nasser',
    nameAr: 'جمال عبد الناصر',
    nameEn: 'Gamal Abdel Nasser',
    type: TransitType.metro,
    latitude: 30.051,
    longitude: 31.238,
    lines: ['Line 1', 'Line 3'],
  ), // Interchange
  StationModel(
    id: 'm1_shohada',
    nameAr: 'الشهداء',
    nameEn: 'Al-Shohada',
    type: TransitType.metro,
    latitude: 30.061,
    longitude: 31.247,
    lines: ['Line 1', 'Line 2'],
  ), // Interchange
  StationModel(
    id: 'm1_elmarg',
    nameAr: 'المرج الجديدة',
    nameEn: 'New El Marg',
    type: TransitType.metro,
    latitude: 30.151,
    longitude: 31.336,
    lines: ['Line 1'],
  ),

  // --- METRO LINE 2 (Red) ---
  StationModel(
    id: 'm2_shobra',
    nameAr: 'شبرا الخيمة',
    nameEn: 'Shobra El Kheima',
    type: TransitType.metro,
    latitude: 30.113,
    longitude: 31.259,
    lines: ['Line 2'],
  ),
  // Shohada & Sadat are already defined above, but we need to treat them as same node or connect them.
  // In this simplified model, we will use the SAME station object if it is an interchange.
  StationModel(
    id: 'm2_attaba',
    nameAr: 'العتبة',
    nameEn: 'Attaba',
    type: TransitType.metro,
    latitude: 30.052,
    longitude: 31.247,
    lines: ['Line 2', 'Line 3'],
  ), // Interchange
  StationModel(
    id: 'm2_dokki',
    nameAr: 'الدقي',
    nameEn: 'Dokki',
    type: TransitType.metro,
    latitude: 30.038,
    longitude: 31.217,
    lines: ['Line 2'],
  ),
  StationModel(
    id: 'm2_giza',
    nameAr: 'الجيزة',
    nameEn: 'Giza',
    type: TransitType.metro,
    latitude: 30.010,
    longitude: 31.212,
    lines: ['Line 2'],
  ),

  // --- METRO LINE 3 (Green) ---
  StationModel(
    id: 'm3_kitkat',
    nameAr: 'الكيت كات',
    nameEn: 'Kit Kat',
    type: TransitType.metro,
    latitude: 30.063,
    longitude: 31.212,
    lines: ['Line 3'],
  ),
  // Attaba & Nasser defined
  StationModel(
    id: 'm3_abbasiya',
    nameAr: 'العباسية',
    nameEn: 'Abbasiya',
    type: TransitType.metro,
    latitude: 30.070,
    longitude: 31.278,
    lines: ['Line 3'],
  ),
  StationModel(
    id: 'm3_stadium',
    nameAr: 'الإستاد',
    nameEn: 'Stadium',
    type: TransitType.metro,
    latitude: 30.073,
    longitude: 31.309,
    lines: ['Line 3', 'Monorail'],
  ), // Interchange
  StationModel(
    id: 'm3_adly',
    nameAr: 'عدلي منصور',
    nameEn: 'Adly Mansour',
    type: TransitType.metro,
    latitude: 30.141,
    longitude: 31.428,
    lines: ['Line 3', 'LRT'],
  ), // Hub
  // --- LRT (Light Rail) ---
  // Adly defined
  StationModel(
    id: 'lrt_future',
    nameAr: 'مدينة المستقبل',
    nameEn: 'Future City',
    type: TransitType.lrt,
    latitude: 30.150,
    longitude: 31.470,
    lines: ['LRT'],
  ),
  StationModel(
    id: 'lrt_arts',
    nameAr: 'مدينة الفنون',
    nameEn: 'Arts & Culture City',
    type: TransitType.lrt,
    latitude: 30.160,
    longitude: 31.550,
    lines: ['LRT'],
  ),

  // --- MONORAIL (East) ---
  // Stadium defined
  StationModel(
    id: 'mono_nasr',
    nameAr: 'مدينة نصر',
    nameEn: 'Nasr City',
    type: TransitType.monorail,
    latitude: 30.060,
    longitude: 31.330,
    lines: ['Monorail'],
  ),
  StationModel(
    id: 'mono_newcap',
    nameAr: 'العاصمة الإدارية',
    nameEn: 'New Capital',
    type: TransitType.monorail,
    latitude: 30.010,
    longitude: 31.700,
    lines: ['Monorail'],
  ),

  // --- BRT (Ring Road - Simplified) ---
  StationModel(
    id: 'brt_adly',
    nameAr: 'محطة عدلي منصور BRT',
    nameEn: 'Adly Mansour BRT',
    type: TransitType.brt,
    latitude: 30.141,
    longitude: 31.428,
    lines: ['BRT'],
  ), // Pseudo-connected to Adly Metro
  StationModel(
    id: 'brt_maadi',
    nameAr: 'المعادي BRT',
    nameEn: 'Maadi BRT',
    type: TransitType.brt,
    latitude: 29.965,
    longitude: 31.260,
    lines: ['BRT'],
  ), // Close to Maadi
];

// --- ADJACENCY LIST (Edges) ---
// From ID -> List of (To ID, Minutes, Type)
class Connection {
  final String toId;
  final double minutes;
  final TransitType type;
  final String lineName;
  Connection(this.toId, this.minutes, this.type, this.lineName);
}

final Map<String, List<Connection>> stationConnections = {
  // Line 1

  // Nasser L3 connections: To Attaba (L3), To Zamalek/Kitkat (L3).
  // Let's simplify:
  // L1: Helwan - Maadi - Sadat - Nasser - Shohada - El Marg
  // L2: Giza - Dokki - Sadat - Attaba - Shohada - Shobra
  // L3: Kitkat - Nasser - Attaba - Abbasiya - Stadium - Adly Mansour

  // -- REFINED CONNECTIONS --
  // L1
  'm1_helwan': [Connection('m1_maadi', 12, TransitType.metro, 'Line 1')],
  'm1_maadi': [
    Connection('m1_helwan', 12, TransitType.metro, 'Line 1'),
    Connection('m1_sadat', 18, TransitType.metro, 'Line 1'),
  ],
  'm1_sadat': [
    Connection('m1_maadi', 18, TransitType.metro, 'Line 1'),
    Connection('m1_nasser', 3, TransitType.metro, 'Line 1'),
    Connection('m2_dokki', 5, TransitType.metro, 'Line 2'),
    Connection('m2_attaba', 4, TransitType.metro, 'Line 2'),
  ], // Sadat is L1 & L2
  'm1_nasser': [
    Connection('m1_sadat', 3, TransitType.metro, 'Line 1'),
    Connection('m1_shohada', 3, TransitType.metro, 'Line 1'),
    Connection('m3_kitkat', 5, TransitType.metro, 'Line 3'),
    Connection('m2_attaba', 3, TransitType.metro, 'Line 3'),
  ], // Nasser is L1 & L3
  'm1_shohada': [
    Connection('m1_nasser', 3, TransitType.metro, 'Line 1'),
    Connection('m1_elmarg', 25, TransitType.metro, 'Line 1'),
    Connection('m2_attaba', 3, TransitType.metro, 'Line 2'),
    Connection('m2_shobra', 10, TransitType.metro, 'Line 2'),
  ], // Shohada is L1 & L2
  'm1_elmarg': [Connection('m1_shohada', 25, TransitType.metro, 'Line 1')],

  // L2 (Partial overlay)
  'm2_giza': [Connection('m2_dokki', 6, TransitType.metro, 'Line 2')],
  'm2_dokki': [
    Connection('m2_giza', 6, TransitType.metro, 'Line 2'),
    Connection('m1_sadat', 5, TransitType.metro, 'Line 2'),
  ],
  'm2_attaba': [
    Connection('m1_sadat', 4, TransitType.metro, 'Line 2'),
    Connection('m1_shohada', 3, TransitType.metro, 'Line 2'),
    Connection('m1_nasser', 3, TransitType.metro, 'Line 3'),
    Connection('m3_abbasiya', 8, TransitType.metro, 'Line 3'),
  ], // Attaba is L2 & L3
  'm2_shobra': [Connection('m1_shohada', 10, TransitType.metro, 'Line 2')],

  // L3
  'm3_kitkat': [Connection('m1_nasser', 5, TransitType.metro, 'Line 3')],
  'm3_abbasiya': [
    Connection('m2_attaba', 8, TransitType.metro, 'Line 3'),
    Connection('m3_stadium', 7, TransitType.metro, 'Line 3'),
  ],
  'm3_stadium': [
    Connection('m3_abbasiya', 7, TransitType.metro, 'Line 3'),
    Connection('m3_adly', 15, TransitType.metro, 'Line 3'),
    Connection('mono_nasr', 10, TransitType.monorail, 'Monorail'),
  ], // Stadium is L3 & Monorail
  'm3_adly': [
    Connection('m3_stadium', 15, TransitType.metro, 'Line 3'),
    Connection('lrt_future', 12, TransitType.lrt, 'LRT'),
    Connection('brt_adly', 5, TransitType.brt, 'BRT'),
  ], // Adly is L3 & LRT & BRT
  // LRT
  'lrt_future': [
    Connection('m3_adly', 12, TransitType.lrt, 'LRT'),
    Connection('lrt_arts', 10, TransitType.lrt, 'LRT'),
  ],
  'lrt_arts': [Connection('lrt_future', 10, TransitType.lrt, 'LRT')],

  // Monorail
  'mono_nasr': [
    Connection('m3_stadium', 10, TransitType.monorail, 'Monorail'),
    Connection('mono_newcap', 35, TransitType.monorail, 'Monorail'),
  ],
  'mono_newcap': [
    Connection('mono_nasr', 35, TransitType.monorail, 'Monorail'),
  ],

  // BRT
  'brt_adly': [
    Connection('m3_adly', 5, TransitType.brt, 'BRT (Transfer)'),
    Connection('brt_maadi', 45, TransitType.brt, 'BRT'),
  ],
  'brt_maadi': [Connection('brt_adly', 45, TransitType.brt, 'BRT')],
};

// --- DATA ---
final List<LandmarkModel> landmarks = [
  LandmarkModel(
    id: 'l_pyramids',
    nameEn: 'Great Pyramids of Giza',
    nameAr: 'أهرامات الجيزة',
    descriptionEn: 'The oldest of the Seven Wonders of the Ancient World.',
    descriptionAr: 'من أقدم عجائب الدنيا السبع.',
    imageUrl: 'assets/images/pyramids.jpg',
    nearestStationId: 'm2_giza',
  ),
  LandmarkModel(
    id: 'l_tower',
    nameEn: 'Cairo Tower',
    nameAr: 'برج القاهرة',
    descriptionEn: 'Free-standing concrete tower in Cairo.',
    descriptionAr: 'برج خرساني يقع في القاهرة.',
    imageUrl: 'assets/images/cairo_tower.jpg',
    nearestStationId:
        'm1_nasser', // or Opera which is closer but not in my short list. Nasser is close enough for mock.
  ),
  LandmarkModel(
    id: 'l_azhar',
    nameEn: 'Al-Azhar Mosque',
    nameAr: 'الجامع الأزهر',
    descriptionEn: 'One of the oldest mosques in Cairo.',
    descriptionAr: 'من أقدم المساجد في القاهرة.',
    imageUrl: 'assets/images/azhar.jpg',
    nearestStationId: 'm2_attaba',
  ),
];
