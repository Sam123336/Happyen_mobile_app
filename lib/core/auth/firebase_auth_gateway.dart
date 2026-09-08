import 'package:firebase_auth/firebase_auth.dart';

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/auth/auth_user.dart';

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_mapUser);

  @override
  Future<String> idToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthSessionException('No authenticated Firebase user');
    }
    final token = await user.getIdToken(forceRefresh);
    if (token == null || token.isEmpty) {
      throw const AuthSessionException('Firebase did not return an ID token');
    }
    return token;
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      displayName: user.displayName,
      email: user.email,
      emailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
    );
  }
}

/// Keeps the map/design shell usable before a developer has installed the
/// environment-owned Firebase configuration. It intentionally has no identity:
/// protected backend requests remain disabled until Firebase is configured and
/// a real user signs in.
class UnavailableAuthGateway implements AuthGateway {
  const UnavailableAuthGateway();

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(null);

  @override
  Future<String> idToken({bool forceRefresh = false}) async {
    throw const AuthSessionException('Firebase is not configured');
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    throw const AuthSessionException('Firebase is not configured');
  }

  @override
  Future<void> signOut() async {}
}

class AuthSessionException implements Exception {
  const AuthSessionException(this.message);

  final String message;

  @override
  String toString() => 'AuthSessionException: $message';
}
