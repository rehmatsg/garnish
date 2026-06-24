//
//  garnish_color_expansion.dart
//  GarnishExpansion (Flutter/Dart port)
//
//  Ported from the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'garnish_math.dart';

/// Handles color array expansion and contraction operations.
///
/// This corresponds to the optional `GarnishExpansion` module of the original
/// Swift package and is exposed via `package:garnish/garnish_expansion.dart`.
abstract final class GarnishColorExpansion {
  /// Fallback color used when a primary color cannot be selected.
  static const Color _fallback = Color(0xFF007AFF);

  // MARK: - Expansion

  /// Expands [colors] to [to] entries using the Harmonic Flow strategy,
  /// preserving family coherence.
  ///
  /// If [colors] already has at least [to] entries, it is contracted instead.
  static List<Color> expand(List<Color> colors, {required int to}) {
    if (colors.isEmpty || to <= 0) return <Color>[];

    if (colors.length >= to) {
      return contract(colors, to: to);
    }
    if (colors.length == 1) {
      return generateVariations(colors[0], count: to);
    }
    return _harmonicFlowExpansion(colors, to);
  }

  /// Contracts [colors] to [to] entries by intelligent sampling.
  static List<Color> contract(List<Color> colors, {required int to}) {
    if (to <= 0) return <Color>[];
    if (colors.length <= to) return colors;

    if (to == 1) {
      return [selectPrimaryColor(colors)];
    }

    final result = <Color>[];
    final step = (colors.length - 1) / (to - 1);
    for (var i = 0; i < to; i++) {
      final index = math.min((i * step).toInt(), colors.length - 1);
      result.add(colors[index]);
    }
    return result;
  }

  /// Selects the most representative color from [colors] (the median by
  /// luminance).
  static Color selectPrimaryColor(List<Color> colors) {
    if (colors.isEmpty) return _fallback;
    if (colors.length == 1) return colors.first;

    final withLuminance = colors
        .map((color) => (color, GarnishMath.relativeLuminance(color)))
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));

    return withLuminance[withLuminance.length ~/ 2].$1;
  }

  // MARK: - Expansion strategies

  /// Harmonic Flow: creates smooth transitions with subtle variations.
  static List<Color> _harmonicFlowExpansion(
    List<Color> sourceColors,
    int targetCount,
  ) {
    final baseRepeats = targetCount ~/ sourceColors.length;
    final remainder = targetCount % sourceColors.length;
    final result = <Color>[];

    for (var index = 0; index < sourceColors.length; index++) {
      final color = sourceColors[index];
      final repeatsForThisColor = baseRepeats + (index < remainder ? 1 : 0);

      if (repeatsForThisColor == 1) {
        result.add(color);
      } else {
        result.addAll(_generateSubtleVariations(color, repeatsForThisColor));
      }
    }
    return result;
  }

  /// Linear interpolation: a smooth gradient between [colors].
  static List<Color> linearInterpolation(
    List<Color> colors, {
    required int to,
  }) {
    if (colors.length <= 1 || to <= colors.length) {
      return expand(colors, to: to);
    }

    final result = <Color>[];
    final step = (colors.length - 1) / (to - 1);

    for (var i = 0; i < to; i++) {
      final position = i * step;
      final lowerIndex = position.toInt();
      final upperIndex = math.min(lowerIndex + 1, colors.length - 1);
      final fraction = position - lowerIndex;

      if (lowerIndex == upperIndex) {
        result.add(colors[lowerIndex]);
      } else {
        result.add(
          _interpolateColors(colors[lowerIndex], colors[upperIndex], fraction),
        );
      }
    }
    return result;
  }

  /// Simple repeat: cycles through [colors] until [to] entries are produced.
  static List<Color> simpleRepeat(List<Color> colors, {required int to}) {
    if (colors.isEmpty) return <Color>[];
    return List<Color>.generate(to, (i) => colors[i % colors.length]);
  }

  // MARK: - Variation generation

  /// Generates [count] harmonious variations of a single [color].
  static List<Color> generateVariations(Color color, {required int count}) {
    if (count <= 0) return <Color>[];
    if (count == 1) return [color];

    final hsb = HSVColor.fromColor(color);
    final result = <Color>[];

    for (var i = 0; i < count; i++) {
      final progress = i / (count - 1);

      // Harmonious variation across hue, saturation, and brightness.
      final hueShift = math.sin(progress * math.pi * 2) * 30; // ±30°
      final satShift = math.cos(progress * math.pi * 2) * 0.2; // ±20%
      final brightShift = math.sin(progress * math.pi * 3) * 0.2; // ±20%

      result.add(_hsv(
        hue: hsb.hue + hueShift,
        saturation: hsb.saturation + satShift,
        brightness: hsb.value + brightShift,
      ));
    }
    return result;
  }

  /// Generates [count] subtle variations used by Harmonic Flow expansion.
  static List<Color> _generateSubtleVariations(Color color, int count) {
    if (count <= 0) return <Color>[];
    if (count == 1) return [color];

    final hsb = HSVColor.fromColor(color);
    final result = <Color>[];

    for (var i = 0; i < count; i++) {
      final progress = i / (count - 1);

      final hueShift = (progress - 0.5) * 10; // ±5°
      final satShift = (progress - 0.5) * 0.1; // ±5%
      final brightShift = (progress - 0.5) * 0.1; // ±5%

      result.add(_hsv(
        hue: hsb.hue + hueShift,
        saturation: hsb.saturation + satShift,
        brightness: hsb.value + brightShift,
      ));
    }
    return result;
  }

  // MARK: - Helpers

  static Color _interpolateColors(Color color1, Color color2, double fraction) {
    final hsb1 = HSVColor.fromColor(color1);
    final hsb2 = HSVColor.fromColor(color2);

    final hue = _interpolateHue(hsb1.hue, hsb2.hue, fraction);
    final saturation =
        hsb1.saturation + (hsb2.saturation - hsb1.saturation) * fraction;
    final brightness = hsb1.value + (hsb2.value - hsb1.value) * fraction;

    return _hsv(hue: hue, saturation: saturation, brightness: brightness);
  }

  static double _interpolateHue(
    double startHue,
    double endHue,
    double progress,
  ) {
    final diff = endHue - startHue;
    // Take the shortest path around the hue wheel.
    final shortestDiff = ((diff + 180) % 360) - 180;
    return startHue + shortestDiff * progress;
  }

  /// Builds a color from HSB components, normalizing the hue into `[0, 360)`
  /// and clamping saturation/brightness. Brightness has a `0.2` floor to match
  /// the original implementation.
  static Color _hsv({
    required double hue,
    required double saturation,
    required double brightness,
  }) {
    var normalizedHue = hue % 360;
    if (normalizedHue < 0) normalizedHue += 360;

    final clampedSat = saturation.clamp(0.0, 1.0).toDouble();
    final clampedBright = brightness.clamp(0.2, 1.0).toDouble();

    return HSVColor.fromAHSV(1.0, normalizedHue, clampedSat, clampedBright)
        .toColor();
  }

  // MARK: - Specific use cases

  /// Expands a single [color] to a gradient mesh ([size] colors, 16 by
  /// default — a 4×4 mesh).
  static List<Color> expandToGradientMesh(Color color, {int size = 16}) =>
      generateVariations(color, count: size);

  /// Expands [colors] for gradient backgrounds (16 colors / 4×4 mesh).
  static List<Color> expandForGradient(List<Color> colors) =>
      expand(colors, to: 16);

  /// Contracts [colors] to a single solid color.
  static Color contractToSolid(List<Color> colors) =>
      selectPrimaryColor(colors);
}
