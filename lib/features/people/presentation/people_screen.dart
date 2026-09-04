import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/activity/presentation/activity_screen.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_screen.dart';
import 'package:happyn_mobile/features/event/presentation/event_detail_screen.dart';

/// "People — Social Layer": friends orbiting the events they are at.
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _FogBackground()),
        ListView(
          padding: EdgeInsets.only(
            top: headerOffset(context, 100),
            bottom: 128,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                32,
                AppSpacing.marginMobile,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Friends out now', style: AppText.headlineMd),
                  const SizedBox(height: 32),
                  const _FriendsHub(),
                  const SizedBox(height: 32),
                  const _FriendRow(),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Going tonight', style: AppText.headlineMd),
                      Text(
                        'View all',
                        style: AppText.labelMd.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _GoingTonightCard(),
                ],
              ),
            ),
          ],
        ),
        const Positioned(left: 0, right: 0, top: 0, child: _PeopleHeader()),
      ],
    );
  }
}

/// `radial-gradient(circle at 50% 0%, rgba(32,32,28,.8), rgba(11,13,18,1) 70%)`
class _FogBackground extends StatelessWidget {
  const _FogBackground();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            colors: [Color(0xCC20201C), Color(0xFF0B0D12)],
            radius: 1.1,
            stops: [0, 0.7],
          ),
        ),
      ),
    );
  }
}

class _PeopleHeader extends StatelessWidget {
  const _PeopleHeader();

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
          // The design lets the 264px headline run under the bell rather than
          // reflow, so the title keeps its two-line break.
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Row(
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
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      height: 40,
                      width: 40,
                      child: ClipOval(child: NetImage(DemoImages.people[0])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Exploring within 10km',
                      style: AppText.displayLg,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ActivityScreen(),
                  ),
                ),
                child: const SizedBox(
                  height: 40,
                  width: 40,
                  child: Icon(
                    Icons.notifications_outlined,
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

class _FriendsHub extends StatelessWidget {
  const _FriendsHub();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: AppColors.surfaceContainerLowest,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            OrbitRing(
              diameter: 300,
              ringColor: AppColors.outlineVariant.withValues(alpha: 0.1),
              satellites: [
                (0, _OrbitAvatar(size: 48, url: DemoImages.people[2])),
                (
                  0.5,
                  Opacity(
                    opacity: 0.8,
                    child: _OrbitAvatar(size: 40, url: DemoImages.people[3]),
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
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24,
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ],
                  shape: BoxShape.circle,
                ),
                height: 180,
                width: 180,
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetImage(DemoImages.people[1]),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [
                              AppColors.primaryContainer,
                              Color(0x000B0D12),
                            ],
                            end: Alignment.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: AppColors.tertiary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'VERY ACTIVE',
                                  style: AppText.labelSm.copyWith(
                                    color: AppColors.tertiary,
                                    letterSpacing: 0.1 * 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bangalore Comedy Night',
                              style: AppText.headlineSm.copyWith(height: 1.25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitAvatar extends StatelessWidget {
  const _OrbitAvatar({required this.size, required this.url});

  final double size;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x80000000))],
        shape: BoxShape.circle,
      ),
      height: size,
      width: size,
      child: ClipOval(child: NetImage(url)),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          SizedBox(
            height: 48,
            width: 48,
            child: ClipOval(child: NetImage(DemoImages.people[6])),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sarthak',
                  style: AppText.headlineSm.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    letterSpacing: -0.02 * 18,
                  ),
                ),
                Text(
                  'at Bangalore Comedy Night',
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    letterSpacing: 0.01 * 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward,
            color: AppColors.outlineVariant,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _GoingTonightCard extends StatelessWidget {
  const _GoingTonightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.05),
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: AppColors.surfaceContainerLow,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: SizedBox(
              height: 80,
              width: 80,
              child: NetImage(DemoImages.people[7]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Midnight Techno Set', style: AppText.headlineSm),
                const SizedBox(height: 8),
                AvatarStack(
                  borderColor: AppColors.surfaceContainerLow,
                  overflowLabel: '+3',
                  overlap: 8,
                  size: 24,
                  urls: DemoImages.people.sublist(8, 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
