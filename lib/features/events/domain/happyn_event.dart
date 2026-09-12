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
    required this.isLive,
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
    // Older deployed API versions do not have this field yet. Treating it as
    // false keeps the app compatible during a rolling mobile/API deploy.
    isLive: json['isLive'] as bool? ?? false,
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
  final bool isLive;
  final double latitude;
  final double longitude;
  final DateTime startAt;
  final String title;
  final String venueName;

  /// "8:30 PM", the form the event page was designed around.
  String get startLabel => clockLabel(startAt);

  String? get endLabel => endAt == null ? null : clockLabel(endAt!);
}

String clockLabel(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
}
