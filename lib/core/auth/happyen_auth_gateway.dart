import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/auth/auth_user.dart';

/// Happyen's own sign-in: `POST /v1/auth/otp/*`. The backend owns the code and
/// the session; this holds the refresh token and nothing else durable.
///
/// The access token lives in memory only. It expires in minutes, so persisting
/// it would add a stored credential without saving a round trip worth having.
/// The refresh token does persist, in the platform keystore, because it can
/// mint access tokens until revoked.
class HappyenAuthGateway implements AuthGateway {
  HappyenAuthGateway({
    required Uri baseUri,
    http.Client? httpClient,
    FlutterSecureStorage? storage,
  }) : _baseUri = baseUri,
       _http = httpClient ?? http.Client(),
       _storage = storage ?? _defaultStorage;

  // Android is Keystore-backed by default in flutter_secure_storage 11, so
  // only iOS needs saying: first_unlock lets a refresh survive a background
  // launch, which `whenUnlocked` would break.
  static const _defaultStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _refreshTokenKey = 'happyn.refresh_token';

  /// Refresh a little early, so a request never leaves with a token that
  /// expires while it is in flight.
  static const _clockSkew = Duration(seconds: 30);

  final Uri _baseUri;
  final http.Client _http;
  final FlutterSecureStorage _storage;
  final StreamController<AuthUser?> _users =
      StreamController<AuthUser?>.broadcast();

  String? _accessToken;
  DateTime? _accessExpiresAt;
  AuthUser? _currentUser;
  bool _restored = false;

  /// One refresh at a time. The backend rotates on every refresh and treats a
  /// replayed token as theft, revoking every session for the account — so two
  /// parallel refreshes would not merely race, they would sign the user out.
  Future<String>? _refreshInFlight;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield await _restore();
    yield* _users.stream;
  }

  @override
  Future<String> idToken({bool forceRefresh = false}) async {
    await _restore();

    final token = _accessToken;
    final expiry = _accessExpiresAt;
    if (!forceRefresh &&
        token != null &&
        expiry != null &&
        DateTime.now().isBefore(expiry.subtract(_clockSkew))) {
      return token;
    }
    return _refresh();
  }

  @override
  Future<void> requestOtp(String phoneE164) async {
    final response = await _post('/v1/auth/otp/request', {'phone': phoneE164});
    if (response.status == 429) {
      throw const AuthSessionException(
        'Too many codes requested for this number. Try again in a few minutes.',
      );
    }
    if (response.status >= 300) {
      throw AuthSessionException(_message(response));
    }
  }

  @override
  Future<void> verifyOtp({
    required String phoneE164,
    required String code,
  }) async {
    final response = await _post('/v1/auth/otp/verify', {
      'code': code,
      'localDate': _localDate(),
      'phone': phoneE164,
    });

    if (response.status == 401) {
      throw AuthSessionException(_message(response), isInvalidCode: true);
    }
    if (response.status >= 300) {
      throw AuthSessionException(_message(response));
    }

    final body = response.body;
    await _adopt(body);
    _currentUser = _mapUser(body['user'] as Map<String, dynamic>?);
    _restored = true;
    _users.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken != null) {
      // Best effort: the local session ends either way, and leaving a token
      // live on the server is worse than a failed call.
      try {
        await _post('/v1/auth/otp/logout', {'refreshToken': refreshToken});
      } on Object {
        // Ignored deliberately; see above.
      }
    }
    await _clear();
  }

  /// Reads the stored refresh token once per launch and turns it into a
  /// session. A token the server no longer accepts is simply a signed-out app.
  Future<AuthUser?> _restore() async {
    if (_restored) return _currentUser;
    _restored = true;

    if (await _storage.read(key: _refreshTokenKey) == null) return null;
    try {
      await _refresh();
    } on AuthSessionException {
      return null;
    }
    return _currentUser;
  }

  Future<String> _refresh() {
    return _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<String> _performRefresh() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      throw const AuthSessionException('Nobody is signed in');
    }

    final ({Map<String, dynamic> body, int status}) response;
    try {
      response = await _post('/v1/auth/otp/refresh', {
        'refreshToken': refreshToken,
      });
    } on AuthSessionException {
      rethrow;
    }

    if (response.status >= 300) {
      // A refused refresh is a real sign-out, not a blip: the token was
      // revoked, expired, or flagged as reused. Clear it rather than retry.
      await _clear();
      throw AuthSessionException(_message(response));
    }

    await _adopt(response.body);
    _currentUser ??= AuthUser(
      // The refresh response carries no profile; the token names the account
      // and `currentProfileProvider` fills in the rest.
      id: _subjectOf(_accessToken) ?? '',
      emailVerified: false,
    );
    return _accessToken!;
  }

  Future<void> _adopt(Map<String, dynamic> body) async {
    _accessToken = body['accessToken'] as String?;
    final expiresIn = body['expiresIn'] as int? ?? 900;
    _accessExpiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    final refreshToken = body['refreshToken'] as String?;
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> _clear() async {
    _accessToken = null;
    _accessExpiresAt = null;
    _currentUser = null;
    await _storage.delete(key: _refreshTokenKey);
    _users.add(null);
  }

  Future<({Map<String, dynamic> body, int status})> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final http.Response response;
    try {
      response = await _http.post(
        _baseUri.resolve(path),
        headers: const {
          'accept': 'application/json',
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } on Object {
      // A dead network is not a wrong code, and the raw SocketException text
      // is a stack trace wearing a sentence.
      throw const AuthSessionException(
        'We could not reach Happyen. Check your connection and try again.',
      );
    }

    final decoded = response.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(response.body);
    return (
      body: decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{},
      status: response.statusCode,
    );
  }

  String _message(({Map<String, dynamic> body, int status}) response) {
    final message = response.body['message'];
    return message is String && message.isNotEmpty
        ? message
        : 'Sign-in failed. Please try again.';
  }

  /// The day as the phone reckons it, which is what the streak counts.
  String _localDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Reads `sub` out of the access token. Signed, not encrypted, so the client
  /// can read its own claims; this only ever trusts it for the account id it
  /// was just handed.
  String? _subjectOf(String? token) {
    final parts = token?.split('.');
    if (parts == null || parts.length != 3) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final subject = payload is Map<String, dynamic> ? payload['sub'] : null;
      return subject is String && subject.isNotEmpty ? subject : null;
    } on Object {
      return null;
    }
  }

  AuthUser? _mapUser(Map<String, dynamic>? user) {
    if (user == null) return null;
    return AuthUser(
      id: user['userId'] as String? ?? '',
      displayName: _string(user['displayName']),
      email: _string(user['email']),
      emailVerified: user['emailVerified'] as bool? ?? false,
      phoneNumber: _string(user['phoneE164']),
      photoUrl: _string(user['avatarUrl']),
    );
  }

  String? _string(Object? value) =>
      value is String && value.isNotEmpty ? value : null;
}
