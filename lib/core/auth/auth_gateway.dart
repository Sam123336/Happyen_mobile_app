import 'package:happyn_mobile/core/auth/auth_user.dart';

/// How Happyen signs people in: a phone number, a code sent to it, nothing
/// else. The screens never see the identity provider behind this.
abstract interface class AuthGateway {
  Stream<AuthUser?> authStateChanges();

  /// A valid access token for the backend, refreshed if the current one has
  /// expired. Throws [AuthSessionException] when nobody is signed in.
  Future<String> idToken({bool forceRefresh = false});

  /// Sends a one-time code to [phoneE164]. The same call both registers a new
  /// number and signs an existing one back in — the provider decides which,
  /// so the app never has to ask "do you already have an account?".
  Future<void> requestOtp(String phoneE164);

  /// Exchanges [code] for a session. Throws [AuthSessionException] when the
  /// code is wrong or has expired.
  Future<void> verifyOtp({required String phoneE164, required String code});

  Future<void> signOut();
}

class AuthSessionException implements Exception {
  const AuthSessionException(this.message, {this.isInvalidCode = false});

  /// Lets the OTP screen say "that code is wrong" rather than "something went
  /// wrong", without every screen parsing provider error strings.
  final bool isInvalidCode;
  final String message;

  @override
  String toString() => 'AuthSessionException: $message';
}
