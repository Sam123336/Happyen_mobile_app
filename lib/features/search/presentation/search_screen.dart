import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';

/// "Search & Filter — Precision Discovery".
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _filters = <String>[
    'Electric',
    'Underground',
    'Jazz',
    'Late Night',
    'Rooftop',
  ];
  static const _recent = <(String, String)>[
    ('The Blind Pig', 'Speakeasy • Soho'),
    ('Neon Dream', 'Club • Downtown'),
  ];

  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
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
                    const _SearchField(),
                    const SizedBox(height: 32),
                    const _SectionLabel('QUICK FILTERS'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) => _QuickFilter(
                          active: index == _filter,
                          label: _filters[index],
                          onTap: () => setState(() => _filter = index),
                        ),
                        itemCount: _filters.length,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _SectionLabel('RECENT SEARCHES'),
                    const SizedBox(height: 16),
                    for (final (title, subtitle) in _recent) ...[
                      _RecentRow(subtitle: subtitle, title: title),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 32),
                    const _SectionLabel('TRENDING DESTINATIONS'),
                    const SizedBox(height: 16),
                    _TrendingCard(
                      imageUrl: DemoImages.search[1],
                      subtitle: 'Underground Club • 0.5mi',
                      title: 'The Vault',
                      trailing: Row(
                        children: [
                          AvatarStack(
                            borderColor: AppColors.primaryContainer,
                            borderWidth: 1,
                            overlap: 8,
                            size: 20,
                            urls: DemoImages.search.sublist(2, 4),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Priya and 4 others here',
                            style: AppText.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _TrendingCard(
                      imageIndex: 4,
                      subtitle: 'Rooftop Lounge • 1.2mi',
                      title: 'The Edition',
                      trailing: _VerifiedChip(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _SearchHeader()),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 24,
      color: AppColors.surface.withValues(alpha: 0.4),
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
                child: const Icon(
                  Icons.menu,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              Text(
                'Happyen',
                style: AppText.displayLg.copyWith(letterSpacing: -0.05 * 40),
              ),
              SizedBox(
                height: 32,
                width: 32,
                child: ClipOval(child: NetImage(DemoImages.search[0])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        color: AppColors.surfaceContainer,
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: AppText.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          hintText: 'Search places, events, people...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.onSurfaceVariant,
            size: 24,
          ),
        ),
        style: AppText.bodyMd,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.labelMd.copyWith(
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.1 * 14,
      ),
    );
  }
}

class _QuickFilter extends StatelessWidget {
  const _QuickFilter({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: active
                ? AppColors.secondary.withValues(alpha: 0.5)
                : AppColors.outlineVariant.withValues(alpha: 0.3),
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
              : AppColors.surfaceContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          label,
          style: AppText.labelMd.copyWith(
            color: active ? AppColors.secondary : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.subtitle, required this.title});

  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          height: 40,
          width: 40,
          child: const Icon(
            Icons.history,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppText.bodyMd),
              Text(
                subtitle,
                style: AppText.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 16),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.subtitle,
    required this.title,
    required this.trailing,
    this.imageIndex,
    this.imageUrl,
  });

  final int? imageIndex;
  final String? imageUrl;
  final String subtitle;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 12,
      border: Border.all(
        color: AppColors.outlineVariant.withValues(alpha: 0.2),
      ),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      color: const Color(0x6620201C),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 96,
              child: NetImage(imageUrl ?? DemoImages.search[imageIndex ?? 0]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.headlineSm,
                          ),
                        ),
                        const Icon(
                          Icons.local_fire_department,
                          color: AppColors.secondary,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppText.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    trailing,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: AppColors.warmPaper,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: AppColors.deepInk, size: 12),
          const SizedBox(width: 4),
          Text(
            'VERIFIED',
            style: AppText.labelSm.copyWith(
              color: AppColors.deepInk,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.05 * 10,
            ),
          ),
        ],
      ),
    );
  }
}
