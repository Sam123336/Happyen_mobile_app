import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/events/domain/happyn_event.dart';

/// How far around the search centre the city looks, in metres. The header
/// quotes it, so it lives here rather than as a silent default.
const nearbyRadiusMeters = 5000;

class EventsRepository {
  EventsRepository(this._api);

  final ApiClient _api;

  Future<List<HappynEvent>> nearby({
    required double latitude,
    required double longitude,
    EventCategory? category,
    int limit = 50,
    bool includeLive = true,
    int radiusMeters = nearbyRadiusMeters,
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
