import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/city/presentation/city_screen.dart';
import 'package:happyn_mobile/features/discover/presentation/discover_screen.dart';
import 'package:happyn_mobile/features/people/presentation/people_screen.dart';

/// Which of the three root tabs the shell is showing.
class SelectedTab extends Notifier<HappynTab> {
  @override
  HappynTab build() => HappynTab.city;

  // ignore: use_setters_to_change_properties
  void select(HappynTab tab) => state = tab;
}

final selectedTabProvider = NotifierProvider<SelectedTab, HappynTab>(
  SelectedTab.new,
);

/// CITY / DISCOVER / PEOPLE shell with the persistent bottom navigation.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: HappynTab.values.indexOf(tab),
              children: const [CityScreen(), DiscoverScreen(), PeopleScreen()],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HappynBottomNav(
              current: tab,
              onChanged: (next) =>
                  ref.read(selectedTabProvider.notifier).select(next),
            ),
          ),
        ],
      ),
    );
  }
}
