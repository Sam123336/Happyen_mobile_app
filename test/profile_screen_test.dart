import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';
import 'package:happyn_mobile/features/profile/presentation/profile_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('shows the account, its handle and its streak', (tester) async {
    const profile = UserProfile(
      displayName: 'Sam Coder',
      emailVerified: false,
      momentsVisibility: PrivacyAudience.friends,
      presenceVisibility: PrivacyAudience.nobody,
      profileVisibility: PrivacyAudience.everyone,
      status: 'active',
      streakDays: 4,
      userId: 'user-1',
      username: 'sam',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentProfileProvider.overrideWith((ref) async => profile),
        ],
        child: MaterialApp(
          home: const ProfileScreen(),
          theme: buildHappynTheme(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Sam Coder'), findsOneWidget);
    expect(find.text('@sam'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('DAY CITY STREAK'), findsOneWidget);
    expect(find.text('EDIT PROFILE'), findsOneWidget);
  });
}
