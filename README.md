# Happyn Mobile

The Flutter client uses a feature-oriented structure with Riverpod. Phase 2 adds an `AuthGateway` boundary, its Firebase implementation, bearer-authenticated API transport, an idempotent session bootstrap provider, and typed profile/privacy models. These pieces can be overridden with fakes in tests and do not initialize Firebase merely by rendering the application shell.

## Flavors

Two flavors, `dev` and `prod`, differing only in where the app points and what
it is called. `lib/flavor.dart` holds both, next to the entrypoints that
pick one:

    flutter run --flavor dev  -t lib/main_dev.dart
    flutter run --flavor prod -t lib/main_prod.dart

`flutter run` with no entrypoint gets dev, so prod is never the accident.

On Android the two install side by side: `dev` carries a `.dev` application-id
suffix and shows as "Happyen Dev". **On iOS `--flavor` does not work yet** —
that needs `dev`/`prod` Xcode schemes and six build configurations, which is
Xcode project surgery nobody has done. Until then run iOS with the entrypoint
alone (`flutter run -t lib/main_dev.dart`): the API origin and app title are
still right, only the bundle id and launcher name are shared.

`--dart-define=HAPPYN_API_ORIGIN=...` overrides whichever flavor is running,
for pointing a build at a laptop on the LAN or a preview deployment.

### Reaching a local backend

`.vscode/launch.json` carries these as Run and Debug entries. `localhost` means
something different on each target, so:

- **Android emulator** — use the "Android emulator" entry; the emulator sees the
  host at `10.0.2.2`, never `localhost`.
- **Physical Android, USB or wireless** — `adb reverse tcp:3000 tcp:3000` once
  per connection, then the plain "Happyen Dev" entry works as-is. For wireless,
  pair first with `adb pair <host>:<port>` and `adb connect <host>:<port>` from
  the phone's Wireless debugging screen; re-run `adb reverse` after connecting,
  because it is per-connection.
- **iOS simulator** — `localhost` is the host already, so nothing is needed.

## Screens on live data

Search runs `GET /v1/places/search` as you type (350ms debounce; the quick
filters are search terms), the profile identity reads the account returned by
`POST /v1/auth/session`, and City draws `GET /v1/events/nearby` on the map.
The event provider polls every 30 seconds while the city screen is mounted, so
the backend's `isLive` status changes without making the user reopen the app.
Other social/detail content still renders its designed placeholder where an
endpoint does not exist yet.

Both fall back to that placeholder state when the API is unreachable. Startup
initializes Firebase when real `google-services.json` / `GoogleService-Info.plist`
files are installed, but intentionally keeps the design shell available without
them. Until those project credentials are installed and a user signs in, the
authenticated API answers `401`.

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
category chip; tapping one selects it and the centre diorama/detail view shows
that API occurrence. The same portable GeoJSON event data creates Mapbox
fill-extrusion beacons: coral, taller beacons are live; violet, shorter beacons
are scheduled. The standard basemap's pitched 3D buildings remain visible
behind them. The API is polled every 30 seconds instead of opening a socket for
every map, which suits the Vercel deployment model.

Two of the diorama's slots stay honest rather than filled: orbiting avatars are
empty because friend presence has no endpoint, and the app reports `LIVE NOW`
rather than inventing an attendance/energy score.

Pins need seeded events — run `pnpm db:seed` in the backend.

## Native runners

The iOS and Android runner projects use the placeholder identifier `com.happyen.app` on both platforms so the app can be run locally. Confirm the final application/bundle identifier before registering Firebase apps or configuring signing, and change it in three places:

- `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`)
- `android/app/build.gradle.kts` (`namespace` and `applicationId`)
- `android/app/src/main/kotlin/.../MainActivity.kt` (package declaration and directory)

The iOS deployment target is 15.0, the minimum required by `firebase_core`. Neither `GoogleService-Info.plist` nor `google-services.json` is committed; the app builds and runs without them because nothing calls `Firebase.initializeApp()` at startup.
