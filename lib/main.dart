import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/router.dart';
import 'package:smart_transit/theme/app_theme.dart';
import 'package:smart_transit/state/settings_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:smart_transit/l10n/gen/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: SmartTransitApp()));
}

class SmartTransitApp extends ConsumerWidget {
  const SmartTransitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final isArabic = ref.watch(isArabicProvider);

    return MaterialApp.router(
      title: 'Smart Transit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      locale: isArabic ? const Locale('ar') : const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
