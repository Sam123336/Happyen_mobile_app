import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
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
}
