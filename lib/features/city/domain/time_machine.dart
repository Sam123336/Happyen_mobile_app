import 'package:happyn_mobile/core/map/happyn_map.dart';

/// The Time Machine's stops: "now" (null), then the next three three-hour
/// marks that are at least an hour away, so 2:17 PM reads NOW · 6PM · 9PM ·
/// 12AM and 8:40 PM reads NOW · 12AM · 3AM · 6AM. Each stop is what the city
/// asks the API for with `starts_before`.
List<DateTime?> timeMachineStops(DateTime now) {
  var mark = DateTime(now.year, now.month, now.day, now.hour - now.hour % 3);
  final stops = <DateTime?>[null];
  while (stops.length < 4) {
    mark = mark.add(const Duration(hours: 3));
    if (mark.difference(now) >= const Duration(hours: 1)) stops.add(mark);
  }
  return stops;
}

/// "NOW", "6PM", "12AM": the slider's labels.
String stopLabel(DateTime? stop) {
  if (stop == null) return 'NOW';
  final hour = stop.hour % 12 == 0 ? 12 : stop.hour % 12;
  return '$hour${stop.hour < 12 ? 'AM' : 'PM'}';
}

/// The city is lit for the hour being looked at, not the hour it is.
MapLight lightAt(DateTime time) =>
    time.hour >= 6 && time.hour < 18 ? MapLight.day : MapLight.night;
