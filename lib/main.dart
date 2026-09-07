import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/shell/presentation/app_shell.dart';

void main() {
  runApp(const ProviderScope(retry: retryOnce, child: HappynApp()));
}

class HappynApp extends StatelessWidget {
  const HappynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
      theme: buildHappynTheme(),
      title: 'Happyen',
    );
  }
}
