import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/map/happyn_map.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_screen.dart';
import 'package:happyn_mobile/features/event/presentation/event_detail_screen.dart';

/// "Living City — Nighttime": the flat grid void with the orbiting diorama
/// and the Temporal Control segmented pill.
class NightCityScreen extends ConsumerStatefulWidget {
  const NightCityScreen({required this.slot, super.key});

  final String slot;

  @override
  ConsumerState<NightCityScreen> createState() => _NightCityScreenState();
}

class _NightCityScreenState extends ConsumerState<NightCityScreen> {
  static const _controls = <(String, IconData)>[
    ('NOW', Icons.schedule),
    ('TONIGHT', Icons.dark_mode),
    ('WEEKEND', Icons.event),
  ];

  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepInk,
      body: Stack(
        children: [
          Positioned.fill(
            child: HappynMap(
              centre: ref.watch(searchCentreProvider).value ?? bengaluruCentre,
              fallback: const _MapGrid(),
              light: MapLight.night,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: const _NightDiorama(),
              ),
            ),
          ),
          Positioned(left: 0, right: 0, top: 0, child: const _NightHeader()),
          Positioned(
            bottom: 96 + MediaQuery.viewPaddingOf(context).bottom,
            left: 0,
            right: 0,
            child: Center(
              child: _TemporalControl(
                controls: _controls,
                onSelected: (i) => setState(() => _selected = i),
                selected: _selected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `background-image: linear-gradient(...)` 40px grid over Deep Ink.
class _MapGrid extends StatelessWidget {
  const _MapGrid();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: ColoredBox(
        color: AppColors.deepInk,
        child: CustomPaint(painter: _MapGridPainter()),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF46464B).withValues(alpha: 0.1)
      ..strokeWidth = 1;
    final offsetX = (size.width / 2) % 40;
    final offsetY = (size.height / 2) % 40;
    for (var x = offsetX; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = offsetY; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter oldDelegate) => false;
}

class _NightHeader extends StatelessWidget {
  const _NightHeader();

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 12,
      color: AppColors.surface.withValues(alpha: 0.4),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileScreen(),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.surfaceVariant,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  height: 40,
                  width: 40,
                  child: ClipOval(child: NetImage(DemoImages.cityNight[0])),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Exploring within 10km',
                    style: AppText.displayLg,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
                width: 40,
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 280px diorama with the coral halo, Editor's Pick tag and orbiting friends.
class _NightDiorama extends StatelessWidget {
  const _NightDiorama();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      width: 380,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0),
                    AppColors.secondary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0),
                  ],
                  end: Alignment.bottomCenter,
                ),
              ),
              height: 200,
              width: 140,
            ),
          ),
          OrbitRing(
            diameter: 360,
            duration: const Duration(seconds: 20),
            ringColor: AppColors.outlineVariant.withValues(alpha: 0.1),
            satellites: [
              (
                0.08,
                _Satellite(
                  borderColor: AppColors.secondary,
                  url: DemoImages.cityNight[2],
                ),
              ),
              (
                0.62,
                _Satellite(
                  borderColor: AppColors.tertiary,
                  url: DemoImages.cityNight[3],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EventDetailScreen(),
              ),
            ),
            child: SizedBox(
              height: 280,
              width: 280,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 24,
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          spreadRadius: -4,
                        ),
                      ],
                      color: AppColors.surfaceContainer.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          NetImage(DemoImages.cityNight[1]),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [Color(0x000B0D12), Color(0xCC0B0D12)],
                                stops: [0.55, 1],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Transform.rotate(
                      angle: 3 * 3.1415926535 / 180,
                      child: const VerifiedBadge(
                        border: Border.fromBorderSide(
                          BorderSide(color: AppColors.deepInk, width: 2),
                        ),
                        label: "Editor's Pick",
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -48,
                    left: -20,
                    right: -20,
                    child: Center(child: const _DioramaLabel()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DioramaLabel extends StatelessWidget {
  const _DioramaLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            color: Color(0x4D000000),
            offset: Offset(0, 10),
          ),
        ],
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bangalore Comedy Night',
            style: AppText.headlineSm.copyWith(
              shadows: [
                Shadow(
                  blurRadius: 12,
                  color: AppColors.secondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const PulseSlow(child: EnergyPill.bare(label: '98% Energy')),
        ],
      ),
    );
  }
}

class _Satellite extends StatelessWidget {
  const _Satellite({required this.borderColor, required this.url});

  final Color borderColor;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      height: 40,
      width: 40,
      child: ClipOval(child: NetImage(url)),
    );
  }
}

class _TemporalControl extends StatelessWidget {
  const _TemporalControl({
    required this.controls,
    required this.onSelected,
    required this.selected,
  });

  final List<(String, IconData)> controls;
  final ValueChanged<int> onSelected;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Frosted(
          blur: 8,
          borderRadius: BorderRadius.circular(AppRadius.full),
          color: AppColors.surface.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Temporal Control',
              style: AppText.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.1 * 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FractionallySizedBox(
          widthFactor: 0.9,
          child: Frosted(
            blur: 24,
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
            // The design's three controls are wider than the pill at mobile
            // widths and simply clip; scrolling keeps the same framing.
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < controls.length; i++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelected(i),
                      child: Container(
                        decoration: i == selected
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 15,
                                    color: AppColors.tertiary.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ],
                                color: AppColors.tertiary,
                              )
                            : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controls[i].$2,
                              color: i == selected
                                  ? AppColors.onTertiary
                                  : AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controls[i].$1,
                              style: AppText.labelSm.copyWith(
                                color: i == selected
                                    ? AppColors.onTertiary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: i == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                letterSpacing: 0.05 * 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
