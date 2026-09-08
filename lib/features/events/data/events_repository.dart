import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/events/domain/happyn_event.dart';

class EventsRepository {
  EventsRepository(this._api);

  final ApiClient _api;

  Future<List<HappynEvent>> nearby({
    required double latitude,
    required double longitude,
    EventCategory? category,
    int limit = 50,
    bool includeLive = true,
    int radiusMeters = 5000,
    DateTime? startsBefore,
  }) async {
    final results = await _api.getList(
      '/v1/events/nearby',
      query: {
        'lat': '$latitude',
        'limit': '$limit',
        'lng': '$longitude',
        'radius_m': '$radiusMeters',
        if (category != null && category != EventCategory.unknown)
          'category': category.name,
        // The API defaults to including live occurrences. Leave the default
        // off the wire, but let future-only time controls opt out explicitly.
        if (!includeLive) 'include_live': 'false',
        if (startsBefore != null)
          'starts_before': startsBefore.toUtc().toIso8601String(),
      },
    );
    return [
      for (final result in results)
        HappynEvent.fromJson(result as Map<String, dynamic>),
    ];
  }
}
