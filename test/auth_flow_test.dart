import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/auth/auth_user.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/features/auth/presentation/auth_controller.dart';

class _FakeGateway implements AuthGateway {
  _FakeGateway({this.failVerify = false, this.failRequest = false});

  final bool failRequest;
  final bool failVerify;
  final requested = <String>[];
  final verified = <(String, String)>[];

  @override
  Stream<AuthUser?> authStateChanges() => const Stream.empty();

  @override
  Future<String> idToken({bool forceRefresh = false}) async => 'token';

  @override
  Future<void> requestOtp(String phoneE164) async {
    requested.add(phoneE164);
    if (failRequest) {
      throw const AuthSessionException('SMS provider rejected the number');
    }
  }

  @override
  Future<void> verifyOtp({
    required String phoneE164,
    required String code,
  }) async {
    verified.add((phoneE164, code));
    if (failVerify) {
      throw const AuthSessionException('Token has expired', isInvalidCode: true);
    }
  }

  @override
  Future<void> signOut() async {}
}

ProviderContainer _containerWith(_FakeGateway gateway) {
  final container = ProviderContainer(
    overrides: [authGatewayProvider.overrideWithValue(gateway)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('a sent code advances to the code step and remembers the number', () async {
    final gateway = _FakeGateway();
    final container = _containerWith(gateway);

    await container.read(authFlowProvider.notifier).requestCode('+919876543210');

    expect(gateway.requested, ['+919876543210']);
    expect(container.read(authFlowProvider).step, AuthStep.code);
    expect(container.read(authFlowProvider).phoneE164, '+919876543210');
    expect(container.read(authFlowProvider).busy, isFalse);
  });

  test('a refused number keeps the user on the phone step with the reason', () async {
    final container = _containerWith(_FakeGateway(failRequest: true));

    await container.read(authFlowProvider.notifier).requestCode('+911');

    final state = container.read(authFlowProvider);
    expect(state.step, AuthStep.phone);
    expect(state.error, contains('rejected'));
    expect(state.busy, isFalse);
  });

  test('a wrong code is reported in words the user can act on', () async {
    final container = _containerWith(_FakeGateway(failVerify: true));
    final flow = container.read(authFlowProvider.notifier);

    await flow.requestCode('+919876543210');
    await flow.submitCode('000000');

    // Not the provider's "Token has expired", which reads as a bug report.
    expect(container.read(authFlowProvider).error, contains('not right'));
    expect(container.read(authFlowProvider).step, AuthStep.code);
  });

  test('the code is verified against the number the code was sent to', () async {
    final gateway = _FakeGateway();
    final container = _containerWith(gateway);
    final flow = container.read(authFlowProvider.notifier);

    await flow.requestCode('+919876543210');
    await flow.submitCode('123456');

    expect(gateway.verified, [('+919876543210', '123456')]);
  });

  test('resend reuses the number, and editing goes back without losing it', () async {
    final gateway = _FakeGateway();
    final container = _containerWith(gateway);
    final flow = container.read(authFlowProvider.notifier);

    await flow.requestCode('+919876543210');
    await flow.resendCode();
    expect(gateway.requested, ['+919876543210', '+919876543210']);

    flow.editPhone();
    expect(container.read(authFlowProvider).step, AuthStep.phone);
    expect(container.read(authFlowProvider).phoneE164, '+919876543210');
  });
}
