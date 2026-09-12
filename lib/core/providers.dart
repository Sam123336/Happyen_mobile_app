import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/auth/auth_user.dart';
import 'package:happyn_mobile/core/auth/supabase_auth_gateway.dart';
import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/features/events/data/events_repository.dart';
import 'package:happyn_mobile/features/events/domain/happyn_event.dart';
import 'package:happyn_mobile/features/places/data/places_repository.dart';
import 'package:happyn_mobile/features/places/domain/place.dart';
import 'package:happyn_mobile/features/profile/data/profile_repository.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';
import 'package:happyn_mobile/flavor.dart';

/// Riverpod retries a failed provider forever by default, which turns a failing
/// endpoint into a permanent spinner and an endless request loop. A server that
/// answered has given its answer, so only a transport failure is retried, once.
Duration? retryOnce(int retryCount, Object error) =>
    error is ApiException || retryCount > 0 ? null : const Duration(seconds: 1);

final authGatewayProvider = Provider<AuthGateway>((ref) {
  if (!hasSupabaseConfig) return const UnavailableAuthGateway();
  return SupabaseAuthGateway(supabase.Supabase.instance.client.auth);
});

final authUserProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authGatewayProvider).authStateChanges();
});

/// Defaults to dev so tests and a bare `flutter run` behave; each entrypoint
/// overrides it with its own flavor.
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.of(Flavor.dev),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUri: Uri.parse(ref.watch(appConfigProvider).apiOrigin),
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

/// City-map event data stays fresh without holding a socket open for every
/// visible map. The backend computes live status at request time, so a short
/// polling interval is enough for an event to turn on/off while the user is
/// looking at the city.
const liveEventRefreshInterval = Duration(seconds: 30);

/// What the city is asking for: one category chip and one Time Machine stop.
/// [until] is null for "now"; otherwise only occurrences starting by then.
typedef NearbyQuery = ({EventCategory? category, DateTime? until});

/// Upcoming occurrences around the search centre for [query]. Keyed by the
/// record, so a chip or a slider stop is a new request. Rebuilding this
/// provider every [liveEventRefreshInterval] also refreshes active events.
final nearbyEventsProvider = FutureProvider.autoDispose
    .family<List<HappynEvent>, NearbyQuery>((ref, query) async {
      final refresh = Timer.periodic(
        liveEventRefreshInterval,
        (_) => ref.invalidateSelf(),
      );
      ref.onDispose(refresh.cancel);
      // Events are protected by ProvisionedUserGuard. Creating the session
      // first maps a valid Supabase identity to its internal account, avoiding
      // the first-city-load race where an otherwise valid token gets a 403.
      final profile = await ref.watch(currentProfileProvider.future);
      if (profile == null) return const <HappynEvent>[];
      final centre = await ref.watch(searchCentreProvider.future);
      return ref
          .watch(eventsRepositoryProvider)
          .nearby(
            category: query.category,
            latitude: centre.latitude,
            longitude: centre.longitude,
            startsBefore: query.until,
          );
    });
