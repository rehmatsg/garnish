//
//  garnish_color.dart
//  Garnish (Flutter/Dart port)
//
//  Ported from the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

import 'package:flutter/widgets.dart';

/// RGBA color components, each channel normalized to the `0.0`–`1.0` range.
@immutable
class ColorComponents {
  /// Creates a set of RGBA components.
  const ColorComponents({
    required this.red,
    required this.green,
    required this.blue,
    required this.alpha,
  });

  /// The red channel (`0.0`–`1.0`).
  final double red;

  /// The green channel (`0.0`–`1.0`).
  final double green;

  /// The blue channel (`0.0`–`1.0`).
  final double blue;

  /// The alpha channel (`0.0`–`1.0`).
  final double alpha;

  @override
  bool operator ==(Object other) =>
      other is ColorComponents &&
      other.red == red &&
      other.green == green &&
      other.blue == blue &&
      other.alpha == alpha;

  @override
  int get hashCode => Object.hash(red, green, blue, alpha);

  @override
  String toString() =>
      'ColorComponents(red: $red, green: $green, blue: $blue, alpha: $alpha)';
}

/// Color manipulation utilities for advanced color operations.
///
/// Provides blending, brightness adjustment, hex conversion, and other color
/// transformation functions.
abstract final class GarnishColor {
  static const Color _transparent = Color(0x00000000);

  // MARK: - Color Blending

  /// Blends [color1] and [color2] together using a [ratio].
  ///
  /// A [ratio] of `0.0` returns 100% of [color1]; a ratio of `1.0` returns
  /// 100% of [color2].
  static Color blend(Color color1, Color color2, {required double ratio}) {
    final r = color1.r * (1 - ratio) + color2.r * ratio;
    final g = color1.g * (1 - ratio) + color2.g * ratio;
    final b = color1.b * (1 - ratio) + color2.b * ratio;
    final a = color1.a * (1 - ratio) + color2.a * ratio;
    return Color.from(alpha: a, red: r, green: g, blue: b);
  }

  // MARK: - Color Averaging

  /// Calculates the average color from a list of [colors].
  ///
  /// Returns a fully transparent color when [colors] is empty.
  static Color averageColor(List<Color> colors) {
    if (colors.isEmpty) return _transparent;

    var totalRed = 0.0;
    var totalGreen = 0.0;
    var totalBlue = 0.0;
    var totalAlpha = 0.0;

    for (final color in colors) {
      totalRed += color.r;
      totalGreen += color.g;
      totalBlue += color.b;
      totalAlpha += color.a;
    }

    final count = colors.length;
    return Color.from(
      alpha: totalAlpha / count,
      red: totalRed / count,
      green: totalGreen / count,
      blue: totalBlue / count,
    );
  }

  /// Extracts the RGBA [ColorComponents] from [color].
  static ColorComponents extractColorComponents(Color color) => ColorComponents(
        red: color.r,
        green: color.g,
        blue: color.b,
        alpha: color.a,
      );

  // MARK: - Brightness Adjustment

  /// Adjusts the brightness of [color] using RGB scaling.
  ///
  /// [by] is the adjustment amount (`-1.0` to `1.0`), where `0.0` means no
  /// change, positive values brighten, and negative values darken.
  static Color adjustBrightness(Color color, {required double by}) {
    final factor = 1.0 + by;
    return Color.from(
      alpha: color.a,
      red: _clamp01(color.r * factor),
      green: _clamp01(color.g * factor),
      blue: _clamp01(color.b * factor),
    );
  }

  /// Adjusts the luminance (HSB brightness/value) of [color] by [by].
  ///
  /// `0.0` means no change, positive values brighten, and negative values
  /// darken.
  static Color adjustLuminance(Color color, {required double by}) {
    final hsv = HSVColor.fromColor(color);
    final newValue = _clamp01(hsv.value + by);
    return hsv.withValue(newValue).toColor();
  }

  // MARK: - Color Conversion

  /// Converts [color] to its hexadecimal string representation.
  ///
  /// When [includeAlpha] is `true`, an 8-character `RRGGBBAA` string is
  /// returned; otherwise a 6-character `RRGGBB` string (e.g. `"FF0000"` for
  /// red).
  static String toHex(Color color, {bool includeAlpha = false}) {
    final r = _channelToInt(color.r);
    final g = _channelToInt(color.g);
    final b = _channelToInt(color.b);
    final a = _channelToInt(color.a);

    if (includeAlpha) {
      return '${_hex(r)}${_hex(g)}${_hex(b)}${_hex(a)}';
    }
    return '${_hex(r)}${_hex(g)}${_hex(b)}';
  }

  /// Creates a color from a hexadecimal string.
  ///
  /// Accepts strings with or without a leading `#`, supporting 3 (`RGB`),
  /// 6 (`RRGGBB`), or 8 (`RRGGBBAA`) hex digits. Returns `null` if the string
  /// is invalid.
  static Color? fromHex(String hex) {
    final sanitized = hex.trim().replaceAll('#', '');
    final value = int.tryParse(sanitized, radix: 16);
    if (value == null) return null;

    final double r, g, b, a;
    switch (sanitized.length) {
      case 3: // RGB
        r = ((value & 0xF00) >> 8) / 15.0;
        g = ((value & 0x0F0) >> 4) / 15.0;
        b = (value & 0x00F) / 15.0;
        a = 1.0;
      case 6: // RRGGBB
        r = ((value & 0xFF0000) >> 16) / 255.0;
        g = ((value & 0x00FF00) >> 8) / 255.0;
        b = (value & 0x0000FF) / 255.0;
        a = 1.0;
      case 8: // RRGGBBAA
        r = ((value & 0xFF000000) >> 24) / 255.0;
        g = ((value & 0x00FF0000) >> 16) / 255.0;
        b = ((value & 0x0000FF00) >> 8) / 255.0;
        a = (value & 0x000000FF) / 255.0;
      default:
        return null;
    }

    return Color.from(alpha: a, red: r, green: g, blue: b);
  }

  // MARK: - Internal helpers

  static double _clamp01(double v) => v.clamp(0.0, 1.0).toDouble();

  static int _channelToInt(double v) => (v * 255).round().clamp(0, 255).toInt();

  static String _hex(int value) =>
      value.toRadixString(16).padLeft(2, '0').toUpperCase();
}
