import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/events/domain/happyn_event.dart';

/// One occurrence, exactly as the API describes it. Friends going, moments
/// and tickets are absent on purpose: each appears when its endpoint does.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({required this.event, super.key});

  final HappynEvent event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              _Hero(event: event),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  24,
                  AppSpacing.marginMobile,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetaRow(event: event),
                    const SizedBox(height: 24),
                    _PlaceAndStatus(event: event),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _TopBar()),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.event});

  final HappynEvent event;

  @override
  Widget build(BuildContext context) {
    final image = event.heroImageUrl;
    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            NetImage(image)
          else
            const ColoredBox(color: AppColors.surfaceContainer),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  Color(0x99131410),
                  Color(0x00131410),
                ],
                end: Alignment.topCenter,
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            child: Text(
              event.title.toUpperCase(),
              style: AppText.displayXl.copyWith(
                letterSpacing: -0.05 * 52,
                shadows: const [
                  Shadow(
                    blurRadius: 12,
                    color: Color(0xCC000000),
                    offset: Offset(0, 4),
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

class _TopBar extends StatelessWidget {
  const _TopBar();

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
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Frosted(
                blur: 12,
                borderRadius: BorderRadius.circular(AppRadius.full),
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                child: const SizedBox(
                  height: 40,
                  width: 40,
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.onSurface,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.event});

  final HappynEvent event;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      spacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_outlined,
              color: AppColors.onSurfaceVariant,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '${_categoryLabel(event)} · ${event.isLive ? 'LIVE' : 'UP NEXT'}',
              style: AppText.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.1 * 14,
              ),
            ),
          ],
        ),
        Text(
          '•',
          style: AppText.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, color: AppColors.onSurface, size: 18),
            const SizedBox(width: 6),
            Text(_timeLabel(event), style: AppText.bodyMd),
          ],
        ),
      ],
    );
  }
}

class _PlaceAndStatus extends StatelessWidget {
  const _PlaceAndStatus({required this.event});

  final HappynEvent event;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.outline,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(event.venueName, style: AppText.headlineSm),
                    Text(
                      _distanceLabel(event),
                      style: AppText.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            PulseSlow(
              duration: const Duration(seconds: 2),
              child: EnergyPill(
                background: AppColors.tertiaryFixed.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.3),
                ),
                iconSize: 18,
                label: event.isLive ? 'LIVE NOW' : 'UP NEXT',
                style: AppText.labelMd.copyWith(letterSpacing: 0.1 * 14),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event.isLive ? 'LIVE STATUS' : 'EVENT STATUS',
              style: AppText.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.05 * 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _categoryLabel(HappynEvent event) =>
    event.category == EventCategory.unknown
    ? 'EVENT'
    : event.category.name.toUpperCase();

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Happening now · until 11:30 PM", "Starts 8:30 PM", "Tomorrow 8:30 PM",
/// "14 Sep 8:30 PM". The day is only spelled out when it is not today.
String _timeLabel(HappynEvent event) {
  final end = event.endLabel;
  final until = end == null ? '' : ' · until $end';
  if (event.isLive) return 'Happening now$until';

  final now = DateTime.now();
  final start = event.startAt;
  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  final day = sameDay(start, now)
      ? ''
      : sameDay(start, now.add(const Duration(days: 1)))
      ? 'Tomorrow '
      : '${start.day} ${_months[start.month - 1]} ';
  return 'Starts $day${event.startLabel}$until';
}

String _distanceLabel(HappynEvent event) {
  if (event.distanceMeters < 1000) {
    return '${event.distanceMeters.round()} m away';
  }
  return '${(event.distanceMeters / 1000).toStringAsFixed(1)} km away';
}
