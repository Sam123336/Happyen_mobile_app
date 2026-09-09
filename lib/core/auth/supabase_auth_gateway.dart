import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/auth/auth_user.dart';

/// Supabase Auth behind [AuthGateway].
///
/// Supabase owns the credential — the phone number and the code sent to it —
/// and nothing else. The account itself, its username, profile and privacy,
/// lives in Happyen's own tables; the backend maps this identity onto that
/// account by the token's subject.
class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._auth);

  final supabase.GoTrueClient _auth;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    // onAuthStateChange only reports transitions, so a session restored from
    // storage before this stream is listened to would never be announced.
    yield _mapUser(_auth.currentSession?.user);
    yield* _auth.onAuthStateChange.map((state) => _mapUser(state.session?.user));
  }

  @override
  Future<String> idToken({bool forceRefresh = false}) async {
    var session = _auth.currentSession;
    if (session == null) {
      throw const AuthSessionException('Nobody is signed in');
    }

    if (forceRefresh || session.isExpired) {
      try {
        session = (await _auth.refreshSession()).session;
      } on supabase.AuthException catch (error) {
        // A refresh token that no longer works is a real sign-out, not a
        // transient failure: let the caller send the user back to sign-in.
        throw AuthSessionException(error.message);
      }
    }

    final token = session?.accessToken;
    if (token == null || token.isEmpty) {
      throw const AuthSessionException('The session carries no access token');
    }
    return token;
  }

  @override
  Future<void> requestOtp(String phoneE164) async {
    try {
      await _auth.signInWithOtp(phone: phoneE164);
    } on supabase.AuthException catch (error) {
      throw AuthSessionException(error.message);
    }
  }

  @override
  Future<void> verifyOtp({
    required String phoneE164,
    required String code,
  }) async {
    try {
      await _auth.verifyOTP(
        phone: phoneE164,
        token: code,
        type: supabase.OtpType.sms,
      );
    } on supabase.AuthException catch (error) {
      throw AuthSessionException(error.message, isInvalidCode: true);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AuthUser? _mapUser(supabase.User? user) {
    if (user == null) return null;
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    return AuthUser(
      id: user.id,
      displayName: _string(metadata['full_name']) ?? _string(metadata['name']),
      email: user.email,
      emailVerified: user.emailConfirmedAt != null,
      phoneNumber: _e164(user.phone),
      photoUrl: _string(metadata['avatar_url']),
    );
  }

  /// Supabase returns the phone as bare digits; the rest of the app uses E.164.
  String? _e164(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    return phone.startsWith('+') ? phone : '+$phone';
  }

  String? _string(Object? value) =>
      value is String && value.isNotEmpty ? value : null;
}

/// Keeps the map and the design shell usable before Supabase is configured.
/// It has no identity, so protected requests stay disabled until
/// SUPABASE_URL and SUPABASE_ANON_KEY are supplied at build time.
class UnavailableAuthGateway implements AuthGateway {
  const UnavailableAuthGateway();

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(null);

  @override
  Future<String> idToken({bool forceRefresh = false}) async {
    throw const AuthSessionException('Supabase is not configured');
  }

  @override
  Future<void> requestOtp(String phoneE164) async {
    throw const AuthSessionException('Supabase is not configured');
  }

  @override
  Future<void> verifyOtp({
    required String phoneE164,
    required String code,
  }) async {
    throw const AuthSessionException('Supabase is not configured');
  }

  @override
  Future<void> signOut() async {}
}
