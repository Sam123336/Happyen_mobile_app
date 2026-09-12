import 'package:flutter_test/flutter_test.dart';
import 'package:happyn_mobile/core/map/happyn_map.dart';
import 'package:happyn_mobile/features/city/domain/time_machine.dart';

void main() {
  test('offers the next three-hour marks that are at least an hour away', () {
    final afternoon = timeMachineStops(DateTime(2026, 9, 12, 14, 17));
    expect(afternoon.map(stopLabel), ['NOW', '6PM', '9PM', '12AM']);
    expect(afternoon[3], DateTime(2026, 9, 13, 0));

    final evening = timeMachineStops(DateTime(2026, 9, 12, 20, 40));
    expect(evening.map(stopLabel), ['NOW', '12AM', '3AM', '6AM']);

    // Exactly an hour away still counts as a stop.
    expect(timeMachineStops(DateTime(2026, 9, 12, 17)).map(stopLabel), [
      'NOW',
      '6PM',
      '9PM',
      '12AM',
    ]);
  });

  test('lights the city for the hour being looked at', () {
    expect(lightAt(DateTime(2026, 9, 12, 14)), MapLight.day);
    expect(lightAt(DateTime(2026, 9, 12, 18)), MapLight.night);
    expect(lightAt(DateTime(2026, 9, 13, 0)), MapLight.night);
    expect(lightAt(DateTime(2026, 9, 13, 6)), MapLight.day);
  });
}
