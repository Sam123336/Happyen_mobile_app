import 'package:happyn_mobile/core/auth/auth_user.dart';

abstract interface class AuthGateway {
  Stream<AuthUser?> authStateChanges();

  Future<String> idToken({bool forceRefresh = false});

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
