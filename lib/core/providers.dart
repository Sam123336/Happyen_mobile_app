import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/auth/auth_user.dart';
import 'package:happyn_mobile/core/auth/firebase_auth_gateway.dart';
import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/events/data/events_repository.dart';
import 'package:happyn_mobile/features/events/domain/happyn_event.dart';
import 'package:happyn_mobile/features/places/data/places_repository.dart';
import 'package:happyn_mobile/features/places/domain/place.dart';
import 'package:happyn_mobile/features/profile/data/profile_repository.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';

/// Riverpod retries a failed provider forever by default, which turns a failing
/// endpoint into a permanent spinner and an endless request loop. A server that
/// answered has given its answer, so only a transport failure is retried, once.
Duration? retryOnce(int retryCount, Object error) =>
    error is ApiException || retryCount > 0 ? null : const Duration(seconds: 1);

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

final placesRepositoryProvider = Provider<PlacesRepository>(
  (ref) => PlacesRepository(ref.watch(apiClientProvider)),
);

typedef Coordinates = ({double latitude, double longitude});

/// Where the city is until the device says otherwise, and the launch city.
const bengaluruCentre = (latitude: 12.9716, longitude: 77.5946);

/// The point place search is centred on. A refused permission, a disabled
/// location service or a slow fix is not an error here: the city centre still
/// gives a usable map, so every failure falls back rather than propagating.
final searchCentreProvider = FutureProvider<Coordinates>((ref) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return bengaluruCentre;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return bengaluruCentre;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: Duration(seconds: 5)),
    );
    return (latitude: position.latitude, longitude: position.longitude);
  } on Object {
    return bengaluruCentre;
  }
});

/// Venue search for [query]. An empty query returns what is simply nearby.
final placeSearchProvider = FutureProvider.autoDispose
    .family<List<Place>, String>((ref, query) async {
      final centre = await ref.watch(searchCentreProvider.future);
      return ref
          .watch(placesRepositoryProvider)
          .search(
            latitude: centre.latitude,
            limit: 12,
            longitude: centre.longitude,
            query: query,
          );
    });

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepository(ref.watch(apiClientProvider)),
);

/// Upcoming occurrences around the search centre, optionally one category.
/// Keyed by category so switching a filter chip is a new request, not a refetch
/// of everything.
final nearbyEventsProvider = FutureProvider.autoDispose
    .family<List<HappynEvent>, EventCategory?>((ref, category) async {
      final centre = await ref.watch(searchCentreProvider.future);
      return ref
          .watch(eventsRepositoryProvider)
          .nearby(
            category: category,
            latitude: centre.latitude,
            longitude: centre.longitude,
          );
    });
