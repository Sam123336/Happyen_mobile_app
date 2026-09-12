import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/auth/presentation/create_account_screen.dart';
import 'package:happyn_mobile/features/auth/presentation/sign_in_screen.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_avatar.dart';
import 'package:happyn_mobile/flavor.dart';

/// The account as the API knows it: name, handle, bio and streak. Nothing here
/// is placeholder; a section appears only once its endpoint exists.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: switch (profile) {
              AsyncData(:final value?) => _Account(profile: value),
              AsyncData() || AsyncError() => const _SignedOut(),
              _ => const Center(
                child: SizedBox(
                  height: 26,
                  width: 26,
                  child: CircularProgressIndicator(
                    color: AppColors.secondaryFixedDim,
                    strokeWidth: 2,
                  ),
                ),
              ),
            },
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _Header()),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 12,
      color: AppColors.background.withValues(alpha: 0.4),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: 16,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  height: 40,
                  width: 40,
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.onSurface,
                    size: 22,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'PROFILE',
                  style: AppText.labelMd.copyWith(letterSpacing: 0.1 * 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _Account extends ConsumerWidget {
  const _Account({required this.profile});

  final UserProfile profile;

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authGatewayProvider).signOut();
    // The gate swaps its home for the sign-in screen; this route still sits
    // on top of it until popped.
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = profile.username;
    final bio = profile.bio;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        headerOffset(context, 104),
        AppSpacing.marginMobile,
        48,
      ),
      children: [
        Center(child: ProfileAvatar(profile: profile, size: 96)),
        const SizedBox(height: 16),
        Text(
          profile.displayName,
          style: AppText.headlineMd,
          textAlign: TextAlign.center,
        ),
        if (username != null) ...[
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: AppText.labelMd.copyWith(color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
        if (bio != null && bio.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            bio,
            style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 32),
        _StreakCard(days: profile.streakDays),
        const SizedBox(height: 32),
        AuthButton(
          busy: false,
          label: 'EDIT PROFILE',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreateAccountScreen(existing: profile),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _signOut(context, ref),
          child: Text(
            'Sign out',
            style: AppText.labelMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Days in a row the city was opened. The API counts it; this only shows it.
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 6,
      border: Border.all(
        color: AppColors.outlineVariant.withValues(alpha: 0.3),
      ),
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      color: AppColors.surfaceContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              color: AppColors.tertiary,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$days', style: AppText.displayLg),
                      const SizedBox(width: 8),
                      Text(
                        'DAY CITY STREAK',
                        style: AppText.labelSm.copyWith(
                          color: AppColors.tertiary,
                          letterSpacing: 0.1 * 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Open Happyen every day to keep it going.',
                    style: AppText.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ProfileAvatar(profile: null, size: 96),
            const SizedBox(height: 16),
            Text(
              'Sign in to make your profile',
              style: AppText.headlineSm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSupabaseConfig
                  ? 'Your name, handle and streak live with your account.'
                  : 'This build was made without Supabase credentials, so '
                        'sign-in is unavailable.',
              style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
