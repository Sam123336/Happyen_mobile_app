import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/places/domain/place.dart';

class PlacesRepository {
  PlacesRepository(this._api);

  final ApiClient _api;

  Future<List<Place>> search({
    required double latitude,
    required double longitude,
    int limit = 10,
    String? query,
    int? radiusMeters,
  }) async {
    final results = await _api.getList(
      '/v1/places/search',
      query: {
        'lat': '$latitude',
        'limit': '$limit',
        'lng': '$longitude',
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        if (radiusMeters != null) 'radius_m': '$radiusMeters',
      },
    );
    return [
      for (final result in results)
        Place.fromJson(result as Map<String, dynamic>),
    ];
  }
}
