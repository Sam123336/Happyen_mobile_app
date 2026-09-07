import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/places/domain/place.dart';

/// "Search & Filter — Precision Discovery", backed by `GET /v1/places/search`.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _filters = <String>[
    'Electric',
    'Underground',
    'Jazz',
    'Late Night',
    'Rooftop',
  ];

  /// Long enough that typing a word is one request, short enough to feel live.
  static const _debounceDelay = Duration(milliseconds: 350);

  final _controller = TextEditingController();
  final _recent = <String>[];

  Timer? _debounce;
  int? _filter;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTyped(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => _search(value, filter: null));
  }

  void _search(String value, {required int? filter}) {
    if (!mounted) return;
    setState(() {
      _filter = filter;
      _query = value.trim();
      if (_query.isNotEmpty) {
        _recent
          ..remove(_query)
          ..insert(0, _query);
        if (_recent.length > 5) _recent.removeLast();
      }
    });
  }

  void _searchFor(String value, {int? filter}) {
    _debounce?.cancel();
    _controller.text = value;
    _search(value, filter: filter);
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(placeSearchProvider(_query));

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
                    _SearchField(
                      controller: _controller,
                      onChanged: _onTyped,
                      onSubmitted: (value) => _searchFor(value),
                    ),
                    const SizedBox(height: 32),
                    const _SectionLabel('QUICK FILTERS'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) => _QuickFilter(
                          active: index == _filter,
                          label: _filters[index],
                          onTap: () => index == _filter
                              ? _searchFor('')
                              : _searchFor(_filters[index], filter: index),
                        ),
                        itemCount: _filters.length,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                      ),
                    ),
                    if (_recent.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const _SectionLabel('RECENT SEARCHES'),
                      const SizedBox(height: 16),
                      for (final term in _recent) ...[
                        _RecentRow(
                          onRemove: () => setState(() => _recent.remove(term)),
                          onTap: () => _searchFor(term),
                          title: term,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    const SizedBox(height: 32),
                    _SectionLabel(_query.isEmpty ? 'NEARBY NOW' : 'RESULTS'),
                    const SizedBox(height: 16),
                    results.when(
                      data: (places) => places.isEmpty
                          ? const _SearchMessage('Nothing here yet.')
                          : Column(
                              children: [
                                for (final place in places) ...[
                                  _PlaceCard(place: place),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                      error: (_, _) => const _SearchMessage(
                        'Places are unavailable right now.',
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _PoweredByFoursquare(),
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
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        color: AppColors.surfaceContainer,
      ),
      child: TextField(
        controller: controller,
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
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: AppText.bodyMd,
        textInputAction: TextInputAction.search,
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

class _SearchMessage extends StatelessWidget {
  const _SearchMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        text,
        style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

/// Foursquare's API licence requires branded attribution on every screen where
/// their Places Data can appear.
class _PoweredByFoursquare extends StatelessWidget {
  const _PoweredByFoursquare();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Powered by Foursquare',
      style: AppText.labelSm.copyWith(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
        fontSize: 10,
        letterSpacing: 0.05 * 10,
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
  const _RecentRow({
    required this.onRemove,
    required this.onTap,
    required this.title,
  });

  final VoidCallback onRemove;
  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
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
                  'Recent search',
                  style: AppText.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              color: AppColors.onSurfaceVariant,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final Place place;

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
              child: place.photoUrl == null
                  ? const ColoredBox(color: AppColors.surfaceContainer)
                  : NetImage(place.photoUrl!),
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
                            place.name,
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
                    if (place.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        place.subtitle,
                        style: AppText.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (place.address != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        place.address!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
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
