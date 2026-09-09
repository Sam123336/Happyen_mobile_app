import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happyn_mobile/core/map/happyn_map.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_screen.dart';
import 'package:happyn_mobile/main.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('renders the city tab inside the navigation shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: HappynApp()));

    expect(find.text('Bengaluru'), findsOneWidget);
    expect(find.text('CITY'), findsOneWidget);
    expect(find.text('DISCOVER'), findsOneWidget);
    expect(find.text('PEOPLE'), findsOneWidget);
  });

  testWidgets('switches to the discover tab from the bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: HappynApp()));

    await tester.tap(find.text('DISCOVER'));
    await tester.pump();

    expect(find.text('What are you feeling?'), findsOneWidget);
  });

  testWidgets('renders the profile screen without a Firebase session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: retryOnce,
        child: MaterialApp(
          home: const ProfileScreen(),
          theme: buildHappynTheme(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Verified Moments'), findsOneWidget);
  });

  testWidgets('the city map shows its diorama until the style loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HappynMap(centre: bengaluruCentre, fallback: Text('diorama')),
      ),
    );

    expect(find.text('diorama'), findsOneWidget);
  });
}
