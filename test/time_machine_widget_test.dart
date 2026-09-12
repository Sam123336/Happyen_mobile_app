import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/city/domain/time_machine.dart';
import 'package:happyn_mobile/features/city/presentation/city_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('dragging the Time Machine knob lands on the nearest stop', (
    tester,
  ) async {
    final labels = timeMachineStops(DateTime.now()).map(stopLabel).toList();

    await tester.pumpWidget(
      ProviderScope(
        retry: retryOnce,
        child: MaterialApp(
          home: const Scaffold(body: CityScreen()),
          theme: buildHappynTheme(),
        ),
      ),
    );
    await tester.pump();

    Color? colourOf(String label) =>
        tester.widget<Text>(find.text(label)).style?.color;
    expect(colourOf(labels[0]), AppColors.secondary);
    expect(colourOf(labels[1]), AppColors.onSurfaceVariant);

    // The track is 720px wide here, so one stop is about 237px; a drag that
    // stops a little short of the second dot still snaps onto it.
    await tester.drag(find.text(labels[0]), const Offset(220, 0));
    await tester.pumpAndSettle();

    expect(colourOf(labels[1]), AppColors.secondary);
    expect(colourOf(labels[0]), AppColors.onSurfaceVariant);
  });
}
