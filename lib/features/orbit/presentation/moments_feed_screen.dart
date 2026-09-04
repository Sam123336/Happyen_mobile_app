import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_screen.dart';
import 'package:happyn_mobile/features/shell/presentation/app_shell.dart';

/// "Moments Feed — Clarity & Vibe": the ORBIT tab of live, verified moments.
class MomentsFeedScreen extends ConsumerStatefulWidget {
  const MomentsFeedScreen({super.key});

  @override
  ConsumerState<MomentsFeedScreen> createState() => _MomentsFeedScreenState();
}

class _MomentsFeedScreenState extends ConsumerState<MomentsFeedScreen> {
  static const _vibes = <String>['WILD', 'HYPE', 'CHILL', 'CULTURE'];

  int _vibe = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBlobs()),
          ListView(
            padding: EdgeInsets.only(
              top: headerOffset(context, 100),
              bottom: 128,
            ),
            children: [
              _VibeFilters(
                onSelected: (i) => setState(() => _vibe = i),
                selected: _vibe,
                vibes: _vibes,
              ),
              const SizedBox(height: 96),
              const _LiveMoment(),
              const SizedBox(height: 96),
              const _StackedMoment(),
            ],
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _OrbitHeader()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HappynBottomNav(
              compactLabels: true,
              current: HappynTab.discover,
              discoverIcon: Icons.adjust,
              discoverLabel: 'ORBIT',
              onChanged: (tab) {
                if (tab == HappynTab.discover) return;
                ref.read(selectedTabProvider.notifier).select(tab);
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The two blurred colour washes behind the feed.
class _AmbientBlobs extends StatelessWidget {
  const _AmbientBlobs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -100,
            top: 80,
            child: _Blob(
              color: AppColors.secondary.withValues(alpha: 0.1),
              size: 384,
            ),
          ),
          Positioned(
            bottom: 160,
            right: -100,
            child: _Blob(
              color: AppColors.tertiary.withValues(alpha: 0.1),
              size: 320,
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(blurRadius: 100, color: color, spreadRadius: 40)],
        color: color,
        shape: BoxShape.circle,
      ),
      height: size,
      width: size,
    );
  }
}

class _OrbitHeader extends StatelessWidget {
  const _OrbitHeader();

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 24,
      border: Border(
        bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      color: AppColors.background.withValues(alpha: 0.6),
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProfileScreen(),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariant),
                        shape: BoxShape.circle,
                      ),
                      height: 40,
                      width: 40,
                      child: ClipOval(child: NetImage(DemoImages.orbit[0])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'HAPPYEN',
                    style: AppText.displayLg.copyWith(
                      fontSize: 24,
                      height: 1.1,
                      letterSpacing: -0.05 * 24,
                    ),
                  ),
                ],
              ),
              Frosted(
                blur: 12,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(AppRadius.full),
                color: AppColors.surfaceContainer.withValues(alpha: 0.5),
                child: const SizedBox(
                  height: 40,
                  width: 40,
                  child: Icon(
                    Icons.my_location,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VibeFilters extends StatelessWidget {
  const _VibeFilters({
    required this.onSelected,
    required this.selected,
    required this.vibes,
  });

  final ValueChanged<int> onSelected;
  final int selected;
  final List<String> vibes;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          colors: [
            AppColors.background,
            AppColors.background.withValues(alpha: 0.8),
            AppColors.background.withValues(alpha: 0),
          ],
          end: Alignment.bottomCenter,
        ),
      ),
      child: SizedBox(
        height: 78,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final active = index == selected;
            return Center(
              child: GestureDetector(
                onTap: () => onSelected(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: active
                          ? AppColors.secondary
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              blurRadius: 15,
                              color: AppColors.secondary.withValues(alpha: 0.3),
                            ),
                          ]
                        : null,
                    color: active
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Text(
                    vibes[index],
                    style: AppText.labelMd.copyWith(
                      color: active ? AppColors.secondary : AppColors.onSurface,
                    ),
                  ),
                ),
              ),
            );
          },
          itemCount: vibes.length,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            8,
            AppSpacing.marginMobile,
            24,
          ),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
        ),
      ),
    );
  }
}

