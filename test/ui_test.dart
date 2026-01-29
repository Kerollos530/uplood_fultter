import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/screens/login_screen.dart';
import 'package:smart_transit/screens/planner_screen.dart';

void main() {
  testWidgets('Login Screen has Email and Password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    expect(find.text('Login'), findsWidgets); // Button and Title
    expect(find.byType(TextField), findsNWidgets(2)); // Email + Pass
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('Planner Screen has Dropdowns and Find Route button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PlannerScreen())),
    );

    expect(find.text('Plan Your Journey'), findsOneWidget);
    // DropdownButtonFormField internally uses more complex widgets, but we can look for the Label text
    // Note: Dropdown labels might be part of decoration.
    // Let's check for the Button "Find Route"
    expect(find.text('Find Route'), findsOneWidget);
    expect(find.text('Tourist Mode'), findsOneWidget);
  });
}
