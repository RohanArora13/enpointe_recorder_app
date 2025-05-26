import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primaryRed = Color(0xFFE53E3E);
  static const Color primaryRedLight = Color(0xFFFC8181);
  static const Color primaryRedDark = Color(0xFFC53030);
  
  // Light theme color scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryRed,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFEBEE),
    onPrimaryContainer: Color(0xFF2D0A0A),
    secondary: Color(0xFF6B7280),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF3F4F6),
    onSecondaryContainer: Color(0xFF1F2937),
    tertiary: Color(0xFF059669),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFD1FAE5),
    onTertiaryContainer: Color(0xFF064E3B),
    error: Color(0xFFDC2626),
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: Colors.white,
    onSurface: Color(0xFF1F2937),
    surfaceContainerHighest: Color(0xFFF9FAFB),
    onSurfaceVariant: Color(0xFF6B7280),
    outline: Color(0xFFD1D5DB),
    outlineVariant: Color(0xFFE5E7EB),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1F2937),
    onInverseSurface: Color(0xFFF9FAFB),
    inversePrimary: primaryRedLight,
    surfaceTint: primaryRed,
    surfaceContainer: Color(0xFFF9FAFB),
    surfaceContainerLow: Color(0xFFFCFCFC),
    surfaceContainerLowest: Colors.white,
    surfaceContainerHigh: Color(0xFFF3F4F6),
  );

  // Dark theme color scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryRedLight,
    onPrimary: Color(0xFF2D0A0A),
    primaryContainer: primaryRedDark,
    onPrimaryContainer: Color(0xFFFFEBEE),
    secondary: Color(0xFF9CA3AF),
    onSecondary: Color(0xFF1F2937),
    secondaryContainer: Color(0xFF374151),
    onSecondaryContainer: Color(0xFFF3F4F6),
    tertiary: Color(0xFF34D399),
    onTertiary: Color(0xFF064E3B),
    tertiaryContainer: Color(0xFF065F46),
    onTertiaryContainer: Color(0xFFD1FAE5),
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    errorContainer: Color(0xFFB91C1C),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: Color(0xFF111827),
    onSurface: Color(0xFFF9FAFB),
    surfaceContainerHighest: Color(0xFF374151),
    onSurfaceVariant: Color(0xFF9CA3AF),
    outline: Color(0xFF6B7280),
    outlineVariant: Color(0xFF4B5563),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFF9FAFB),
    onInverseSurface: Color(0xFF1F2937),
    inversePrimary: primaryRed,
    surfaceTint: primaryRedLight,
    surfaceContainer: Color(0xFF1F2937),
    surfaceContainerLow: Color(0xFF0F172A),
    surfaceContainerLowest: Color(0xFF0C1017),
    surfaceContainerHigh: Color(0xFF374151),
  );

  // Audio visualizer colors for light theme
  static const Color lightVisualizerPrimary = primaryRed;
  static const Color lightVisualizerSecondary = primaryRedLight;
  static const Color lightVisualizerShadow = Color(0x40000000);

  // Audio visualizer colors for dark theme
  static const Color darkVisualizerPrimary = primaryRedLight;
  static const Color darkVisualizerSecondary = Color(0xFFFFB3B3);
  static const Color darkVisualizerShadow = Color(0x60000000);

  // Recording button colors
  static const Color recordingActiveLight = Color(0xFFDC2626);
  static const Color recordingInactiveLight = Color(0xFF6B7280);
  static const Color recordingActiveDark = Color(0xFFF87171);
  static const Color recordingInactiveDark = Color(0xFF9CA3AF);
}