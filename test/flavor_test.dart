import 'package:flutter_test/flutter_test.dart';
import 'package:happyn_mobile/flavor.dart';

void main() {
  test('dev and uat talk to a local backend, prod to the deployment', () {
    expect(AppConfig.of(Flavor.dev).apiOrigin, 'http://localhost:3000');
    expect(AppConfig.of(Flavor.uat).apiOrigin, 'http://localhost:3000');
    expect(AppConfig.of(Flavor.prod).apiOrigin, startsWith('https://'));
  });

  test('the three builds are named apart in the app switcher', () {
    expect(AppConfig.of(Flavor.dev).appName, 'Happyen Dev');
    expect(AppConfig.of(Flavor.uat).appName, 'Happyen UAT');
    expect(AppConfig.of(Flavor.prod).appName, 'Happyen');
  });

  test('only dev reports itself as dev', () {
    expect(AppConfig.of(Flavor.dev).isDev, isTrue);
    expect(AppConfig.of(Flavor.uat).isDev, isFalse);
    expect(AppConfig.of(Flavor.prod).isDev, isFalse);
  });
}
