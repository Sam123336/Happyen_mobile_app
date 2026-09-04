# Happyn Mobile

The Flutter client uses a feature-oriented structure with Riverpod. Phase 2 adds an `AuthGateway` boundary, its Firebase implementation, bearer-authenticated API transport, an idempotent session bootstrap provider, and typed profile/privacy models. These pieces can be overridden with fakes in tests and do not initialize Firebase merely by rendering the application shell.

Set the API origin at build time with `--dart-define=HAPPYN_API_ORIGIN=https://...`.

## Native runners

The iOS and Android runner projects use the placeholder identifier `com.happyen.app` on both platforms so the app can be run locally. Confirm the final application/bundle identifier before registering Firebase apps or configuring signing, and change it in three places:

- `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`)
- `android/app/build.gradle.kts` (`namespace` and `applicationId`)
- `android/app/src/main/kotlin/.../MainActivity.kt` (package declaration and directory)

The iOS deployment target is 15.0, the minimum required by `firebase_core`. Neither `GoogleService-Info.plist` nor `google-services.json` is committed; the app builds and runs without them because nothing calls `Firebase.initializeApp()` at startup.
