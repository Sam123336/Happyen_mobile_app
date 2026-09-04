import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/auth/auth_user.dart';
import 'package:happyn_mobile/core/auth/firebase_auth_gateway.dart';
import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/profile/data/profile_repository.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';

final authGatewayProvider = Provider<AuthGateway>(
  (ref) => FirebaseAuthGateway(FirebaseAuth.instance),
);

final authUserProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authGatewayProvider).authStateChanges();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  const apiOrigin = String.fromEnvironment(
    'HAPPYN_API_ORIGIN',
    defaultValue: 'http://localhost:3000',
  );
  return ApiClient(
    baseUri: Uri.parse(apiOrigin),
    accessToken: () => ref.read(authGatewayProvider).idToken(),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);

final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authUser = await ref.watch(authUserProvider.future);
  if (authUser == null) return null;
  return ref.watch(profileRepositoryProvider).createSession();
});
