import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/places/data/places_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const placeJson = {
  'address': '1 MG Road, Bengaluru',
  'categories': ['Music Venue'],
  'distanceMeters': 340,
  'id': 'abc123',
  'latitude': 12.97,
  'longitude': 77.59,
  'name': 'The Humming Tree',
  'photoUrl': null,
};

PlacesRepository repositoryReturning(
  List<Map<String, dynamic>> places,
  void Function(http.Request) capture,
) {
  final client = MockClient((request) async {
    capture(request);
    return http.Response(jsonEncode(places), 200);
  });
  return PlacesRepository(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      accessToken: () async => 'firebase-token',
      httpClient: client,
    ),
  );
}

void main() {
  test('sends the search as query parameters and parses the array', () async {
    late http.Request captured;
    final repository = repositoryReturning([placeJson], (r) => captured = r);

    final places = await repository.search(
      latitude: 12.9716,
      longitude: 77.5946,
      query: '  jazz  ',
      radiusMeters: 1500,
    );

    expect(captured.url.path, '/v1/places/search');
    expect(captured.url.queryParameters, {
      'lat': '12.9716',
      'limit': '10',
      'lng': '77.5946',
      'query': 'jazz',
      'radius_m': '1500',
    });
    expect(captured.headers['authorization'], 'Bearer firebase-token');
    expect(places.single.name, 'The Humming Tree');
    expect(places.single.subtitle, 'Music Venue • 340m');
  });

  test('omits an empty query so the search is simply nearby', () async {
    late http.Request captured;
    final repository = repositoryReturning([], (r) => captured = r);

    await repository.search(latitude: 12.9716, longitude: 77.5946, query: '  ');

    expect(captured.url.queryParameters.containsKey('query'), isFalse);
  });

  test('formats a distance over a kilometre in kilometres', () async {
    final repository = repositoryReturning([
      {...placeJson, 'distanceMeters': 2400},
    ], (_) {});

    final places = await repository.search(latitude: 0, longitude: 0);

    expect(places.single.subtitle, 'Music Venue • 2.4km');
  });

  test('surfaces an unavailable provider as an ApiException', () async {
    final repository = PlacesRepository(
      ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        accessToken: () async => 'firebase-token',
        httpClient: MockClient(
          (_) async =>
              http.Response('{"code":"places_provider_not_configured"}', 503),
        ),
      ),
    );

    await expectLater(
      repository.search(latitude: 0, longitude: 0),
      throwsA(isA<ApiException>()),
    );
  });
}
