import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/search/presentation/search_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const testCentre = (latitude: 12.9352, longitude: 77.6245);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('lists nearby places, then what was typed', (tester) async {
    final queries = <String?>[];
    final centres = <String>[];
    final client = MockClient((request) async {
      final query = request.url.queryParameters['query'];
      queries.add(query);
      centres.add(
        '${request.url.queryParameters['lat']},'
        '${request.url.queryParameters['lng']}',
      );
      return http.Response(
        jsonEncode([
          {
            'address': '1 MG Road, Bengaluru',
            'categories': ['Music Venue'],
            'distanceMeters': 340,
            'id': 'abc123',
            'latitude': 12.97,
            'longitude': 77.59,
            'name': query == null ? 'Nearby Bar' : 'Result for $query',
            'photoUrl': null,
          },
        ]),
        200,
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        retry: retryOnce,
        overrides: [
          searchCentreProvider.overrideWith((ref) async => testCentre),
          apiClientProvider.overrideWithValue(
            ApiClient(
              baseUri: Uri.parse('https://api.example.com'),
              accessToken: () async => 'firebase-token',
              httpClient: client,
            ),
          ),
        ],
        child: MaterialApp(
          home: const SearchScreen(),
          theme: buildHappynTheme(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('NEARBY NOW'), findsOneWidget);
    expect(find.text('Nearby Bar'), findsOneWidget);
    expect(find.text('Music Venue • 340m'), findsOneWidget);
    expect(find.text('Powered by Foursquare'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'jazz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(queries, [null, 'jazz']);
    expect(centres, ['12.9352,77.6245', '12.9352,77.6245']);
    expect(find.text('Result for jazz'), findsOneWidget);
    expect(find.text('RESULTS'), findsOneWidget);
  });

  testWidgets('reports an unavailable backend instead of failing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: retryOnce,
        overrides: [
          searchCentreProvider.overrideWith((ref) async => testCentre),
          apiClientProvider.overrideWithValue(
            ApiClient(
              baseUri: Uri.parse('https://api.example.com'),
              accessToken: () async => 'firebase-token',
              httpClient: MockClient((_) async => http.Response('{}', 503)),
            ),
          ),
        ],
        child: MaterialApp(
          home: const SearchScreen(),
          theme: buildHappynTheme(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Places are unavailable right now.'), findsOneWidget);
  });

  test('falls back to the city centre when the device has no fix', () async {
    // No platform channel in a unit test, so the geolocator call throws; a
    // refused permission and a disabled location service take the same path.
    final container = ProviderContainer(retry: retryOnce);
    addTearDown(container.dispose);

    await expectLater(
      container.read(searchCentreProvider.future),
      completion(bengaluruCentre),
    );
  });
}
