import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  Future<UserProfile> createSession() async =>
      UserProfile.fromJson(await _api.post('/v1/auth/session'));

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
