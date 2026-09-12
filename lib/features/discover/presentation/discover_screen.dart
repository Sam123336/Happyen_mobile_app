import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/search/presentation/search_screen.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_screen.dart';

/// "Discover Feed": mood cards over an editorial grid of nearby events.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  static const _moods = <(String, String)>[
    ('Laugh', 'Comedy & Shows'),
    ('Dance', 'Clubs & Raves'),
    ('Explore', 'Arts & Culture'),
    ('Eat', 'Dining & Pop-ups'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.only(top: headerOffset(context, 96), bottom: 128),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.marginMobile, 32, 24, 0),
              child: _SoraHeading('What are you feeling?', height: 20 / 16),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 320,
              child: ListView.separated(
                itemBuilder: (context, index) => _MoodCard(
                  imageUrl: DemoImages.discover[1 + index],
                  subtitle: _moods[index].$2,
                  title: _moods[index].$1,
                ),
                itemCount: _moods.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.gutter),
              ),
            ),
            const SizedBox(height: 64),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SoraHeading('Happening around you'),
                      Text(
                        'SEE MAP',
                        style: AppText.bodyMd.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 0.1 * 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _FeaturedCard(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallCard(
                          distance: '1.2 mi away',
                          imageUrl: DemoImages.discover[8],
                          title: 'Secret Speakeasy',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gutter),
                      Expanded(
                        child: _SmallCard(
                          distance: '2.5 mi away',
                          imageUrl: DemoImages.discover[9],
                          title: 'Midnight Gallery Tour',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const Positioned(left: 0, right: 0, top: 0, child: _DiscoverHeader()),
      ],
    );
  }
}

/// The Stitch screens apply the Sora family without a size utility, so the
/// published design renders these headings at the inherited 16px.
class _SoraHeading extends StatelessWidget {
  const _SoraHeading(this.text, {this.height = 24 / 16});

  final double height;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.headlineMd.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: height,
      ),
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader();

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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileScreen(),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  height: 40,
                  width: 40,
                  child: ClipOval(child: NetImage(DemoImages.discover[0])),
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
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
                ),
                child: const SizedBox(
                  height: 40,
                  width: 40,
                  child: Icon(
                    Icons.location_on_outlined,
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

class _MoodCard extends StatelessWidget {
  const _MoodCard({
    required this.imageUrl,
    required this.subtitle,
    required this.title,
  });

  final String imageUrl;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: SizedBox(
        height: 320,
        width: 256,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  colors: [Color(0xCC131410), Color(0x00131410)],
                  end: Alignment.center,
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppText.headlineMd.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 24 / 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Frosted(
                    blur: 12,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    color: AppColors.surfaceContainer.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        subtitle,
                        style: AppText.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
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

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: AppColors.secondary.withValues(alpha: 0.2),
              spreadRadius: 4,
            ),
          ],
        ),
        height: 384,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetImage(DemoImages.discover[5]),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    colors: [Color(0xE60B0D12), Color(0x000B0D12)],
                    end: Alignment.center,
                  ),
                ),
              ),
              const Positioned(
                left: 24,
                top: 24,
                child: VerifiedBadge(label: 'Verified Here'),
              ),
              Positioned(
                right: 24,
                top: 24,
                child: PulseSlow(
                  child: Frosted(
                    blur: 12,
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    color: AppColors.surfaceContainer.withValues(alpha: 0.4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: EnergyPill.bare(label: 'High Vibe'),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Neon Nights Festival',
                          style: AppText.headlineMd.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 24 / 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.near_me,
                              color: AppColors.onSurfaceVariant,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '0.8 mi • Downtown',
                              style: AppText.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AvatarStack(
                      overflowLabel: '+5',
                      urls: DemoImages.discover.sublist(6, 8),
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

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.distance,
    required this.imageUrl,
    required this.title,
  });

  final String distance;
  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  colors: [Color(0xCC0B0D12), Color(0x000B0D12)],
                  end: Alignment.center,
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
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMd,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    distance,
                    overflow: TextOverflow.ellipsis,
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
    );
  }
}
