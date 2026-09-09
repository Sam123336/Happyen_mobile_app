import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/auth/presentation/create_account_screen.dart';
import 'package:happyn_mobile/features/auth/presentation/sign_in_screen.dart';
import 'package:happyn_mobile/features/shell/presentation/app_shell.dart';
import 'package:happyn_mobile/flavor.dart';

/// Decides what the app opens on, from state rather than from navigation:
/// signed out → sign in, signed in but unnamed → create the account, otherwise
/// the city. Because it watches providers, finishing a step moves the user on
/// without any screen pushing the next one.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A build with no Supabase credentials cannot sign anyone in. Rather than
    // trapping the user on a sign-in screen that can never succeed, keep the
    // map-only shell that needs no identity.
    if (!hasSupabaseConfig) return const AppShell();

    final authUser = ref.watch(authUserProvider);

    return switch (authUser) {
      AsyncData(value: null) => const SignInScreen(),
      AsyncData() => const _ProvisionedGate(),
      AsyncError() => const SignInScreen(),
      _ => const _Splash(),
    };
  }
}

/// Signed in with Supabase, but Happyen's own account may still be half-built:
/// the backend row exists from the first `POST /v1/auth/session`, and a null
/// username is what "has not finished signing up" looks like.
class _ProvisionedGate extends ConsumerWidget {
  const _ProvisionedGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return switch (profile) {
      AsyncData(:final value?) when value.username == null =>
        const CreateAccountScreen(),
      AsyncData(value: _?) => const AppShell(),
      AsyncError(:final error) => _ProvisionFailed(error: error),
      _ => const _Splash(),
    };
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SizedBox(
          height: 26,
          width: 26,
          child: CircularProgressIndicator(
            color: AppColors.secondaryFixedDim,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

/// The session is valid but the backend would not provision the account. That
/// is a real failure worth showing, not an empty city: without it the app
/// silently looks like a design mock, which is exactly the confusion the
/// silent-fallback habit used to cause.
class _ProvisionFailed extends ConsumerWidget {
  const _ProvisionFailed({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'We could not open your account',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '$error',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AuthButton(
                  busy: false,
                  label: 'TRY AGAIN',
                  onPressed: () => ref.invalidate(currentProfileProvider),
                ),
                TextButton(
                  onPressed: () => ref.read(authGatewayProvider).signOut(),
                  child: const Text(
                    'Sign out',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
