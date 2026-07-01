# Core API

A reference for the main Garnish APIs. For an introduction, see
[Getting Started](Getting-Started.md).

```dart
import 'package:garnish/garnish.dart';
// Optional palette utilities:
import 'package:garnish/garnish_expansion.dart';
```

---

## `Garnish`

The high-level entry point for contrast-aware color generation.

### `contrastingShade`

```dart
static Color contrastingShade(
  Color color, {
  BrightnessMethod method = BrightnessMethod.luminance,
  double targetRatio = GarnishMath.defaultThreshold,
  ContrastDirection direction = ContrastDirection.auto,
  double? minimumBlend,
  BlendStyle? blendStyle,
  BlendRange? blendRange,
})
```

Generates a contrasting shade of the *same* color that meets WCAG standards.

```dart
final shade = Garnish.contrastingShade(Colors.blue);
final shadow = Garnish.contrastingShade(Colors.blue, direction: ContrastDirection.forceDark);
```

### `contrastingColor`

```dart
static Color contrastingColor(
  Color color, {
  required Color against,
  BrightnessMethod method = BrightnessMethod.luminance,
  double targetRatio = GarnishMath.defaultThreshold,
  ContrastDirection direction = ContrastDirection.auto,
  double? minimumBlend,
  BlendStyle? blendStyle,
  BlendRange? blendRange,
})
```

Optimizes `color` to read well against the `against` background. Returns the
input unchanged when contrast already meets `targetRatio`.

```dart
final optimized = Garnish.contrastingColor(Colors.red, against: Colors.blue);
```

### `hasGoodContrast`

```dart
static bool hasGoodContrast(Color color1, Color color2)
```

Returns `true` if the two colors meet WCAG AA (4.5:1).

### Enums

- `ContrastDirection` — `auto`, `forceLight`, `forceDark`, `preferLight`, `preferDark`.
- `BlendStyle` — `minimal` (0.0), `moderate` (0.5), `strong` (0.7), `maximum` (1.0); each exposes `minimumBlend`.
- `BlendRange` — `typedef BlendRange = ({double min, double max})`.

---

## `GarnishMath`

WCAG-compliant color mathematics.

```dart
static const double wcagAAThreshold  = 4.5;
static const double wcagAAAThreshold = 7.0;
static const double defaultThreshold = wcagAAThreshold;

static double relativeLuminance(Color color);
static double rgbBrightness(Color color);
static double brightness(Color color, {BrightnessMethod method = BrightnessMethod.luminance});
static double contrastRatio(Color color1, Color color2);

static ColorClassification classify(Color color, {double threshold = 0.5, BrightnessMethod method = BrightnessMethod.luminance});
static Brightness colorScheme(Color color, {BrightnessMethod method = BrightnessMethod.luminance});

static bool meetsWCAGAA(Color a, Color b);
static bool meetsWCAGAAA(Color a, Color b);
static bool ratioMeetsWCAGAA(double ratio);
static bool ratioMeetsWCAGAAA(double ratio);
```

```dart
final l = GarnishMath.relativeLuminance(Colors.blue);            // 0.0 – 1.0
final r = GarnishMath.contrastRatio(Colors.white, Colors.black); // ~21.0
final c = GarnishMath.classify(Colors.amber);                    // ColorClassification.light
```

- `BrightnessMethod` — `luminance` (WCAG, default) or `rgb` (simple average).
- `ColorClassification` — `light` / `dark`; exposes `.brightness` (`Brightness`).

---

## `GarnishColor`

Lower-level color manipulation.

```dart
static Color blend(Color color1, Color color2, {required double ratio});
static Color averageColor(List<Color> colors);
static ColorComponents extractColorComponents(Color color);
static Color adjustBrightness(Color color, {required double by});
static Color adjustLuminance(Color color, {required double by});
static String toHex(Color color, {bool includeAlpha = false});
static Color? fromHex(String hex);
```

```dart
final mix   = GarnishColor.blend(Colors.red, Colors.blue, ratio: 0.5);
final hex   = GarnishColor.toHex(Colors.indigo);            // "3F51B5"
final color = GarnishColor.fromHex('#3F51B5');              // Color? (null if invalid)
final dark  = GarnishColor.adjustBrightness(Colors.blue, by: -0.2);
```

`ColorComponents` holds normalized `red`, `green`, `blue`, `alpha` (`0.0`–`1.0`).

---

## `Color` extensions

```dart
// From color_extensions.dart
Colors.blue.hsb;                       // (hue: 0–360, saturation: 0–1, brightness: 0–1)
Colors.blue.adjustBrightness(by: 0.1);
Colors.blue.adjustLuminance(by: 0.1);
Colors.blue.toHex();

// From color_convenience_extensions.dart
Colors.blue.contrastingShade();
Colors.red.optimized(Colors.blue);
Colors.blue.classify();
Colors.blue.colorScheme();
Colors.blue.relativeLuminance();
Colors.blue.brightness();
Colors.white.contrastRatio(Colors.black);
Colors.white.meetsWCAGAA(Colors.black);
Colors.white.meetsWCAGAAA(Colors.black);

// From font_extensions.dart
final weight = Colors.grey.recommendedFontWeight(against: Colors.white);
```

---

## `GarnishColorExpansion`

`import 'package:garnish/garnish_expansion.dart';`

```dart
static List<Color> expand(List<Color> colors, {required int to});
static List<Color> contract(List<Color> colors, {required int to});
static List<Color> linearInterpolation(List<Color> colors, {required int to});
static List<Color> simpleRepeat(List<Color> colors, {required int to});
static List<Color> generateVariations(Color color, {required int count});
static Color selectPrimaryColor(List<Color> colors);
static List<Color> expandToGradientMesh(Color color, {int size = 16, double spread = 0.35});
static List<Color> expandForGradient(List<Color> colors);
static Color contractToSolid(List<Color> colors);
```

```dart
final palette = GarnishColorExpansion.expand([Colors.blue, Colors.purple], to: 8);
final mesh    = GarnishColorExpansion.expandToGradientMesh(Colors.teal); // 16 colors
```

---

## Error handling

`GarnishError` mirrors the original package's error type. In Flutter it is
rarely thrown — `recommendedFontWeight` throws it when given an empty
`fontWeightRange`. Each instance exposes `errorDescription`, `failureReason`,
and `recoverySuggestion`.
