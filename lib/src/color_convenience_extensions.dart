//
//  color_convenience_extensions.dart
//  Garnish (Flutter/Dart port)
//
//  Ported from the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

import 'package:flutter/widgets.dart';

import 'garnish_base.dart';
import 'garnish_math.dart';

/// Garnish convenience methods added directly to [Color], mirroring the
/// static APIs on [Garnish] and [GarnishMath].
extension GarnishColorConvenience on Color {
  /// Returns a contrasting shade of this color that works well against itself.
  ///
  /// Equivalent to `Garnish.contrastingShade(this)`.
  Color contrastingShade() => Garnish.contrastingShade(this);

  /// Returns an optimized version of this color that works well against the
  /// [against] background.
  ///
  /// Equivalent to `Garnish.contrastingColor(this, against: against)`.
  Color optimized(
    Color against, {
    double targetRatio = GarnishMath.wcagAAThreshold,
  }) =>
      Garnish.contrastingColor(this,
          against: against, targetRatio: targetRatio);

  /// Classifies this color as light or dark.
  ///
  /// Equivalent to `GarnishMath.classify(this)`.
  ColorClassification classify({
    double threshold = 0.5,
    BrightnessMethod method = BrightnessMethod.luminance,
  }) =>
      GarnishMath.classify(this, threshold: threshold, method: method);

  /// Determines the optimal [Brightness] for this color.
  ///
  /// Equivalent to `GarnishMath.colorScheme(this)`.
  Brightness colorScheme(
          {BrightnessMethod method = BrightnessMethod.luminance}) =>
      GarnishMath.colorScheme(this, method: method);

  /// Calculates the relative luminance of this color using WCAG 2.1 standards.
  ///
  /// Equivalent to `GarnishMath.relativeLuminance(this)`.
  double relativeLuminance() => GarnishMath.relativeLuminance(this);

  /// Calculates the brightness of this color using the specified [method].
  ///
  /// Equivalent to `GarnishMath.brightness(this, method: method)`.
  double brightness({BrightnessMethod method = BrightnessMethod.luminance}) =>
      GarnishMath.brightness(this, method: method);

  /// Calculates the contrast ratio between this color and [other] using
  /// WCAG 2.1 standards.
  ///
  /// Equivalent to `GarnishMath.contrastRatio(this, other)`.
  double contrastRatio(Color other) => GarnishMath.contrastRatio(this, other);

  /// Whether this color meets WCAG AA contrast requirements against [other].
  ///
  /// Equivalent to `GarnishMath.meetsWCAGAA(this, other)`.
  bool meetsWCAGAA(Color other) => GarnishMath.meetsWCAGAA(this, other);

  /// Whether this color meets WCAG AAA contrast requirements against [other].
  ///
  /// Equivalent to `GarnishMath.meetsWCAGAAA(this, other)`.
  bool meetsWCAGAAA(Color other) => GarnishMath.meetsWCAGAAA(this, other);
}
