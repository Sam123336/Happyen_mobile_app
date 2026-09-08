import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/shell/presentation/app_shell.dart';
import 'package:happyn_mobile/flavor.dart';

/// `flutter run` with no entrypoint gets dev. Prod is never the accident.
Future<void> main() => bootstrap(Flavor.dev);

/// Shared by both flavor entrypoints: the only difference between them is the
/// [AppConfig] the tree is built with.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  // The native Firebase files are environment-owned and deliberately do not
  // live in source control. Initialise when they are present so the bearer
  // client can exchange a real Firebase ID token with the backend; retaining
  // the visual fallback keeps design/test builds usable before that setup.
  try {
    await Firebase.initializeApp();
  } on FirebaseException {
    // Authenticated requests surface their own recoverable error until Firebase
    // is configured. Do not make the city/map shell unavailable because a
    // developer has not installed local Firebase credentials yet.
  }
  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(AppConfig.of(flavor))],
      retry: retryOnce,
      child: const HappynApp(),
    ),
  );
}

class HappynApp extends ConsumerWidget {
  const HappynApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
      theme: buildHappynTheme(),
      title: config.appName,
    );
  }
}
