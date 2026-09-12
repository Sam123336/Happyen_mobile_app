import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  /// Opens the account for this device, which also counts as opening the city
  /// today for the streak. The day is the phone's own, not the server's.
  Future<UserProfile> createSession({DateTime? now}) async =>
      UserProfile.fromJson(
        await _api.post('/v1/auth/session', {
          'localDate': isoDay(now ?? DateTime.now()),
        }),
      );

  /// Whether [username] is still free. Advisory: the claim in [updateProfile]
  /// is what actually decides, and answers 409 if someone got there first.
  Future<bool> isUsernameAvailable(String username) async {
    final result = await _api.get(
      '/v1/me/username-available',
      query: {'username': username},
    );
    return result['available'] as bool;
  }

  Future<UserProfile> load() async =>
      UserProfile.fromJson(await _api.get('/v1/me/profile'));

  Future<UserProfile> updateProfile({
    String? bio,
    String? displayName,
    String? username,
  }) async {
    final body = <String, dynamic>{};
    if (bio != null) body['bio'] = bio;
    if (displayName != null) body['displayName'] = displayName;
    if (username != null) body['username'] = username;
    return UserProfile.fromJson(await _api.patch('/v1/me/profile', body));
  }

  Future<UserProfile> updatePrivacy({
    PrivacyAudience? moments,
    PrivacyAudience? presence,
    PrivacyAudience? profile,
  }) async => UserProfile.fromJson(
    await _api.patch('/v1/me/privacy', {
      if (moments != null) 'momentsVisibility': moments.name,
      if (presence != null) 'presenceVisibility': presence.name,
      if (profile != null) 'profileVisibility': profile.name,
    }),
  );
}

/// `YYYY-MM-DD` in the device's own calendar, the form the streak API reads.
String isoDay(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-${two(date.month)}-${two(date.day)}';
}
