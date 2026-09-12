import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/map/happyn_map.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/city/domain/time_machine.dart';
import 'package:happyn_mobile/features/event/presentation/event_detail_screen.dart';
import 'package:happyn_mobile/features/events/data/events_repository.dart';
import 'package:happyn_mobile/features/events/domain/happyn_event.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_avatar.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_screen.dart';

/// "Living City": the tilted city map with every nearby event standing on it.
/// The map is the whole page. Nothing about an event is shown here beyond its
/// pin and name; tapping one leaves for [EventDetailScreen]. Every pin is an
/// API occurrence — an empty city means the API had none to give.
class CityScreen extends ConsumerStatefulWidget {
  const CityScreen({super.key});

  @override
  ConsumerState<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends ConsumerState<CityScreen> {
  static const _categories = <String>[
    'FOR YOU',
    'MUSIC',
    'COMEDY',
    'FOOD',
    'PETS',
    'SPORTS',
  ];

  int _category = 0;
  int _slot = 0;

  /// "FOR YOU" is not a category the API knows; it means no filter.
  EventCategory? get _selectedCategory => switch (_categories[_category]) {
    'MUSIC' => EventCategory.music,
    'COMEDY' => EventCategory.comedy,
    'FOOD' => EventCategory.food,
    'PETS' => EventCategory.pets,
    'SPORTS' => EventCategory.sports,
    _ => null,
  };

  void _openEvent(List<HappynEvent> nearby, String id) {
    final event = nearby.where((event) => event.id == id).firstOrNull;
    if (event == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading until the device reports a fix; the city centre holds the camera
    // until then, and the map flies to the device once it arrives.
    final centre = ref.watch(searchCentreProvider).value ?? bengaluruCentre;
    final stops = timeMachineStops(DateTime.now());
    final until = stops[_slot];
    // An unreachable API leaves the map empty rather than failing the screen.
    final nearby =
        ref
            .watch(
              nearbyEventsProvider((category: _selectedCategory, until: until)),
            )
            .value ??
        const <HappynEvent>[];
    final profile = ref.watch(currentProfileProvider).value;

    return Stack(
      children: [
        Positioned.fill(
          child: HappynMap(
            centre: centre,
            fallback: const _IsometricMap(),
            light: lightAt(until ?? DateTime.now()),
            onPinTapped: (id) => _openEvent(nearby, id),
            pins: [
              for (final event in nearby)
                MapPin(
                  id: event.id,
                  isLive: event.isLive,
                  label: event.title,
                  latitude: event.latitude,
                  longitude: event.longitude,
                ),
            ],
          ),
        ),
        Positioned(left: 0, right: 0, top: 0, child: _Header(profile: profile)),
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
            labels: [for (final stop in stops) stopLabel(stop)],
            onSelected: (i) => setState(() => _slot = i),
            selected: _slot,
          ),
        ),
        // Last, and clearing the shell's bottom navigation: the tile licence
        // is only satisfied while this stays visible.
        const MapAttribution(bottomInset: 88),
      ],
    );
  }
}

/// `transform: rotateX(60deg) rotateZ(-30deg) translateZ(-200px) scale(0.8)`
/// over a 100px grid, with a few extruded blocks. Covers the frame until the
/// map style has loaded.
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

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final UserProfile? profile;

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
                        'Exploring within ${nearbyRadiusMeters ~/ 1000} km',
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
                    builder: (_) => const ProfileScreen(),
                  ),
                ),
                child: ProfileAvatar(profile: profile, size: 40),
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

/// A knob you can drag along the track as well as tap. While a finger is
/// down the knob follows it exactly; on release it settles on the nearest
/// stop, and only then does the city ask for that hour.
class _TimeMachine extends StatefulWidget {
  const _TimeMachine({
    required this.labels,
    required this.onSelected,
    required this.selected,
  });

  final List<String> labels;
  final ValueChanged<int> onSelected;
  final int selected;

  @override
  State<_TimeMachine> createState() => _TimeMachineState();
}

class _TimeMachineState extends State<_TimeMachine> {
  static const _inset = 4.0;
  static const _knob = 16.0;

  /// Knob position in stops while a finger is on the track; null at rest.
  double? _dragging;

  double _stopAt(double dx, double step) =>
      ((dx - _inset) / step).clamp(0, widget.labels.length - 1).toDouble();

  void _release() {
    final landed = _dragging;
    if (landed == null) return;
    setState(() => _dragging = null);
    widget.onSelected(landed.round());
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.labels.length;
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
                        (constraints.maxWidth - 2 * _inset) / (count - 1);
                    final knob = _dragging ?? widget.selected.toDouble();
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragCancel: _release,
                      onHorizontalDragEnd: (_) => _release(),
                      onHorizontalDragStart: (details) => setState(
                        () =>
                            _dragging = _stopAt(details.localPosition.dx, step),
                      ),
                      onHorizontalDragUpdate: (details) => setState(
                        () =>
                            _dragging = _stopAt(details.localPosition.dx, step),
                      ),
                      onTapUp: (details) => widget.onSelected(
                        _stopAt(details.localPosition.dx, step).round(),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 6,
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
                          // The stretch already travelled.
                          Positioned(
                            left: 0,
                            top: 6,
                            width: _inset + knob * step,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                color: AppColors.secondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              height: 4,
                            ),
                          ),
                          for (var i = 0; i < count; i++)
                            Positioned(
                              left: _inset + i * step - 20,
                              top: 0,
                              width: 40,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: i <= knob
                                          ? AppColors.secondary
                                          : AppColors.outlineVariant,
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
                                    widget.labels[i],
                                    style: AppText.labelSm.copyWith(
                                      color: i == widget.selected
                                          ? AppColors.secondary
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          AnimatedPositioned(
                            curve: Curves.easeOut,
                            duration: Duration(
                              milliseconds: _dragging == null ? 200 : 0,
                            ),
                            left: _inset + knob * step - _knob / 2,
                            top: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 12,
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ],
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              height: _knob,
                              width: _knob,
                            ),
                          ),
                        ],
                      ),
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
