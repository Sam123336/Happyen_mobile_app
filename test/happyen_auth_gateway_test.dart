import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/auth/happyen_auth_gateway.dart';

const phone = '+919876543210';

/// Records every request and answers from [replies], keyed by path.
({List<String> paths, MockClient client}) stubBackend(
  Map<String, (int, Map<String, dynamic>)> replies,
) {
  final paths = <String>[];
  final client = MockClient((request) async {
    paths.add(request.url.path);
    final reply = replies[request.url.path] ?? (404, <String, dynamic>{});
    return http.Response(
      jsonEncode(reply.$2),
      reply.$1,
      headers: const {'content-type': 'application/json'},
    );
  });
  return (paths: paths, client: client);
}

HappyenAuthGateway gatewayWith(MockClient client) => HappyenAuthGateway(
  baseUri: Uri.parse('http://localhost:3000'),
  httpClient: client,
);

/// A token the gateway can read a subject out of. Signed tokens are readable
/// by anyone holding them, which is exactly why the app may parse its own.
String accessTokenFor(String userId) {
  String segment(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${segment({'alg': 'EdDSA'})}.${segment({'sub': userId})}.signature';
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('requests a code from the backend, not an identity provider', () async {
    final backend = stubBackend({
      '/v1/auth/otp/request': (202, {'status': 'sent'}),
    });

    await gatewayWith(backend.client).requestOtp(phone);

    expect(backend.paths, ['/v1/auth/otp/request']);
  });

  test('explains a rate-limited number instead of failing silently', () async {
    final backend = stubBackend({
      '/v1/auth/otp/request': (429, {'code': 'otp_rate_limited'}),
    });

    await expectLater(
      gatewayWith(backend.client).requestOtp(phone),
      throwsA(
        isA<AuthSessionException>().having(
          (e) => e.message,
          'message',
          contains('Too many codes'),
        ),
      ),
    );
  });

  test('verifying a code keeps the session and announces the user', () async {
    final backend = stubBackend({
      '/v1/auth/otp/verify': (
        201,
        {
          'accessToken': accessTokenFor('user-1'),
          'expiresIn': 900,
          'refreshToken': 'refresh-1',
          'user': {
            'displayName': 'City Explorer',
            'emailVerified': false,
            'phoneE164': phone,
            'userId': 'user-1',
          },
        },
      ),
    });
    final gateway = gatewayWith(backend.client);

    await gateway.verifyOtp(phoneE164: phone, code: '123456');

    expect(await gateway.idToken(), accessTokenFor('user-1'));
    // The refresh token is the durable credential and belongs in the keystore.
    expect(
      await const FlutterSecureStorage().read(key: 'happyn.refresh_token'),
      'refresh-1',
    );
    await expectLater(gateway.authStateChanges(), emits(isNotNull));
  });

  test('a wrong code is reported as a wrong code, not a failure', () async {
    final backend = stubBackend({
      '/v1/auth/otp/verify': (
        401,
        {'code': 'otp_mismatch', 'message': 'That code is not valid'},
      ),
    });

    await expectLater(
      gatewayWith(backend.client).verifyOtp(phoneE164: phone, code: '000000'),
      throwsA(
        isA<AuthSessionException>().having(
          (e) => e.isInvalidCode,
          'isInvalidCode',
          isTrue,
        ),
      ),
    );
  });

  test('refreshes once for concurrent callers, never twice', () async {
    FlutterSecureStorage.setMockInitialValues({
      'happyn.refresh_token': 'refresh-1',
    });
    final backend = stubBackend({
      '/v1/auth/otp/refresh': (
        201,
        {
          'accessToken': accessTokenFor('user-1'),
          'expiresIn': 900,
          'refreshToken': 'refresh-2',
        },
      ),
    });
    final gateway = gatewayWith(backend.client);

    await Future.wait([
      gateway.idToken(forceRefresh: true),
      gateway.idToken(forceRefresh: true),
      gateway.idToken(forceRefresh: true),
    ]);

    // The backend rotates on every refresh and treats a replayed token as
    // theft, revoking the account's sessions. Three parallel refreshes would
    // not race, they would sign the user out.
    expect(backend.paths.where((p) => p.endsWith('/refresh')).length, 1);
  });

  test('a refused refresh ends the session rather than retrying', () async {
    FlutterSecureStorage.setMockInitialValues({
      'happyn.refresh_token': 'stolen',
    });
    final backend = stubBackend({
      '/v1/auth/otp/refresh': (401, {'code': 'refresh_reused'}),
    });
    final gateway = gatewayWith(backend.client);

    await expectLater(gateway.idToken(), throwsA(isA<AuthSessionException>()));
    expect(
      await const FlutterSecureStorage().read(key: 'happyn.refresh_token'),
      isNull,
    );
  });

  test('signing out tells the backend and clears the keystore', () async {
    FlutterSecureStorage.setMockInitialValues({
      'happyn.refresh_token': 'refresh-1',
    });
    final backend = stubBackend({
      '/v1/auth/otp/logout': (204, <String, dynamic>{}),
    });

    await gatewayWith(backend.client).signOut();

    expect(backend.paths, contains('/v1/auth/otp/logout'));
    expect(
      await const FlutterSecureStorage().read(key: 'happyn.refresh_token'),
      isNull,
    );
  });

  test('nobody signed in means no token, not an empty one', () async {
    final backend = stubBackend({});

    await expectLater(
      gatewayWith(backend.client).idToken(),
      throwsA(isA<AuthSessionException>()),
    );
  });
}
