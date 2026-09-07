import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/events/data/events_repository.dart';
import 'package:happyn_mobile/features/events/domain/happyn_event.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const occurrenceJson = {
  'category': 'comedy',
  'distanceMeters': 340.5,
  'endAt': '2026-09-08T18:00:00.000Z',
  'eventId': 'event-1',
  'heroImageUrl': null,
  'id': 'occurrence-1',
  'latitude': 12.9784,
  'longitude': 77.6408,
  'startAt': '2026-09-08T15:00:00.000Z',
  'title': 'Open Mic: First Drafts',
  'venueName': 'Neon Terrace',
};

EventsRepository repositoryReturning(
  List<Map<String, dynamic>> occurrences,
  void Function(http.Request) capture,
) => EventsRepository(
  ApiClient(
    baseUri: Uri.parse('https://api.example.com'),
    accessToken: () async => 'firebase-token',
    httpClient: MockClient((request) async {
      capture(request);
      return http.Response(jsonEncode(occurrences), 200);
    }),
  ),
);

void main() {
  test('asks for upcoming occurrences around a point', () async {
    late http.Request captured;
    final repository = repositoryReturning([
      occurrenceJson,
    ], (r) => captured = r);

    final events = await repository.nearby(
      category: EventCategory.comedy,
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 3000,
    );

    expect(captured.url.path, '/v1/events/nearby');
    expect(captured.url.queryParameters, {
      'category': 'comedy',
      'lat': '12.9716',
      'limit': '50',
      'lng': '77.5946',
      'radius_m': '3000',
    });
    expect(events.single.title, 'Open Mic: First Drafts');
    expect(events.single.venueName, 'Neon Terrace');
    expect(events.single.category, EventCategory.comedy);
  });

  test('sends no category for the unfiltered "for you" view', () async {
    late http.Request captured;
    final repository = repositoryReturning([], (r) => captured = r);

    await repository.nearby(latitude: 0, longitude: 0);

    expect(captured.url.queryParameters.containsKey('category'), isFalse);
  });

  test('keeps a category it does not recognise off the map filter', () async {
    final repository = repositoryReturning([
      {...occurrenceJson, 'category': 'techno'},
    ], (_) {});

    final events = await repository.nearby(latitude: 0, longitude: 0);

    expect(events.single.category, EventCategory.unknown);
  });

  test('renders a start time the way the diorama expects', () {
    final event = HappynEvent.fromJson({
      ...occurrenceJson,
      'startAt': DateTime(2026, 9, 8, 20, 30).toUtc().toIso8601String(),
    });

    expect(event.startLabel, '8:30 PM');
  });
}
