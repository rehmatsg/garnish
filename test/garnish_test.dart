import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garnish/garnish.dart';
import 'package:garnish/garnish_expansion.dart';

const white = Color(0xFFFFFFFF);
const black = Color(0xFF000000);
const red = Color(0xFFFF0000);
const green = Color(0xFF00FF00);
const blue = Color(0xFF0000FF);
const grey = Color(0xFF808080);

void main() {
  group('GarnishMath', () {
    test('relative luminance of white is 1 and black is 0', () {
      expect(GarnishMath.relativeLuminance(white), closeTo(1.0, 1e-9));
      expect(GarnishMath.relativeLuminance(black), closeTo(0.0, 1e-9));
    });

    test('contrast ratio between white and black is ~21', () {
      expect(GarnishMath.contrastRatio(white, black), closeTo(21.0, 1e-6));
    });

    test('contrast ratio is symmetric', () {
      expect(
        GarnishMath.contrastRatio(red, blue),
        closeTo(GarnishMath.contrastRatio(blue, red), 1e-9),
      );
    });

    test('rgb brightness averages the channels', () {
      expect(
        GarnishMath.brightness(red, method: BrightnessMethod.rgb),
        closeTo(1 / 3, 1e-9),
      );
      expect(
        GarnishMath.brightness(white, method: BrightnessMethod.rgb),
        closeTo(1.0, 1e-9),
      );
    });

    test('classify distinguishes light and dark', () {
      expect(GarnishMath.classify(white), ColorClassification.light);
      expect(GarnishMath.classify(black), ColorClassification.dark);
      expect(white.classify(), ColorClassification.light);
    });

    test('colorScheme maps to Brightness', () {
      expect(GarnishMath.colorScheme(white), Brightness.light);
      expect(GarnishMath.colorScheme(black), Brightness.dark);
      expect(ColorClassification.light.brightness, Brightness.light);
    });

    test('WCAG thresholds', () {
      expect(GarnishMath.meetsWCAGAA(white, black), isTrue);
      expect(GarnishMath.meetsWCAGAAA(white, black), isTrue);
      expect(GarnishMath.meetsWCAGAA(grey, grey), isFalse);
      expect(GarnishMath.ratioMeetsWCAGAA(4.5), isTrue);
      expect(GarnishMath.ratioMeetsWCAGAA(4.4), isFalse);
      expect(GarnishMath.ratioMeetsWCAGAAA(7.0), isTrue);
      expect(GarnishMath.ratioMeetsWCAGAAA(6.9), isFalse);
    });
  });

  group('GarnishColor', () {
    test('blend endpoints and midpoint', () {
      expect(
          GarnishColor.blend(red, blue, ratio: 0.0).toARGB32(), red.toARGB32());
      expect(GarnishColor.blend(red, blue, ratio: 1.0).toARGB32(),
          blue.toARGB32());

      final mid = GarnishColor.blend(red, blue, ratio: 0.5);
      expect(mid.r, closeTo(0.5, 1e-6));
      expect(mid.g, closeTo(0.0, 1e-6));
      expect(mid.b, closeTo(0.5, 1e-6));
    });

    test('averageColor of red, green, blue', () {
      final avg = GarnishColor.averageColor([red, green, blue]);
      expect(avg.r, closeTo(1 / 3, 1e-6));
      expect(avg.g, closeTo(1 / 3, 1e-6));
      expect(avg.b, closeTo(1 / 3, 1e-6));
    });

    test('averageColor of empty list is transparent', () {
      expect(GarnishColor.averageColor(const []).a, 0.0);
    });

    test('extractColorComponents', () {
      final c = GarnishColor.extractColorComponents(red);
      expect(c.red, closeTo(1.0, 1e-9));
      expect(c.green, closeTo(0.0, 1e-9));
      expect(c.blue, closeTo(0.0, 1e-9));
      expect(c.alpha, closeTo(1.0, 1e-9));
    });

    test('adjustBrightness brightens and darkens', () {
      final brighter = GarnishColor.adjustBrightness(grey, by: 0.5);
      final darker = GarnishColor.adjustBrightness(grey, by: -0.5);
      expect(brighter.r, greaterThan(grey.r));
      expect(darker.r, lessThan(grey.r));
      // Channels stay clamped within range.
      final clamped = GarnishColor.adjustBrightness(white, by: 1.0);
      expect(clamped.r, lessThanOrEqualTo(1.0));
    });

    test('adjustLuminance brightens and darkens', () {
      expect(GarnishColor.adjustLuminance(grey, by: 0.3).computeLuminance(),
          greaterThan(grey.computeLuminance()));
      expect(GarnishColor.adjustLuminance(grey, by: -0.3).computeLuminance(),
          lessThan(grey.computeLuminance()));
    });

    test('toHex', () {
      expect(GarnishColor.toHex(red), 'FF0000');
      expect(GarnishColor.toHex(green), '00FF00');
      expect(GarnishColor.toHex(blue), '0000FF');
      expect(GarnishColor.toHex(red, includeAlpha: true), 'FF0000FF');
    });

    test('fromHex parses 3, 6 and 8 digit strings', () {
      expect(GarnishColor.fromHex('#F00')!.toARGB32(), red.toARGB32());
      expect(GarnishColor.fromHex('FF0000')!.toARGB32(), red.toARGB32());
      expect(GarnishColor.fromHex('#FF0000FF')!.toARGB32(), red.toARGB32());
      expect(GarnishColor.fromHex('00FF00')!.toARGB32(), green.toARGB32());
    });

    test('fromHex returns null for invalid input', () {
      expect(GarnishColor.fromHex('nope'), isNull);
      expect(GarnishColor.fromHex('12345'), isNull); // unsupported length
    });

    test('toHex / fromHex round-trip', () {
      const original = Color(0xFF3A7BD5);
      final hex = GarnishColor.toHex(original);
      expect(GarnishColor.fromHex(hex)!.toARGB32(), original.toARGB32());
    });
  });

  group('Garnish core', () {
    test('returns the original color when contrast is already sufficient', () {
      expect(
        Garnish.contrastingColor(white, against: black).toARGB32(),
        white.toARGB32(),
      );
    });

    test('improves contrast for a low-contrast pair', () {
      final result = Garnish.contrastingColor(grey, against: grey);
      final ratio = GarnishMath.contrastRatio(result, grey);
      expect(ratio, greaterThan(GarnishMath.contrastRatio(grey, grey)));
      expect(ratio, greaterThanOrEqualTo(GarnishMath.wcagAAThreshold - 0.1));
    });

    test('contrastingShade equals contrastingColor against itself', () {
      expect(
        Garnish.contrastingShade(blue).toARGB32(),
        Garnish.contrastingColor(blue, against: blue).toARGB32(),
      );
    });

    test('forceLight and forceDark bias the result', () {
      final lighter = Garnish.contrastingColor(
        grey,
        against: grey,
        direction: ContrastDirection.forceLight,
      );
      final darker = Garnish.contrastingColor(
        grey,
        against: grey,
        direction: ContrastDirection.forceDark,
      );
      expect(
          lighter.computeLuminance(), greaterThan(darker.computeLuminance()));
    });

    test('blendStyle.maximum yields a fully blended base', () {
      final result = Garnish.contrastingColor(
        grey,
        against: grey,
        direction: ContrastDirection.forceDark,
        blendStyle: BlendStyle.maximum,
      );
      expect(result.toARGB32(), black.toARGB32());
    });

    test('hasGoodContrast', () {
      expect(Garnish.hasGoodContrast(white, black), isTrue);
      expect(Garnish.hasGoodContrast(grey, grey), isFalse);
    });

    test('BlendStyle minimum blend values', () {
      expect(BlendStyle.minimal.minimumBlend, 0.0);
      expect(BlendStyle.moderate.minimumBlend, 0.5);
      expect(BlendStyle.strong.minimumBlend, 0.7);
      expect(BlendStyle.maximum.minimumBlend, 1.0);
    });
  });

  group('Color extensions', () {
    test('hsb components', () {
      final hsb = red.hsb;
      expect(hsb.hue, closeTo(0.0, 1e-6));
      expect(hsb.saturation, closeTo(1.0, 1e-6));
      expect(hsb.brightness, closeTo(1.0, 1e-6));
    });

    test('convenience methods mirror the static API', () {
      expect(red.relativeLuminance(),
          closeTo(GarnishMath.relativeLuminance(red), 1e-9));
      expect(white.contrastRatio(black), closeTo(21.0, 1e-6));
      expect(white.meetsWCAGAA(black), isTrue);
      expect(white.meetsWCAGAAA(black), isTrue);
      expect(white.toHex(), 'FFFFFF');
      expect(blue.optimized(blue).toARGB32(),
          Garnish.contrastingColor(blue, against: blue).toARGB32());
      expect(blue.contrastingShade().toARGB32(),
          Garnish.contrastingShade(blue).toARGB32());
    });

    test('recommendedFontWeight responds to contrast', () {
      // Very low contrast -> heaviest weight.
      expect(
        grey.recommendedFontWeight(against: grey),
        FontWeight.w600,
      );
      // High contrast -> lightest weight.
      expect(
        black.recommendedFontWeight(against: white),
        FontWeight.w400,
      );
    });

    test('recommendedFontWeight throws on empty range', () {
      expect(
        () => black.recommendedFontWeight(against: white, fontWeightRange: []),
        throwsA(isA<GarnishError>()),
      );
    });
  });

  group('GarnishColorExpansion', () {
    test('expand grows a palette to the target size', () {
      final palette = GarnishColorExpansion.expand([blue, red], to: 8);
      expect(palette, hasLength(8));
    });

    test('expand of a single color generates variations', () {
      expect(GarnishColorExpansion.expand([blue], to: 5), hasLength(5));
    });

    test('contract shrinks a palette', () {
      final source = [red, green, blue, white, black];
      expect(GarnishColorExpansion.contract(source, to: 3), hasLength(3));
    });

    test('selectPrimaryColor returns the only color when length is 1', () {
      expect(GarnishColorExpansion.selectPrimaryColor([green]).toARGB32(),
          green.toARGB32());
    });

    test('simpleRepeat cycles through the colors', () {
      final result = GarnishColorExpansion.simpleRepeat([red, blue], to: 5);
      expect(result.map((c) => c.toARGB32()).toList(), [
        red.toARGB32(),
        blue.toARGB32(),
        red.toARGB32(),
        blue.toARGB32(),
        red.toARGB32(),
      ]);
    });

    test('linearInterpolation produces the requested count', () {
      expect(
        GarnishColorExpansion.linearInterpolation([red, blue], to: 6),
        hasLength(6),
      );
    });

    test('generateVariations and gradient helpers', () {
      expect(GarnishColorExpansion.generateVariations(blue, count: 1), [blue]);
      expect(GarnishColorExpansion.generateVariations(blue, count: 4),
          hasLength(4));
      expect(GarnishColorExpansion.expandToGradientMesh(blue), hasLength(16));
      expect(
          GarnishColorExpansion.expandForGradient([blue, red]), hasLength(16));
    });

    test('contractToSolid returns a single color', () {
      final solid = GarnishColorExpansion.contractToSolid([red, green, blue]);
      expect([red, green, blue].map((c) => c.toARGB32()),
          contains(solid.toARGB32()));
    });

    test('empty / non-positive inputs are handled gracefully', () {
      expect(GarnishColorExpansion.expand([], to: 5), isEmpty);
      expect(GarnishColorExpansion.expand([blue], to: 0), isEmpty);
      expect(GarnishColorExpansion.simpleRepeat([], to: 3), isEmpty);
    });
  });
}
