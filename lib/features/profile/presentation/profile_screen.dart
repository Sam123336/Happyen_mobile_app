import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/vibe/presentation/vibe_report_screen.dart';
import 'package:happyn_mobile/features/shell/presentation/app_shell.dart';

/// "User Profile — My Verified Journey".
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _tags = <String>['TECHNO HEAD', 'ART SCENE', 'FOODIE'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: headerOffset(context, 112),
              bottom: 128,
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                child: Column(
                  children: [
                    _ProfileIdentity(tags: _tags),
                    SizedBox(height: 48),
                    _StatsPanel(),
                    SizedBox(height: 48),
                    _VerifiedMoments(),
                    SizedBox(height: 48),
                    Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: _ShareProfileButton(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _ProfileHeader()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HappynBottomNav(
              compactLabels: true,
              current: HappynTab.people,
              onChanged: (tab) {
                ref.read(selectedTabProvider.notifier).select(tab);
                Navigator.of(context).maybePop();
              },
              peopleIcon: Icons.person,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  height: 40,
                  width: 40,
                  child: ClipOval(child: NetImage(DemoImages.profile[0])),
                ),
              ),
              Expanded(
                child: Text(
                  'HAPPYEN',
                  style: AppText.headlineMd.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    letterSpacing: -0.05 * 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 40,
                width: 40,
                child: Icon(
                  Icons.settings_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surfaceVariant, width: 2),
            shape: BoxShape.circle,
          ),
          height: 128,
          width: 128,
          child: ClipOval(child: NetImage(DemoImages.profile[1])),
        ),
        const SizedBox(height: 24),
        Text('Alex Mercer', style: sora16),
        const SizedBox(height: 8),
        Text(
          "Exploring the city's hidden frequencies. Always down for "
          'late-night jazz and early-morning coffee.',
          style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const VibeReportScreen()),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: AppColors.tertiary.withValues(alpha: 0.4),
                ),
              ],
              color: AppColors.surfaceContainerHigh,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppColors.tertiary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '12 WEEK STREAK',
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.tertiary,
                    letterSpacing: 0.1 * 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            for (final tag in tags)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondaryFixed.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  color: AppColors.secondaryFixed.withValues(alpha: 0.1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Text(
                  tag,
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.secondaryFixed,
                    letterSpacing: 0.05 * 16,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel();

  static const _stats = <(String, String)>[
    ('42', 'VERIFIED MOMENTS'),
    ('89', 'EVENTS ATTENDED'),
    ('1.2k', 'FOLLOWERS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 4,
      border: const Border.symmetric(
        horizontal: BorderSide(color: AppColors.surfaceVariant),
      ),
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          children: [
            for (var i = 0; i < _stats.length; i++) ...[
              if (i > 0)
                Container(
                  color: AppColors.surfaceVariant,
                  height: 48,
                  width: 1,
                ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_stats[i].$1, style: sora16),
                    Text(
                      _stats[i].$2,
                      style: AppText.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.05 * 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerifiedMoments extends StatelessWidget {
  const _VerifiedMoments();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Verified Moments', style: sora16),
            Text(
              'VIEW ALL',
              style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: _MomentTile(
                height: 150,
                imageIndex: 2,
                place: 'Basement Club',
              ),
            ),
            SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: _MomentTile(
                height: 150,
                imageIndex: 3,
                place: 'The Velvet Room',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gutter),
        const _MomentTile(
          caption:
              'Incredible energy tonight. The installations completely '
              'transformed the plaza.',
          height: 250,
          imageIndex: 4,
          place: 'Lumina Festival',
        ),
      ],
    );
  }
}

class _MomentTile extends StatelessWidget {
  const _MomentTile({
    required this.height,
    required this.imageIndex,
    required this.place,
    this.caption,
  });

  final String? caption;
  final double height;
  final int imageIndex;
  final String place;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(DemoImages.profile[imageIndex]),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  colors: [
                    Color(0xE6131410),
                    Color(0x33131410),
                    Color(0x00131410),
                  ],
                  end: Alignment.topCenter,
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: AppColors.secondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          place,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyMd,
                        ),
                      ),
                    ],
                  ),
                  if (caption != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      caption!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareProfileButton extends StatelessWidget {
  const _ShareProfileButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.2),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ],
          color: AppColors.secondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Text(
          'SHARE PROFILE',
          style: AppText.bodyMd.copyWith(
            color: AppColors.onSecondary,
            letterSpacing: 0.05 * 16,
          ),
        ),
      ),
    );
  }
}

/// Several Stitch screens apply the Sora family without a size utility, so
/// their headings render at the inherited 16px.
TextStyle get sora16 => AppText.headlineMd.copyWith(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 24 / 16,
);
