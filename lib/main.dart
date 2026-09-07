import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/shell/presentation/app_shell.dart';
import 'package:happyn_mobile/flavor.dart';

/// `flutter run` with no entrypoint gets dev. Prod is never the accident.
void main() => bootstrap(Flavor.dev);

/// Shared by both flavor entrypoints: the only difference between them is the
/// [AppConfig] the tree is built with.
void bootstrap(Flavor flavor) {
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
