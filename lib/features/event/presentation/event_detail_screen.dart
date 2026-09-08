import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/events/domain/happyn_event.dart';
import 'package:happyn_mobile/features/geofence/presentation/geofence_screen.dart';
import 'package:happyn_mobile/features/orbit/presentation/moments_feed_screen.dart';
import 'package:happyn_mobile/features/ticket/presentation/ticket_screen.dart';

/// A detail view for an event selected from the living map.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({this.event, super.key});

  /// Nullable for the existing design-preview entry points. Map navigation
  /// always provides an API-backed occurrence.
  final HappynEvent? event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 128),
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
                    _PlaceAndEnergy(event: event),
                    const SizedBox(height: 48),
                    const _FriendsCard(),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        Text(
                          event?.isLive == true ? 'LIVE NOW' : 'EVENT MOMENTS',
                          style: AppText.headlineMd.copyWith(
                            letterSpacing: -0.025 * 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const _LiveNowRail(),
            ],
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _TopBar()),
          const Positioned(bottom: 0, left: 0, right: 0, child: _TicketBar()),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({this.event});

  final HappynEvent? event;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(event?.heroImageUrl ?? DemoImages.eventDetail[6]),
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
              (event?.title ?? 'Bangalore Comedy Night').toUpperCase(),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const _CircleButton(icon: Icons.ios_share),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Frosted(
        blur: 12,
        borderRadius: BorderRadius.circular(AppRadius.full),
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, color: AppColors.onSurface, size: 24),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({this.event});

  final HappynEvent? event;

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
              '${_categoryLabel(event)} · ${event?.isLive == true ? 'LIVE' : 'UP NEXT'}',
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

class _PlaceAndEnergy extends StatelessWidget {
  const _PlaceAndEnergy({this.event});

  final HappynEvent? event;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event?.venueName ?? 'Koramangala',
                  style: AppText.headlineSm,
                ),
                Text(
                  _distanceLabel(event),
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
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
                label: event?.isLive == true ? 'LIVE NOW' : 'UP NEXT',
                style: AppText.labelMd.copyWith(letterSpacing: 0.1 * 14),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event?.isLive == true ? 'LIVE STATUS' : 'EVENT STATUS',
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

String _categoryLabel(HappynEvent? event) {
  final category = event?.category;
  if (category == null || category == EventCategory.unknown) return 'EVENT';
  return category.name.toUpperCase();
}

String _timeLabel(HappynEvent? event) {
  if (event == null) return 'Tonight 8:30 PM';
  return event.isLive ? 'Happening now' : 'Starts ${event.startLabel}';
}

String _distanceLabel(HappynEvent? event) {
  if (event == null) return '2.4 km away';
  if (event.distanceMeters < 1000) {
    return '${event.distanceMeters.round()} m away';
  }
  return '${(event.distanceMeters / 1000).toStringAsFixed(1)} km away';
}

class _FriendsCard extends StatelessWidget {
  const _FriendsCard();

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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AvatarStack(
              overflowLabel: '+2',
              size: 40,
              urls: DemoImages.eventDetail.sublist(0, 3),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      style: AppText.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 16,
                      ),
                      text: 'Sarthak, Rahul',
                    ),
                    TextSpan(
                      style: AppText.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 20 / 16,
                      ),
                      text: ' + 4 friends are here',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              height: 32,
              width: 32,
              child: const Icon(
                Icons.chevron_right,
                color: AppColors.onSurface,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveNowRail extends StatelessWidget {
  const _LiveNowRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
        ),
        scrollDirection: Axis.horizontal,
        children: [
          _LiveCard(
            imageUrl: DemoImages.eventDetail[3],
            overlay: const VerifiedBadge(label: 'Verified Here'),
            width: 200,
          ),
          const SizedBox(width: 16),
          _LiveCard(
            imageUrl: DemoImages.eventDetail[4],
            overlay: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.surface),
                    shape: BoxShape.circle,
                  ),
                  height: 24,
                  width: 24,
                  child: ClipOval(child: NetImage(DemoImages.eventDetail[5])),
                ),
                const SizedBox(width: 8),
                Text('@priya_lols', style: AppText.labelSm),
              ],
            ),
            width: 260,
          ),
        ],
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({
    required this.imageUrl,
    required this.overlay,
    required this.width,
  });

  final String imageUrl;
  final Widget overlay;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const MomentsFeedScreen()),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        child: SizedBox(
          width: width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetImage(imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    colors: [Color(0xE6131410), Color(0x00131410)],
                    end: Alignment.center,
                  ),
                ),
              ),
              Positioned(bottom: 12, left: 12, child: overlay),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketBar extends StatelessWidget {
  const _TicketBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          colors: [AppColors.background, Color(0xE6131410), Color(0x00131410)],
          end: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TicketScreen(),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 16,
                          color: AppColors.secondary.withValues(alpha: 0.2),
                        ),
                      ],
                      color: AppColors.secondary,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GET TICKETS',
                          style: AppText.labelMd.copyWith(
                            color: AppColors.onSecondaryFixed,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1 * 14,
                          ),
                        ),
                        Text(
                          '₹499',
                          style: AppText.headlineSm.copyWith(
                            color: AppColors.onSecondaryFixed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GeofenceScreen(),
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  height: 56,
                  width: 56,
                  child: const Icon(
                    Icons.directions,
                    color: AppColors.onSurface,
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
