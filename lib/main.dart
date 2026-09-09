import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:happyn_mobile/core/auth/secure_session_storage.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/auth/presentation/auth_gate.dart';
import 'package:happyn_mobile/flavor.dart';

/// `flutter run` with no entrypoint gets dev. Prod is never the accident.
Future<void> main() => bootstrap(Flavor.dev);

/// Shared by both flavor entrypoints: the only difference between them is the
/// [AppConfig] the tree is built with.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Supabase credentials come from --dart-define, so a build without them
  // still launches: sign-in is unavailable and the map-only shell remains.
  if (hasSupabaseConfig) {
    await Supabase.initialize(
      publishableKey: supabaseAnonKey,
      // The session holds a refresh token, which is a credential. Keychain and
      // Keystore are where those belong; the package's default is shared
      // preferences, which is plain storage.
      authOptions: const FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
      ),
      url: supabaseUrl,
    );
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
      home: const AuthGate(),
      theme: buildHappynTheme(),
      title: config.appName,
    );
  }
}
