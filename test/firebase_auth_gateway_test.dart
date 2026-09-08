import 'package:flutter_test/flutter_test.dart';
import 'package:happyn_mobile/core/auth/firebase_auth_gateway.dart';

void main() {
  test('unconfigured Firebase gateway stays signed out', () async {
    const gateway = UnavailableAuthGateway();

    expect(await gateway.authStateChanges().first, isNull);
    await expectLater(gateway.idToken(), throwsA(isA<AuthSessionException>()));
  });
}
