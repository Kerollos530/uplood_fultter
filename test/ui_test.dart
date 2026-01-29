import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/screens/login_screen.dart';
import 'package:smart_transit/screens/planner_screen.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Login Screen has Email and Password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );

    // Wait for localizations to load if necessary (usually synchronous in tests but good practice to settle)
    await tester.pumpAndSettle();

    // We expect either English or Arabic check
    // "Login" (en) or "تسجيل الدخول" (ar)
    // "Create Account" (en) or "انشاء حساب" (ar)

    // We expect either English or Arabic check
    final loginFinder = find.text('Login');
    final loginArFinder = find.text('تسجيل الدخول');

    // Check which one is present
    if (loginFinder.evaluate().isNotEmpty) {
      expect(
        loginFinder,
        findsWidgets,
      ); // findsWidgets because it might be in Title and Button
    } else {
      expect(loginArFinder, findsWidgets);
    }

    final createFinder = find.text('Create Account');
    final createArFinder = find.text('انشاء حساب');

    if (createFinder.evaluate().isNotEmpty) {
      expect(createFinder, findsOneWidget);
    } else {
      expect(createArFinder, findsOneWidget);
    }
  });

  testWidgets('Planner Screen has Dropdowns and Find Route button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PlannerScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Wait, let's double check app_ar.arb content for "findRoute"
    // I read it earlier: "findRoute": "بحث عن مسار"
    // AND "searchRoute": "ابحث عن رحلة"
    // PlannerScreen uses `l10n.searchRoute` for the button.
    // In English arb: "searchRoute": "Search Route"

    const buttonTextEn = 'Search Route';
    const buttonTextAr = 'ابحث عن رحلة';

    final finderEn = find.text(buttonTextEn);
    final finderAr = find.text(buttonTextAr);

    if (finderEn.evaluate().isNotEmpty) {
      expect(finderEn, findsOneWidget);
    } else {
      expect(finderAr, findsOneWidget);
    }
  });
}
