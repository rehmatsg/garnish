//
//  color_extensions.dart
//  Garnish (Flutter/Dart port)
//
//  Ported from the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

import 'package:flutter/widgets.dart';

import 'garnish_color.dart';

/// HSB (Hue, Saturation, Brightness) components of a color.
///
/// [hue] is expressed in degrees (`0`–`360`); [saturation] and [brightness]
/// are in the `0.0`–`1.0` range.
typedef HsbComponents = ({double hue, double saturation, double brightness});

/// Core color-manipulation conveniences added directly to [Color].
extension GarnishColorExtensions on Color {
  /// The HSB (Hue, Saturation, Brightness) components of this color.
  HsbComponents get hsb {
    final hsv = HSVColor.fromColor(this);
    return (hue: hsv.hue, saturation: hsv.saturation, brightness: hsv.value);
  }

  /// Adjusts the brightness of this color using RGB scaling.
  ///
  /// See [GarnishColor.adjustBrightness].
  Color adjustBrightness({required double by}) =>
      GarnishColor.adjustBrightness(this, by: by);

  /// Adjusts the luminance (HSB brightness) of this color.
  ///
  /// See [GarnishColor.adjustLuminance].
  Color adjustLuminance({required double by}) =>
      GarnishColor.adjustLuminance(this, by: by);

  /// The hexadecimal string representation of this color.
  ///
  /// When [includeAlpha] is `true`, an 8-character `RRGGBBAA` string is
  /// returned; otherwise a 6-character `RRGGBB` string.
  String toHex({bool includeAlpha = false}) =>
      GarnishColor.toHex(this, includeAlpha: includeAlpha);
}
