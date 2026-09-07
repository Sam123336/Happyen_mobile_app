/// A venue candidate as returned by `GET /v1/places/search`.
class Place {
  const Place({
    required this.categories,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    this.address,
    this.distanceMeters,
    this.photoUrl,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    address: json['address'] as String?,
    categories: ((json['categories'] as List<dynamic>?) ?? const [])
        .cast<String>(),
    distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
    id: json['id'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    name: json['name'] as String,
    photoUrl: json['photoUrl'] as String?,
  );

  final String? address;
  final List<String> categories;
  final double? distanceMeters;
  final String id;
  final double latitude;
  final double longitude;
  final String name;
  final String? photoUrl;

  /// "Underground Club • 0.5km", the subtitle the search cards were designed for.
  String get subtitle {
    final category = categories.isEmpty ? null : categories.first;
    final distance = distanceMeters == null
        ? null
        : distanceMeters! < 1000
        ? '${distanceMeters!.round()}m'
        : '${(distanceMeters! / 1000).toStringAsFixed(1)}km';
    return [category, distance].nonNulls.join(' • ');
  }
}
