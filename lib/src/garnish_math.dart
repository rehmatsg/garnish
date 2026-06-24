//
//  garnish_math.dart
//  Garnish (Flutter/Dart port)
//
//  Ported from the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Method for calculating color brightness / luminance.
enum BrightnessMethod {
  /// WCAG 2.1 relative luminance calculation (recommended).
  luminance,

  /// Simple RGB averaging: `(r + g + b) / 3`.
  rgb,
}

/// Classification of a color as light or dark.
enum ColorClassification {
  /// A color that reads as light.
  light,

  /// A color that reads as dark.
  dark;

  /// The corresponding [Brightness].
  ///
  /// This is the Flutter equivalent of SwiftUI's `ColorScheme` — a [light]
  /// color maps to [Brightness.light] and a [dark] color to [Brightness.dark].
  Brightness get brightness =>
      this == ColorClassification.light ? Brightness.light : Brightness.dark;
}

/// Mathematical utilities for color analysis and contrast calculations.
///
/// Provides standardized, WCAG-compliant methods for luminance and contrast
/// calculations.
abstract final class GarnishMath {
  /// WCAG AA contrast ratio threshold (4.5:1).
  static const double wcagAAThreshold = 4.5;

  /// WCAG AAA contrast ratio threshold (7:1).
  static const double wcagAAAThreshold = 7.0;

  /// The default contrast threshold used throughout Garnish (WCAG AA).
  static const double defaultThreshold = wcagAAThreshold;

  // MARK: - Luminance Calculations

  /// Calculates the relative luminance of [color] using WCAG 2.1 standards.
  ///
  /// This is the recommended method for accessibility-compliant color
  /// analysis. Returns a value between `0.0` and `1.0`.
  ///
  /// ```dart
  /// final luminance = GarnishMath.relativeLuminance(Colors.blue);
  /// ```
  static double relativeLuminance(Color color) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  /// Calculates brightness using simple RGB averaging.
  ///
  /// Less accurate than [relativeLuminance] but faster for non-accessibility
  /// use cases. Returns a value between `0.0` and `1.0`.
  static double rgbBrightness(Color color) =>
      (color.r + color.g + color.b) / 3.0;

  /// Calculates brightness using the specified [method].
  ///
  /// Returns a value between `0.0` and `1.0`.
  static double brightness(
    Color color, {
    BrightnessMethod method = BrightnessMethod.luminance,
  }) {
    switch (method) {
      case BrightnessMethod.luminance:
        return relativeLuminance(color);
      case BrightnessMethod.rgb:
        return rgbBrightness(color);
    }
  }

  // MARK: - Contrast Calculations

  /// Computes the contrast ratio between [color1] and [color2] using
  /// WCAG 2.1 standards.
  ///
  /// The ratio is defined as `(L1 + 0.05) / (L2 + 0.05)`, where `L1` is the
  /// lighter color's luminance and `L2` is the darker color's luminance.
  ///
  /// ```dart
  /// final ratio = GarnishMath.contrastRatio(Colors.white, Colors.black);
  /// // Returns ~21.0 (maximum possible contrast)
  /// ```
  ///
  /// Returns a value between `1.0` and `21.0`, where higher is better contrast.
  static double contrastRatio(Color color1, Color color2) {
    final l1 = relativeLuminance(color1);
    final l2 = relativeLuminance(color2);
    final maxLum = math.max(l1, l2);
    final minLum = math.min(l1, l2);
    return (maxLum + 0.05) / (minLum + 0.05);
  }

  // MARK: - Color Classification

  /// Classifies [color] as [ColorClassification.light] or
  /// [ColorClassification.dark] based on its brightness.
  ///
  /// [threshold] is the brightness cutoff (default `0.5`).
  static ColorClassification classify(
    Color color, {
    double threshold = 0.5,
    BrightnessMethod method = BrightnessMethod.luminance,
  }) {
    final b = brightness(color, method: method);
    return b > threshold ? ColorClassification.light : ColorClassification.dark;
  }

  /// Determines the optimal [Brightness] for the given [color].
  ///
  /// This is the Flutter equivalent of SwiftUI's `colorScheme(for:)`.
  static Brightness colorScheme(
    Color color, {
    BrightnessMethod method = BrightnessMethod.luminance,
  }) {
    return classify(color, method: method).brightness;
  }

  // MARK: - Contrast Validation

  /// Returns `true` if [color1] and [color2] meet WCAG AA contrast
  /// requirements (ratio >= 4.5:1).
  static bool meetsWCAGAA(Color color1, Color color2) =>
      contrastRatio(color1, color2) >= wcagAAThreshold;

  /// Returns `true` if the given contrast [ratio] meets WCAG AA (>= 4.5:1).
  static bool ratioMeetsWCAGAA(double ratio) => ratio >= wcagAAThreshold;

  /// Returns `true` if [color1] and [color2] meet WCAG AAA contrast
  /// requirements (ratio >= 7:1).
  static bool meetsWCAGAAA(Color color1, Color color2) =>
      contrastRatio(color1, color2) >= wcagAAAThreshold;

  /// Returns `true` if the given contrast [ratio] meets WCAG AAA (>= 7:1).
  static bool ratioMeetsWCAGAAA(double ratio) => ratio >= wcagAAAThreshold;
}
