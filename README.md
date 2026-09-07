# Happyn Mobile

The Flutter client uses a feature-oriented structure with Riverpod. Phase 2 adds an `AuthGateway` boundary, its Firebase implementation, bearer-authenticated API transport, an idempotent session bootstrap provider, and typed profile/privacy models. These pieces can be overridden with fakes in tests and do not initialize Firebase merely by rendering the application shell.

Set the API origin at build time with `--dart-define=HAPPYN_API_ORIGIN=https://...`.

## Screens on live data

Search runs `GET /v1/places/search` as you type (350ms debounce; the quick
filters are search terms), and the profile identity reads the account returned by
`POST /v1/auth/session`. Every other screen still renders its designed
placeholder because the endpoint behind it does not exist yet.

Both fall back to that placeholder state when the API is unreachable, so the app
runs without Firebase configured — but no authenticated call can succeed until
`Firebase.initializeApp()` is called with real `google-services.json` /
`GoogleService-Info.plist` files. Until then the API answers `401`.

`ProviderScope` is created with `retry: retryOnce`: Riverpod 3 otherwise retries
a failed provider forever, which turns an unreachable API into a permanent
spinner and an endless request loop.

Search is centred on the device position (`geolocator`, when-in-use). A refused
permission, a disabled location service or a slow fix all fall back to
Bengaluru's centre rather than failing, so the screen is never empty.

Foursquare's API licence requires "Powered by Foursquare" on every screen where
their Places Data appears, so any new screen that shows places must carry it
too. The same licence limits caching of Places Data, so do not add a cache
without checking the limits for the account type.

## The map

Both city screens render `HappynMap`, which wraps `mapbox_maps_flutter` and is
the only file allowed to name Mapbox types (ADR 002). The camera carries the
Stitch diorama's own angles: `rotateX(60deg) rotateZ(-30deg)` is pitch 60 and
bearing -30. Day and night are one map under two `lightPreset` values, not two
maps.

Supply the public token at build time:

    flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token

Without it `HappynMap` renders the designed diorama instead, so the app still
runs and the tests stay hermetic.

Native builds need nothing extra on Android: the plugin's Gradle authenticates
only Mapbox's *snapshots* repository (`SDK_REGISTRY_TOKEN`), and release
artifacts come from the public one. iOS pulls `MapboxMaps 11.30.0` through
CocoaPods, which per Mapbox's install guide wants a `~/.netrc` secret token.

Mapbox's terms require their logo and attribution control to stay visible. Both
are SDK defaults here — do not disable them while tidying the map UI.

The city screens draw pins from `GET /v1/events/nearby` for the selected
category chip; tapping one selects it and the centre diorama shows that event.
Two of the diorama's slots stay honest rather than filled: the orbiting
avatars are empty because friend presence has no endpoint, and the energy pill
carries the category because Live Energy is server-owned and does not exist yet.

Pins need seeded events — run `pnpm db:seed` in the backend.

## Native runners

The iOS and Android runner projects use the placeholder identifier `com.happyen.app` on both platforms so the app can be run locally. Confirm the final application/bundle identifier before registering Firebase apps or configuring signing, and change it in three places:

- `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`)
- `android/app/build.gradle.kts` (`namespace` and `applicationId`)
- `android/app/src/main/kotlin/.../MainActivity.kt` (package declaration and directory)

The iOS deployment target is 15.0, the minimum required by `firebase_core`. Neither `GoogleService-Info.plist` nor `google-services.json` is committed; the app builds and runs without them because nothing calls `Firebase.initializeApp()` at startup.
