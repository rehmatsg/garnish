//
//  font_extensions.dart
//  Garnish (Flutter/Dart port)
//
//  Ported from the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

import 'package:flutter/widgets.dart';

import 'garnish_error.dart';
import 'garnish_math.dart';

/// Font-weight recommendations based on contrast, added directly to [Color].
extension GarnishFontExtensions on Color {
  /// Recommends an appropriate [FontWeight] for this color when used as text
  /// on the [against] background.
  ///
  /// Lower contrast yields a heavier weight to preserve readability:
  /// * contrast `< 3.0` → the heaviest weight in [fontWeightRange]
  /// * contrast `< 4.5` (WCAG AA) → the middle weight
  /// * otherwise → the lightest weight
  ///
  /// [fontWeightRange] defaults to `[FontWeight.w400, FontWeight.w600]`
  /// (regular and semibold).
  ///
  /// Throws a [GarnishError] if [fontWeightRange] is empty.
  FontWeight recommendedFontWeight({
    required Color against,
    List<FontWeight> fontWeightRange = const [FontWeight.w400, FontWeight.w600],
    bool debugStatements = false,
  }) {
    if (fontWeightRange.isEmpty) {
      throw GarnishError.invalidParameter(
        'fontWeightRange',
        value: fontWeightRange,
      );
    }

    final contrast = GarnishMath.contrastRatio(this, against);

    if (debugStatements) {
      debugPrint(
        '[Garnish] Background: $against, Foreground: $this, Contrast: $contrast',
      );
    }

    const heavyWeightThreshold = 3.0;
    const lightWeightThreshold = GarnishMath.wcagAAThreshold;

    if (contrast < heavyWeightThreshold) {
      return fontWeightRange.last;
    } else if (contrast < lightWeightThreshold) {
      return fontWeightRange[fontWeightRange.length ~/ 2];
    } else {
      return fontWeightRange.first;
    }
  }
}
