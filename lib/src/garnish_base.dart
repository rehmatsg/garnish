//
//  garnish_base.dart
//  Garnish (Flutter/Dart port)
//
//  Ported from the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

import 'package:flutter/widgets.dart';

import 'garnish_color.dart';
import 'garnish_math.dart';

/// Direction to bias contrasting-color generation.
enum ContrastDirection {
  /// Automatically choose between light and dark based on which provides
  /// better contrast.
  auto,

  /// Force towards white / lighter shades (useful for highlights).
  forceLight,

  /// Force towards black / darker shades (useful for shadows).
  forceDark,

  /// Prefer lighter shades, switching to dark only if necessary to meet the
  /// target contrast.
  preferLight,

  /// Prefer darker shades, switching to light only if necessary to meet the
  /// target contrast.
  preferDark,
}

/// Blend intensity presets controlling how strongly colors are adjusted.
enum BlendStyle {
  /// Minimal blending — just enough to meet the target contrast.
  minimal(0.0),

  /// Moderate blending — at least 50% blend towards the chosen direction.
  moderate(0.5),

  /// Strong blending — at least 70% blend towards the chosen direction.
  strong(0.7),

  /// Maximum blending — always 100% blend (pure white or black).
  maximum(1.0);

  const BlendStyle(this.minimumBlend);

  /// The minimum blend amount associated with this style.
  final double minimumBlend;
}

/// A closed range of blend amounts, `[min, max]`, used to constrain the
/// blend search performed by [Garnish.contrastingColor].
typedef BlendRange = ({double min, double max});

/// **Garnish** — clean, simple color contrast utilities.
///
/// Provides two main functions:
/// 1. **Monochromatic contrast** ([contrastingShade]) — find a good shade of
///    the same color.
/// 2. **Bi-chromatic contrast** ([contrastingColor]) — optimize one color
///    against another.
///
/// All calculations use WCAG-compliant standards for accessibility.
abstract final class Garnish {
  static const Color _black = Color(0xFF000000);
  static const Color _white = Color(0xFFFFFFFF);

  // MARK: - Core API

  /// Generates a contrasting shade of the same [color] that meets WCAG
  /// standards.
  ///
  /// **Use case:** "I have blue, give me a shade of blue that looks good
  /// against blue."
  ///
  /// ```dart
  /// final contrastingBlue = Garnish.contrastingShade(Colors.blue);
  /// final shadowBlue =
  ///     Garnish.contrastingShade(Colors.blue, direction: ContrastDirection.forceDark);
  /// final strongWhite =
  ///     Garnish.contrastingShade(Colors.blue, blendStyle: BlendStyle.strong);
  /// final customBlend = Garnish.contrastingShade(Colors.blue, minimumBlend: 0.6);
  /// ```
  ///
  /// - [method]: brightness calculation method (default
  ///   [BrightnessMethod.luminance]).
  /// - [targetRatio]: minimum contrast ratio to achieve (default WCAG AA).
  /// - [direction]: direction preference (default [ContrastDirection.auto]).
  /// - [minimumBlend]: minimum blend amount (0.0–1.0). Overrides [blendStyle].
  /// - [blendStyle]: preset blend intensity.
  /// - [blendRange]: full control over the blend range. Overrides
  ///   [minimumBlend] and [blendStyle].
  static Color contrastingShade(
    Color color, {
    BrightnessMethod method = BrightnessMethod.luminance,
    double targetRatio = GarnishMath.defaultThreshold,
    ContrastDirection direction = ContrastDirection.auto,
    double? minimumBlend,
    BlendStyle? blendStyle,
    BlendRange? blendRange,
  }) {
    // contrastingShade is just contrastingColor against itself.
    return contrastingColor(
      color,
      against: color,
      method: method,
      targetRatio: targetRatio,
      direction: direction,
      minimumBlend: minimumBlend,
      blendStyle: blendStyle,
      blendRange: blendRange,
    );
  }

