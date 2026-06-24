//
//  garnish.dart
//  Garnish (Flutter/Dart port)
//
//  A Flutter/Dart port of the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

/// Garnish — intelligent color utilities for accessibility, contrast
/// optimization, and visual harmony.
///
/// This is a Flutter/Dart port of the SwiftUI package
/// [Garnish](https://github.com/Aeastr/Garnish) by Aether.
///
/// The core entry points are:
/// * [Garnish] — contrasting shade / color generation.
/// * [GarnishMath] — luminance, brightness, and contrast calculations.
/// * [GarnishColor] — blending, brightness adjustment, and hex conversion.
///
/// Convenience methods are also exposed directly on [Color] via extensions.
/// The optional color-array expansion utilities live in a separate library,
/// `package:garnish/garnish_expansion.dart`.
library;

export 'src/color_convenience_extensions.dart';
export 'src/color_extensions.dart';
export 'src/font_extensions.dart';
export 'src/garnish_base.dart';
export 'src/garnish_color.dart';
export 'src/garnish_error.dart';
export 'src/garnish_math.dart';
