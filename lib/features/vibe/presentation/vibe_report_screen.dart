import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';

/// "Vibe Report — Your Weekly Rhythm".
class VibeReportScreen extends StatelessWidget {
  const VibeReportScreen({super.key});

  static const _stats = <(IconData, Color, String, String)>[
    (Icons.directions_run, AppColors.secondary, '32', 'KM EXPLORED'),
    (Icons.location_on, AppColors.tertiary, '5', 'NEW SPOTS'),
    (Icons.nightlife, AppColors.primary, '8', 'EVENTS ATTENDED'),
    (Icons.group, AppColors.secondary, '12', 'NEW ORBITS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepInk,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: headerOffset(context, 96),
              bottom: 128,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'YOUR\nVIBE REPORT',
                            style: AppText.displayXl,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oct 12 - Oct 19',
                            style: AppText.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    const _TopVibeCard(),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        Expanded(child: _StatCard(stat: _stats[0])),
                        const SizedBox(width: 16),
                        Expanded(child: _StatCard(stat: _stats[1])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _StatCard(stat: _stats[2]),
                    const SizedBox(height: 16),
                    _StatCard(stat: _stats[3]),
                    const SizedBox(height: 48),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Verified Moments',
                        style: AppText.headlineMd,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xl,
                                ),
                                child: NetImage(DemoImages.vibe[1 + i]),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Center(child: _ShareVibeButton()),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _VibeHeader()),
        ],
      ),
    );
  }
}

class _VibeHeader extends StatelessWidget {
  const _VibeHeader();

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 24,
      border: Border(
        bottom: BorderSide(
          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.2),
        ),
      ),
      color: AppColors.primaryContainer.withValues(alpha: 0.8),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Frosted(
                  blur: 12,
                  border: Border.all(
                    color: AppColors.onSurface.withValues(alpha: 0.05),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  color: const Color(0x6620201C),
                  child: const SizedBox(
                    height: 40,
                    width: 40,
                    child: Icon(
                      Icons.close,
                      color: AppColors.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Text('Weekly Vibe', style: AppText.headlineSm),
              const SizedBox(height: 40, width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopVibeCard extends StatelessWidget {
  const _TopVibeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            color: AppColors.secondary.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(opacity: 0.6, child: NetImage(DemoImages.vibe[0])),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryContainer,
                      Color(0x800B0D12),
                      Color(0x000B0D12),
                    ],
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        color: AppColors.secondary.withValues(alpha: 0.1),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: AppColors.secondary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TOP VIBE',
                            style: AppText.labelSm.copyWith(
                              color: AppColors.secondary,
                              letterSpacing: 0.05 * 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // `.text-gradient`: linear-gradient(to right, coral, primary)
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                      ).createShader(bounds),
                      child: Text(
                        'TECHNO\nHEAD',
                        style: AppText.displayLg.copyWith(
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You spent 14 hours in the underground this week. '
                      'Your energy is unmatched.',
                      style: AppText.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final (IconData, Color, String, String) stat;

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 12,
      border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.05)),
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      color: const Color(0x6620201C),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(stat.$1, color: stat.$2, size: 30),
            const SizedBox(height: 8),
            Text(stat.$3, style: AppText.displayLg),
            const SizedBox(height: 8),
            Text(
              stat.$4,
              style: AppText.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.1 * 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareVibeButton extends StatelessWidget {
  const _ShareVibeButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ],
        color: AppColors.secondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.ios_share, color: AppColors.onSecondary, size: 24),
          const SizedBox(width: 8),
          Text(
            'SHARE MY VIBE',
            style: AppText.labelMd.copyWith(
              color: AppColors.onSecondary,
              letterSpacing: 0.05 * 14,
            ),
          ),
        ],
      ),
    );
  }
}
