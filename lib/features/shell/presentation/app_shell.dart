import 'package:flutter/material.dart';

import 'package:happyn_mobile/features/city/presentation/city_screen.dart';

/// The city, and nothing else.
///
/// Discover and People were design shells from Stitch: hardcoded titles and
/// stock photography, no request to the backend at all. There are no endpoints
/// behind them either — the API serves health, auth, profile, events and
/// places, and nothing for moments, people, activity, tickets or vibe. A tab
/// that can only ever show invented content is worse than a missing tab, so
/// they are gone until something real backs them.
///
/// With one destination there is nothing to navigate between, so the bottom
/// navigation went with them.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) => const CityScreen();
}