  /// Optimizes [color] to work well against the [against] background.
  ///
  /// **Use case:** "I have blue and red, which version of red looks best
  /// against blue?"
  ///
  /// ```dart
  /// final optimizedRed = Garnish.contrastingColor(Colors.red, against: Colors.blue);
  /// ```
  ///
  /// If the current contrast already meets [targetRatio], [color] is returned
  /// unchanged. See [contrastingShade] for the meaning of the remaining
  /// parameters.
  static Color contrastingColor(
    Color color, {
    required Color against,
    BrightnessMethod method = BrightnessMethod.luminance,
    double targetRatio = GarnishMath.defaultThreshold,
    ContrastDirection direction = ContrastDirection.auto,
    double? minimumBlend,
    BlendStyle? blendStyle,
    BlendRange? blendRange,
  }) {
    final background = against;

    // If contrast is already sufficient, return the original color.
    final currentRatio = GarnishMath.contrastRatio(color, background);
    if (currentRatio >= targetRatio) {
      return color;
    }

    // Determine the base color (black or white) to blend with.
    final contrastingBase = _determineContrastingBase(
      color: color,
      background: background,
      direction: direction,
      targetRatio: targetRatio,
    );

    // Determine the blend range to search within.
    final searchRange = _determineBlendRange(
      blendRange: blendRange,
      minimumBlend: minimumBlend,
      blendStyle: blendStyle,
    );

    // Binary search for the blend amount that achieves the target contrast.
    final bestBlend = _findOptimalBlend(
      color: color,
      contrastingBase: contrastingBase,
      background: background,
      targetRatio: targetRatio,
      searchRange: searchRange,
    );

    return GarnishColor.blend(color, contrastingBase, ratio: bestBlend);
  }

  /// Quick accessibility check.
  ///
  /// Returns `true` if [color1] and [color2] meet WCAG AA standards.
  static bool hasGoodContrast(Color color1, Color color2) =>
      GarnishMath.meetsWCAGAA(color1, color2);

  // MARK: - Private Helpers

  static Color _determineContrastingBase({
    required Color color,
    required Color background,
    required ContrastDirection direction,
    required double targetRatio,
  }) {
    switch (direction) {
      case ContrastDirection.forceDark:
        return _black;
      case ContrastDirection.forceLight:
        return _white;
      case ContrastDirection.auto:
        final fullyBlack = GarnishColor.blend(color, _black, ratio: 1.0);
        final fullyWhite = GarnishColor.blend(color, _white, ratio: 1.0);
        final maxBlackRatio = GarnishMath.contrastRatio(fullyBlack, background);
        final maxWhiteRatio = GarnishMath.contrastRatio(fullyWhite, background);
        return maxBlackRatio > maxWhiteRatio ? _black : _white;
      case ContrastDirection.preferLight:
      case ContrastDirection.preferDark:
        final preferredBase =
            direction == ContrastDirection.preferLight ? _white : _black;
        final alternateBase =
            direction == ContrastDirection.preferLight ? _black : _white;
        final fullyBlended =
            GarnishColor.blend(color, preferredBase, ratio: 1.0);
        final maxRatio = GarnishMath.contrastRatio(fullyBlended, background);
        return maxRatio >= targetRatio ? preferredBase : alternateBase;
    }
  }

  static BlendRange _determineBlendRange({
    required BlendRange? blendRange,
    required double? minimumBlend,
    required BlendStyle? blendStyle,
  }) {
    if (blendRange != null) return blendRange;
    if (minimumBlend != null) return (min: minimumBlend, max: 1.0);
    if (blendStyle != null) return (min: blendStyle.minimumBlend, max: 1.0);
    return (min: 0.0, max: 1.0);
  }

  static double _findOptimalBlend({
    required Color color,
    required Color contrastingBase,
    required Color background,
    required double targetRatio,
    required BlendRange searchRange,
  }) {
    var lowBlend = searchRange.min;
    var highBlend = searchRange.max;
    var bestBlend = 0.0;
    var bestRatio = 0.0;
    const maxIterations = 5;

    for (var i = 0; i < maxIterations; i++) {
      final testBlend = (lowBlend + highBlend) / 2.0;
      final testColor =
          GarnishColor.blend(color, contrastingBase, ratio: testBlend);
      final testRatio = GarnishMath.contrastRatio(testColor, background);

      if (testRatio >= targetRatio &&
          (bestRatio < targetRatio || testBlend < bestBlend)) {
        bestBlend = testBlend;
        bestRatio = testRatio;
      }

      if (testRatio >= targetRatio) {
        highBlend = testBlend;
      } else {
        lowBlend = testBlend;
        if (bestRatio < targetRatio) {
          bestBlend = testBlend;
          bestRatio = testRatio;
        }
      }

      if (bestRatio >= targetRatio && (bestRatio - targetRatio).abs() < 0.05) {
        break;
      }
    }

    return bestBlend;
  }
}
