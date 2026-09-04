import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour ramp transcribed from the Stitch "Spatial Editorial" design system.
abstract final class AppColors {
  static const background = Color(0xFF131410);
  static const surface = Color(0xFF131410);
  static const surfaceDim = Color(0xFF131410);
  static const surfaceBright = Color(0xFF3A3935);
  static const surfaceContainerLowest = Color(0xFF0E0E0B);
  static const surfaceContainerLow = Color(0xFF1C1C18);
  static const surfaceContainer = Color(0xFF20201C);
  static const surfaceContainerHigh = Color(0xFF2A2A26);
  static const surfaceContainerHighest = Color(0xFF353530);
  static const surfaceVariant = Color(0xFF353530);

  static const onBackground = Color(0xFFE5E2DB);
  static const onSurface = Color(0xFFE5E2DB);
  static const onSurfaceVariant = Color(0xFFC7C6CB);
  static const inverseSurface = Color(0xFFE5E2DB);
  static const inverseOnSurface = Color(0xFF31312C);

  static const outline = Color(0xFF909095);
  static const outlineVariant = Color(0xFF46464B);
  static const surfaceTint = Color(0xFFC6C6CD);

  static const primary = Color(0xFFC6C6CD);
  static const onPrimary = Color(0xFF2E3036);
  static const primaryContainer = Color(0xFF0B0D12);
  static const onPrimaryContainer = Color(0xFF797A81);
  static const inversePrimary = Color(0xFF5D5E64);
  static const primaryFixed = Color(0xFFE2E2E9);
  static const primaryFixedDim = Color(0xFFC6C6CD);
  static const onPrimaryFixed = Color(0xFF1A1B21);
  static const onPrimaryFixedVariant = Color(0xFF45474D);

  static const secondary = Color(0xFFFFB4A7);
  static const onSecondary = Color(0xFF680300);
  static const secondaryContainer = Color(0xFF920800);
  static const onSecondaryContainer = Color(0xFFFF9A89);
  static const secondaryFixed = Color(0xFFFFDAD4);
  static const secondaryFixedDim = Color(0xFFFFB4A7);
  static const onSecondaryFixed = Color(0xFF400100);
  static const onSecondaryFixedVariant = Color(0xFF920800);

  static const tertiary = Color(0xFFA3D735);
  static const onTertiary = Color(0xFF243600);
  static const tertiaryContainer = Color(0xFF080F00);
  static const onTertiaryContainer = Color(0xFF608600);
  static const tertiaryFixed = Color(0xFFBEF450);
  static const tertiaryFixedDim = Color(0xFFA3D735);
  static const onTertiaryFixed = Color(0xFF141F00);
  static const onTertiaryFixedVariant = Color(0xFF364E00);

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  /// Brand literals the Stitch screens hard-code outside the token ramp.
  static const deepInk = Color(0xFF0B0D12);
  static const warmPaper = Color(0xFFF4F1EA);
}

/// Radii after Tailwind merges the Stitch `borderRadius` overrides with its
/// own defaults: only DEFAULT/lg/xl/full are overridden.
abstract final class AppRadius {
  static const sm = 2.0; // tailwind default rounded-sm
  static const md = 6.0; // tailwind default rounded-md
  static const base = 16.0; // rounded → 1rem
  static const xl2 = 16.0; // rounded-2xl → tailwind default 1rem
  static const lg = 32.0; // rounded-lg → 2rem
  static const xl = 48.0; // rounded-xl → 3rem
  static const full = 9999.0;
}

abstract final class AppSpacing {
  static const unit = 4.0;
  static const gutter = 16.0;
  static const marginMobile = 24.0;
  static const marginDesktop = 64.0;
  static const orbitSm = 80.0;
  static const orbitLg = 240.0;
}

/// Type ramp: Sora for display/headline, Inter for body/label.
abstract final class AppText {
  static TextStyle get displayXl => GoogleFonts.sora(
    color: AppColors.onSurface,
    fontSize: 52,
    fontWeight: FontWeight.w800,
    height: 56 / 52,
    letterSpacing: -0.04 * 52,
  );

  static TextStyle get displayLg => GoogleFonts.sora(
    color: AppColors.onSurface,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 44 / 40,
    letterSpacing: -0.03 * 40,
  );

  static TextStyle get headlineMd => GoogleFonts.sora(
    color: AppColors.onSurface,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  static TextStyle get headlineSm => GoogleFonts.sora(
    color: AppColors.onSurface,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static TextStyle get bodyLg => GoogleFonts.inter(
    color: AppColors.onSurface,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );

  static TextStyle get bodyMd => GoogleFonts.inter(
    color: AppColors.onSurface,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static TextStyle get labelMd => GoogleFonts.inter(
    color: AppColors.onSurface,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.05 * 14,
  );

  static TextStyle get labelSm => GoogleFonts.inter(
    color: AppColors.onSurface,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );
}

ThemeData buildHappynTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceDim: AppColors.surfaceDim,
    surfaceBright: AppColors.surfaceBright,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    inversePrimary: AppColors.inversePrimary,
    surfaceTint: AppColors.surfaceTint,
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: NoSplash.splashFactory,
    textTheme: TextTheme(
      displayLarge: AppText.displayXl,
      displayMedium: AppText.displayLg,
      headlineMedium: AppText.headlineMd,
      headlineSmall: AppText.headlineSm,
      bodyLarge: AppText.bodyLg,
      bodyMedium: AppText.bodyMd,
      labelLarge: AppText.labelMd,
      labelSmall: AppText.labelSm,
    ),
    useMaterial3: true,
  );
}
