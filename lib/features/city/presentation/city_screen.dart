import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/activity/presentation/activity_screen.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_screen.dart';
import 'package:happyn_mobile/features/city/presentation/night_city_screen.dart';
import 'package:happyn_mobile/features/event/presentation/event_detail_screen.dart';

/// "Living City — Daytime": the isometric city diorama with the Time Machine.
class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  static const _categories = <String>[
    'FOR YOU',
    'MUSIC',
    'COMEDY',
    'FOOD',
    'PETS',
    'SPORTS',
  ];
  static const _slots = <String>['NOW', '6PM', '9PM', '12AM'];

  int _category = 0;
  int _slot = 0;

  void _selectSlot(int index) {
    setState(() => _slot = index);
    if (index == 0) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => NightCityScreen(slot: _slots[index]),
          ),
        )
        .then((_) {
          if (mounted) setState(() => _slot = 0);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _IsometricMap()),
        const Positioned.fill(child: _Fog()),
        Positioned.fill(
          child: Center(
            child: _EventDiorama(
              energy: '82° Energy',
              imageUrl: DemoImages.cityDay[3],
              satellites: DemoImages.cityDay.take(3).toList(),
              subtitle: '8:30 PM',
              title: 'Bangalore Comedy Night',
            ),
          ),
        ),
        Positioned(left: 0, right: 0, top: 0, child: _Header()),
        Positioned(
          left: 0,
          right: 0,
          top: headerOffset(context, 88),
          child: _CategoryRow(
            categories: _categories,
            onSelected: (i) => setState(() => _category = i),
            selected: _category,
          ),
        ),
        Positioned(
          bottom: 116 + MediaQuery.viewPaddingOf(context).bottom,
          left: 0,
          right: 0,
          child: _TimeMachine(
            onSelected: _selectSlot,
            selected: _slot,
            slots: _slots,
          ),
        ),
      ],
    );
  }
}

/// `transform: rotateX(60deg) rotateZ(-30deg) translateZ(-200px) scale(0.8)`
/// over a 100px grid, with a few extruded blocks.
class _IsometricMap extends StatelessWidget {
  const _IsometricMap();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(60 * math.pi / 180)
      ..rotateZ(-30 * math.pi / 180)
      ..translateByDouble(0, 0, -200, 1)
      ..scaleByDouble(0.8, 0.8, 0.8, 1);
    return ColoredBox(
      color: AppColors.background,
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: OverflowBox(
          maxHeight: size.height * 2,
          maxWidth: size.width * 2,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: const _GridPainter()),
              ),
              for (final block in const [
                (Alignment(-0.5, -0.5), Size(48, 48)),
                (Alignment(0.33, -0.33), Size(64, 96)),
                (Alignment(-0.33, 0.5), Size(80, 40)),
                (Alignment(0.5, 0.33), Size(56, 56)),
              ])
                Align(
                  alignment: block.$1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant),
                      color: AppColors.surfaceContainerLow,
                    ),
                    height: block.$2.height,
                    width: block.$2.width,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1C1C18).withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

/// `radial-gradient(circle at center, transparent 30%, #0B0D12 80%)`
class _Fog extends StatelessWidget {
  const _Fog();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // CSS `circle at center` defaults to a farthest-corner radius.
          final corner =
              math.sqrt(
                math.pow(constraints.maxWidth / 2, 2) +
                    math.pow(constraints.maxHeight / 2, 2),
              ) /
              constraints.biggest.shortestSide;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: const [Color(0x000B0D12), Color(0xFF0B0D12)],
                radius: corner,
                stops: const [0.3, 0.8],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bengaluru',
                          style: AppText.displayLg.copyWith(
                            fontSize: 32,
                            height: 36 / 32,
                            letterSpacing: -0.05 * 32,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        'Exploring within 10 km',
                        style: AppText.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ActivityScreen(),
                  ),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
                  child: ClipOval(child: NetImage(DemoImages.cityDay[4])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.onSelected,
    required this.selected,
  });

  final List<String> categories;
  final ValueChanged<int> onSelected;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        itemBuilder: (context, index) => Center(
          child: FilterPill(
            label: categories[index],
            onTap: () => onSelected(index),
            selected: index == selected,
          ),
        ),
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: 8,
        ),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
      ),
    );
  }
}

/// 180px circular diorama, dashed 260px orbit ring, 32px satellites.
/// 180px circular diorama, dashed 260px orbit ring, 32px satellites.
/// Geometry mirrors the design: mask 180, ring 260, energy pill at top -40,
/// label block ending 48px below the mask.
class _EventDiorama extends StatelessWidget {
  const _EventDiorama({
    required this.energy,
    required this.imageUrl,
    required this.satellites,
    required this.subtitle,
    required this.title,
  });

  static const _box = 380.0;
  static const _mask = 180.0;
  static const _ring = 260.0;

  final String energy;
  final String imageUrl;
  final List<String> satellites;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    const maskTop = (_box - _mask) / 2;
    return SizedBox(
      height: _box,
      width: _box,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: (_box - _ring) / 2,
            top: (_box - _ring) / 2,
            child: OrbitRing(
              dashed: true,
              diameter: _ring,
              duration: const Duration(seconds: 30),
              ringColor: AppColors.outline.withValues(alpha: 0.3),
              satellites: [
                for (var i = 0; i < satellites.length; i++)
                  (
                    i / satellites.length,
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12,
                            color: Color(0x80000000),
                            offset: Offset(0, 4),
                          ),
                        ],
                        shape: BoxShape.circle,
                      ),
                      height: 32,
                      width: 32,
                      child: ClipOval(child: NetImage(satellites[i])),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: maskTop,
            top: maskTop,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EventDetailScreen(),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 40,
                      color: AppColors.secondary.withValues(alpha: 0.15),
                    ),
                  ],
                  shape: BoxShape.circle,
                ),
                height: _mask,
                width: _mask,
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetImage(imageUrl),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [AppColors.deepInk, Color(0x000B0D12)],
                            end: Alignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: maskTop - 40,
            child: Center(
              child: PulseSlow(
                child: EnergyPill(
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  label: energy,
                  style: AppText.labelMd,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: maskTop + _mask + 48 - 52,
            child: Column(
              children: [
                Text(
                  title,
                  style: AppText.headlineSm.copyWith(
                    letterSpacing: -0.025 * 20,
                    shadows: const [
                      Shadow(
                        blurRadius: 12,
                        color: Color(0xCC000000),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppText.labelMd.copyWith(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeMachine extends StatelessWidget {
  const _TimeMachine({
    required this.onSelected,
    required this.selected,
    required this.slots,
  });

  final ValueChanged<int> onSelected;
  final int selected;
  final List<String> slots;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      child: Frosted(
        blur: 12,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'TIME MACHINE',
                  style: AppText.labelSm.copyWith(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final step =
                        (constraints.maxWidth - 8) / (slots.length - 1);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              color: AppColors.surfaceContainerHighest,
                            ),
                            height: 4,
                          ),
                        ),
                        for (var i = 0; i < slots.length; i++)
                          Positioned(
                            left: 4 + i * step - 20,
                            top: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onSelected(i),
                              child: SizedBox(
                                width: 40,
                                child: Column(
                                  children: [
                                    if (i == selected)
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.background,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 12,
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ],
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                        height: 16,
                                        width: 16,
                                      )
                                    else
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: AppColors.outlineVariant,
                                          shape: BoxShape.circle,
                                        ),
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        width: 8,
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      slots[i],
                                      style: AppText.labelSm.copyWith(
                                        color: i == selected
                                            ? AppColors.secondary
                                            : AppColors.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