/// `border-radius: 40% 60% 70% 30% / 40% 50% 60% 50%`
BorderRadius _blobOne(double w, double h) => BorderRadius.only(
  bottomLeft: Radius.elliptical(w * 0.30, h * 0.50),
  bottomRight: Radius.elliptical(w * 0.70, h * 0.60),
  topLeft: Radius.elliptical(w * 0.40, h * 0.40),
  topRight: Radius.elliptical(w * 0.60, h * 0.50),
);

/// `border-radius: 60% 40% 30% 70% / 60% 30% 70% 40%`
BorderRadius _blobTwo(double w, double h) => BorderRadius.only(
  bottomLeft: Radius.elliptical(w * 0.70, h * 0.40),
  bottomRight: Radius.elliptical(w * 0.30, h * 0.70),
  topLeft: Radius.elliptical(w * 0.60, h * 0.60),
  topRight: Radius.elliptical(w * 0.40, h * 0.30),
);

class _LiveMoment extends StatelessWidget {
  const _LiveMoment();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 48),
      child: Column(
        children: [
          SizedBox(
            height: 400,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 32,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: _blobOne(320, 400),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 40,
                          color: AppColors.secondary.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                    height: 400,
                    width: 320,
                    child: ClipRRect(
                      borderRadius: _blobOne(320, 400),
                      child: NetImage(DemoImages.orbit[1]),
                    ),
                  ),
                ),
                Positioned(
                  left: 32,
                  top: -20,
                  child: PulseSlow(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: AppColors.secondary.withValues(alpha: 0.4),
                          ),
                        ],
                        color: AppColors.secondary.withValues(alpha: 0.1),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            height: 8,
                            width: 8,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LIVE NOW',
                            style: AppText.labelSm.copyWith(
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2 * 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: 280,
                  child: Frosted(
                    blur: 12,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    color: AppColors.background.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'NEON NIGHTS\nAT THE VAULT',
                        style: AppText.displayXl.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          height: 0.9,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        height: 56,
                        width: 56,
                        child: ClipOval(child: NetImage(DemoImages.orbit[2])),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Elena R.',
                              style: AppText.headlineSm.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.025 * 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                'Lost in the bassline. The energy here is '
                                'unmatched tonight.',
                                style: AppText.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const _ActionRail(
                  icons: [Icons.favorite, Icons.chat_bubble, Icons.share],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedMoment extends StatelessWidget {
  const _StackedMoment();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: ClipOval(
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0, 0, 0, 1, 0, //
                      ]),
                      child: NetImage(DemoImages.orbit[3]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Marcus T.',
                  style: AppText.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 450,
            child: Stack(
              children: [
                Positioned(
                  left: 24,
                  top: 0,
                  child: Transform.rotate(
                    angle: -6 * math.pi / 180,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 50,
                            color: Color(0x66000000),
                            offset: Offset(0, 25),
                          ),
                        ],
                      ),
                      height: 320,
                      width: 240,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: NetImage(DemoImages.orbit[4]),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 32,
                  top: 128,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      borderRadius: _blobTwo(180, 180),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 25,
                          color: Color(0x40000000),
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    height: 180,
                    width: 180,
                    child: ClipRRect(
                      borderRadius: _blobTwo(180, 180),
                      child: NetImage(DemoImages.orbit[5]),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 180,
                  child: Frosted(
                    blur: 6,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    color: AppColors.background.withValues(alpha: 0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VERIFIED HERE',
                            style: AppText.labelSm.copyWith(
                              color: AppColors.tertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3 * 10,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '5 hours ago',
                            style: AppText.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 48,
                  left: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Frosted(
                        blur: 12,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        color: AppColors.background.withValues(alpha: 0.6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'THE\nALCHEMIST',
                            style: AppText.displayLg.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'HIDDEN SPEAKEASY VIBES.',
                        style: AppText.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                          letterSpacing: 0.1 * 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  bottom: 48,
                  right: 32,
                  child: _ActionRail(
                    icons: [Icons.favorite_border, Icons.chat_bubble_outline],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({required this.icons});

  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 24,
      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      borderRadius: BorderRadius.circular(AppRadius.full),
      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < icons.length; i++) ...[
              if (i > 0) const SizedBox(height: 24),
              SizedBox(
                height: 40,
                width: 40,
                child: Icon(
                  icons[i],
                  color: i == 0 ? AppColors.secondary : AppColors.onSurface,
                  size: 24,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
