import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Keeps the Supabase session in the platform keystore.
///
/// The session carries a refresh token, which is a long-lived credential: it
/// can mint access tokens until it is revoked. `supabase_flutter` persists to
/// shared preferences by default, which is plain, world-readable-on-root
/// storage; Keychain and the Android Keystore are where this belongs.
class SecureSessionStorage extends LocalStorage {
  const SecureSessionStorage();

  static const _key = 'happyn.supabase.session';
  // Android defaults to Keystore-backed AES/GCM in flutter_secure_storage 11,
  // so only iOS needs saying: first_unlock lets a token refresh survive a
  // background launch, which `whenUnlocked` would break.
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: _key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);
}
