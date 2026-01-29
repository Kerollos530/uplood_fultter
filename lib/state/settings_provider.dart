import 'package:flutter_riverpod/flutter_riverpod.dart';

final isArabicProvider = StateProvider<bool>((ref) => true); // Default Arabics
final isDarkModeProvider = StateProvider<bool>((ref) => false);
