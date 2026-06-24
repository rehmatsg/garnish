//
//  garnish_error.dart
//  Garnish (Flutter/Dart port)
//
//  Ported from the SwiftUI package Garnish by Aether.
//  https://github.com/Aeastr/Garnish
//
//  Licensed under the MIT License.
//

import 'package:flutter/widgets.dart';

/// The kind of failure represented by a [GarnishError].
enum GarnishErrorKind {
  /// Failed to extract color components from the provided color.
  colorComponentExtractionFailed,

  /// Failed to convert color to the required color space.
  colorSpaceConversionFailed,

  /// A required parameter was not provided.
  missingRequiredParameter,

  /// An invalid parameter value was provided.
  invalidParameter,

  /// A color calculation resulted in invalid values.
  invalidColorCalculation,
}

/// Errors that can occur during Garnish color operations.
///
/// This mirrors the `GarnishError` enum from the original Swift package. In
/// practice, Flutter's [Color] always exposes its components, so the
/// extraction/conversion cases are rarely thrown — they exist for parity and
/// for callers who construct stricter validation on top of Garnish.
@immutable
class GarnishError implements Exception {
  const GarnishError._(
    this.kind, {
    this.color,
    this.targetSpace,
    this.parameter,
    this.value,
    this.operation,
  });

  /// Failed to extract color components from [color].
  factory GarnishError.colorComponentExtractionFailed(Color color) =>
      GarnishError._(
        GarnishErrorKind.colorComponentExtractionFailed,
        color: color,
      );

  /// Failed to convert [color] to the [targetSpace] color space.
  factory GarnishError.colorSpaceConversionFailed(
    Color color, {
    required String targetSpace,
  }) =>
      GarnishError._(
        GarnishErrorKind.colorSpaceConversionFailed,
        color: color,
        targetSpace: targetSpace,
      );

  /// The required [parameter] was not provided.
  factory GarnishError.missingRequiredParameter(String parameter) =>
      GarnishError._(
        GarnishErrorKind.missingRequiredParameter,
        parameter: parameter,
      );

  /// An invalid [value] was provided for [parameter].
  factory GarnishError.invalidParameter(
    String parameter, {
    required Object? value,
  }) =>
      GarnishError._(
        GarnishErrorKind.invalidParameter,
        parameter: parameter,
        value: value,
      );

  /// A color calculation failed during [operation].
  factory GarnishError.invalidColorCalculation(String operation) =>
      GarnishError._(
        GarnishErrorKind.invalidColorCalculation,
        operation: operation,
      );

  /// The category of failure.
  final GarnishErrorKind kind;

  /// The color involved in the failure, when relevant.
  final Color? color;

  /// The target color space, for [GarnishErrorKind.colorSpaceConversionFailed].
  final String? targetSpace;

  /// The offending parameter name, when relevant.
  final String? parameter;

  /// The offending parameter value, when relevant.
  final Object? value;

  /// The operation that failed, when relevant.
  final String? operation;

  /// A human-readable description of what went wrong.
  String get errorDescription {
    switch (kind) {
      case GarnishErrorKind.colorComponentExtractionFailed:
        return 'Failed to extract color components from color: $color. '
            'The color may be in an unsupported format.';
      case GarnishErrorKind.colorSpaceConversionFailed:
        return 'Failed to convert color $color to $targetSpace color space.';
      case GarnishErrorKind.missingRequiredParameter:
        return "Required parameter '$parameter' was not provided.";
      case GarnishErrorKind.invalidParameter:
        return "Invalid value '$value' provided for parameter '$parameter'.";
      case GarnishErrorKind.invalidColorCalculation:
        return 'Color calculation failed during operation: $operation.';
    }
  }

  /// The underlying reason for the failure.
  String get failureReason {
    switch (kind) {
      case GarnishErrorKind.colorComponentExtractionFailed:
        return 'The color may be using a color space or format that is not '
            'supported for component extraction.';
      case GarnishErrorKind.colorSpaceConversionFailed:
        return 'The color could not be converted to the required color space '
            'for processing.';
      case GarnishErrorKind.missingRequiredParameter:
        return 'A required parameter was not provided to the function.';
      case GarnishErrorKind.invalidParameter:
        return 'The provided parameter value is outside the expected range or '
            'format.';
      case GarnishErrorKind.invalidColorCalculation:
        return 'The color calculation produced invalid or out-of-range values.';
    }
  }

  /// A suggestion for how to recover from the failure.
  String get recoverySuggestion {
    switch (kind) {
      case GarnishErrorKind.colorComponentExtractionFailed:
        return 'Try using a different color format or ensure the color is '
            'properly initialized.';
      case GarnishErrorKind.colorSpaceConversionFailed:
        return 'Ensure the color is compatible with RGB color space '
            'operations.';
      case GarnishErrorKind.missingRequiredParameter:
        return "Provide a valid value for the '$parameter' parameter.";
      case GarnishErrorKind.invalidParameter:
        return "Check the documentation for valid values for the '$parameter' "
            'parameter.';
      case GarnishErrorKind.invalidColorCalculation:
        return 'Check the input values and ensure they are within valid '
            'ranges.';
    }
  }

  @override
  String toString() => 'GarnishError: $errorDescription';
}
