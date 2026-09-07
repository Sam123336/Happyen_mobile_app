/// The categories the city screen filters by. [unknown] is deliberate: the API
/// may learn a new category before this app is updated, and an unrecognised one
/// must not break the map.
enum EventCategory { music, comedy, food, pets, sports, other, unknown }

EventCategory _categoryFrom(String? name) => EventCategory.values.firstWhere(
  (category) => category.name == name,
  orElse: () => EventCategory.unknown,
);

/// One occurrence, as returned by `GET /v1/events/nearby`.
class HappynEvent {
  const HappynEvent({
    required this.category,
    required this.distanceMeters,
    required this.eventId,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.startAt,
    required this.title,
    required this.venueName,
    this.endAt,
    this.heroImageUrl,
  });

  factory HappynEvent.fromJson(Map<String, dynamic> json) => HappynEvent(
    category: _categoryFrom(json['category'] as String?),
    distanceMeters: (json['distanceMeters'] as num).toDouble(),
    endAt: json['endAt'] == null
        ? null
        : DateTime.parse(json['endAt'] as String).toLocal(),
    eventId: json['eventId'] as String,
    heroImageUrl: json['heroImageUrl'] as String?,
    id: json['id'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    startAt: DateTime.parse(json['startAt'] as String).toLocal(),
    title: json['title'] as String,
    venueName: json['venueName'] as String,
  );

  final EventCategory category;
  final double distanceMeters;
  final DateTime? endAt;
  final String eventId;
  final String? heroImageUrl;
  final String id;
  final double latitude;
  final double longitude;
  final DateTime startAt;
  final String title;
  final String venueName;

  /// "8:30 PM", the form the city diorama was designed around.
  String get startLabel {
    final hour = startAt.hour % 12 == 0 ? 12 : startAt.hour % 12;
    final minute = startAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${startAt.hour < 12 ? 'AM' : 'PM'}';
  }
}
