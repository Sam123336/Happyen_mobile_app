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
them — the map needs no Firebase at all.

There is no sign-in screen yet, so `authUserProvider` signs in **anonymously**
the first time it sees a signed-out app. That is what gets the city its data:
every protected endpoint needs a Firebase identity, and without one the event
list is empty and no request is ever sent. Firebase keeps the anonymous account
across launches, and a real sign-in later upgrades it rather than replacing it.
The attempt is made once per gateway, so an unconfigured Firebase or a project
with the anonymous provider switched off leaves the app signed out instead of
retrying forever.

That means events need exactly two things:

1. `android/app/google-services.json` (and/or `ios/Runner/GoogleService-Info.plist`)
   downloaded from the Firebase project named by the backend's
   `FIREBASE_PROJECT_ID`. Both are gitignored. `android/app/build.gradle.kts`
   applies the `google-services` plugin only when that file exists, so Firebase
   wires itself up as soon as you drop it in and the build keeps working — map
   included — while it is absent.
2. **Anonymous** enabled under Firebase console → Authentication → Sign-in
   method. Without it Firebase returns `admin-restricted-operation` and the app
   stays signed out.

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

Both city screens render `HappynMap`, which wraps `maplibre_gl` and is the only
file allowed to name MapLibre types (ADR 002). That boundary is what let the
basemap move off Mapbox in one file. The camera carries the Stitch diorama's
own angles: `rotateX(60deg) rotateZ(-30deg)` is tilt 60 and bearing -30. Day
and night are two OpenFreeMap styles — `liberty` and `dark` — swapped on the
same map, not two maps.

Nothing is needed at build time. Tiles come from OpenFreeMap's public instance,
which has no registration, no API key and no card on file, so `flutter run`
alone gives you the real map:

    flutter run -t lib/main_dev.dart

MapLibre is open source, so native builds need no secret Maven or CocoaPods
credentials either — which is the other reason the basemap is no longer Mapbox.

OpenFreeMap's terms require the attribution `OpenFreeMap © OpenMapTiles Data
from OpenStreetMap`, which `HappynMap` renders over every map. Do not remove it
while tidying the map UI. Its public instance is donation-funded and carries no
SLA; it is built to be self-hosted if that ever matters.

Widget tests have no platform views, so `HappynMap` renders the screen's
`fallback` diorama under `FLUTTER_TEST` and the tests stay hermetic.

The city screens draw pins from `GET /v1/events/nearby` for the selected
category chip; tapping one selects it and the centre diorama/detail view shows
that API occurrence. The same portable GeoJSON event data creates
fill-extrusion beacons: coral, taller beacons are live; violet, shorter beacons
are scheduled. The Liberty basemap's pitched 3D buildings remain visible
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

The iOS deployment target is 15.0, the minimum required by `firebase_core`. Neither `GoogleService-Info.plist` nor `google-services.json` is committed, and both are gitignored; the app builds and runs without them, because `bootstrap` treats a failed `Firebase.initializeApp()` as a recoverable condition and the Android Gradle build only applies the `google-services` plugin when the file is actually present.
