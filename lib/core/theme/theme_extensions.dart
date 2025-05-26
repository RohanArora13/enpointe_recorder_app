import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AudioVisualizerTheme extends ThemeExtension<AudioVisualizerTheme> {
  const AudioVisualizerTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.shadowColor,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final Color shadowColor;

  @override
  AudioVisualizerTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? shadowColor,
  }) {
    return AudioVisualizerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  AudioVisualizerTheme lerp(AudioVisualizerTheme? other, double t) {
    if (other is! AudioVisualizerTheme) {
      return this;
    }
    return AudioVisualizerTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }

  static const AudioVisualizerTheme light = AudioVisualizerTheme(
    primaryColor: AppColors.lightVisualizerPrimary,
    secondaryColor: AppColors.lightVisualizerSecondary,
    shadowColor: AppColors.lightVisualizerShadow,
  );

  static const AudioVisualizerTheme dark = AudioVisualizerTheme(
    primaryColor: AppColors.darkVisualizerPrimary,
    secondaryColor: AppColors.darkVisualizerSecondary,
    shadowColor: AppColors.darkVisualizerShadow,
  );
}

@immutable
class RecordingButtonTheme extends ThemeExtension<RecordingButtonTheme> {
  const RecordingButtonTheme({
    required this.activeColor,
    required this.inactiveColor,
  });

  final Color activeColor;
  final Color inactiveColor;

  @override
  RecordingButtonTheme copyWith({
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return RecordingButtonTheme(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
    );
  }

  @override
  RecordingButtonTheme lerp(RecordingButtonTheme? other, double t) {
    if (other is! RecordingButtonTheme) {
      return this;
    }
    return RecordingButtonTheme(
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
    );
  }

  static const RecordingButtonTheme light = RecordingButtonTheme(
    activeColor: AppColors.recordingActiveLight,
    inactiveColor: AppColors.recordingInactiveLight,
  );

  static const RecordingButtonTheme dark = RecordingButtonTheme(
    activeColor: AppColors.recordingActiveDark,
    inactiveColor: AppColors.recordingInactiveDark,
  );
}

// Extension methods for easy access to theme extensions
extension ThemeExtensions on ThemeData {
  AudioVisualizerTheme get audioVisualizerTheme =>
      extension<AudioVisualizerTheme>() ?? AudioVisualizerTheme.light;

  RecordingButtonTheme get recordingButtonTheme =>
      extension<RecordingButtonTheme>() ?? RecordingButtonTheme.light;
}