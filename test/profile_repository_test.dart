import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/profile/data/profile_repository.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'creates a session with a bearer token and parses privacy defaults',
    () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'avatarUrl': null,
            'bio': null,
            'displayName': 'City Explorer',
            'email': 'person@example.com',
            'emailVerified': true,
            'momentsVisibility': 'friends',
            'phoneE164': null,
            'presenceVisibility': 'nobody',
            'profileVisibility': 'everyone',
            'status': 'active',
            'userId': 'user-1',
            'username': null,
          }),
          201,
        );
      });
      final repository = ProfileRepository(
        ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          accessToken: () async => 'firebase-token',
          httpClient: client,
        ),
      );

      final profile = await repository.createSession();

      expect(captured.url.path, '/v1/auth/session');
      expect(captured.headers['authorization'], 'Bearer firebase-token');
      expect(profile.presenceVisibility, PrivacyAudience.nobody);
      expect(profile.momentsVisibility, PrivacyAudience.friends);
    },
  );
}
