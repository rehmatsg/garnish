# GarnishMath

`GarnishMath` provides the mathematical foundation for all color analysis in
Garnish. It implements WCAG 2.1–compliant calculations for luminance, contrast
ratios, and color classification.

```dart
import 'package:garnish/garnish.dart';
```

> **Null safety:** unlike the Swift original (which returns optionals),
> `GarnishMath` returns **non-nullable** values — Flutter's `Color` always
> exposes its channels, so the calculations can't fail. See
> [Error Handling](Error-Handling.md).

---

## 📐 Brightness calculation methods

```dart
enum BrightnessMethod {
  luminance, // WCAG 2.1 relative luminance (recommended)
  rgb,       // simple RGB averaging
}
```

**When to use each:**
- **`luminance`** — accessibility compliance and accurate perceptual brightness.
- **`rgb`** — simple, fast calculations where precision isn't critical.

---

## 🌟 Luminance calculations

### `relativeLuminance(color)`

WCAG 2.1 relative luminance — the gold standard for accessibility.

```dart
final luminance = GarnishMath.relativeLuminance(Colors.blue);
// Extension form:
final l2 = Colors.blue.relativeLuminance(); // ~0.0722 (blue is quite dark)
```

- Formula: `0.2126·R + 0.7152·G + 0.0722·B` over sRGB-companded channels.
- Returns `0.0` (black) … `1.0` (white).

### `rgbBrightness(color)`

```dart
final b = GarnishMath.rgbBrightness(Colors.blue);
// ~0.333  (R=0, G=0, B=1 → average)
```

### `brightness(color, {method})`

Unified brightness with method selection.

```dart
final lum = GarnishMath.brightness(Colors.blue, method: BrightnessMethod.luminance);
final avg = Colors.blue.brightness(method: BrightnessMethod.rgb);
```

---

## 📊 Contrast calculations

### `contrastRatio(a, b)`

```dart
final ratio = GarnishMath.contrastRatio(Colors.white, Colors.black);
final r2 = Colors.white.contrastRatio(Colors.black); // 21.0
```

**Formula:** `(L1 + 0.05) / (L2 + 0.05)` where `L1` is the lighter luminance.

| Ratio | Meaning |
|------:|---------|
| `1:1` | No contrast (same color) |
| `4.5:1` | WCAG AA minimum |
| `7:1` | WCAG AAA minimum |
| `21:1` | Maximum (white on black) |

---

## 🎨 Color classification

```dart
enum ColorClassification {
  light,
  dark; // exposes `.brightness` -> Brightness.light / Brightness.dark
}
```

### `classify(color, {threshold, method})`

```dart
final c = GarnishMath.classify(Colors.blue);   // ColorClassification.dark
final c2 = Colors.amber.classify();            // ColorClassification.light
```

- `threshold` — brightness cutoff (default `0.5`).
- `method` — calculation method (default `luminance`).

### `colorScheme(color, {method})`

Returns Flutter's [`Brightness`] (the equivalent of SwiftUI's `ColorScheme`).

```dart
final scheme = GarnishMath.colorScheme(backgroundColor); // Brightness.light / .dark
final s2 = backgroundColor.colorScheme();
```

---

## ✅ WCAG compliance validation

```dart
GarnishMath.wcagAAThreshold;  // 4.5
GarnishMath.wcagAAAThreshold; // 7.0
GarnishMath.defaultThreshold; // 4.5 (AA)
```

**Color-based:**

```dart
final meetsAA = GarnishMath.meetsWCAGAA(Colors.white, Colors.blue);
final meetsAA2 = Colors.white.meetsWCAGAA(Colors.blue);
final meetsAAA = Colors.white.meetsWCAGAAA(Colors.blue);
```

**Ratio-based** (Dart has no method overloading, so these are named separately):

```dart
const ratio = 6.2;
GarnishMath.ratioMeetsWCAGAA(ratio);  // true
GarnishMath.ratioMeetsWCAGAAA(ratio); // false
```

---

## 🎯 Practical examples

### Dynamic theme detection

```dart
Brightness recommendedBrightness(Color background) =>
    GarnishMath.colorScheme(background);
```

### Accessibility audit

```dart
String auditColorPair(Color foreground, Color background) {
  final ratio = GarnishMath.contrastRatio(foreground, background);
  if (GarnishMath.ratioMeetsWCAGAAA(ratio)) {
    return '✅ Excellent (AAA): ${ratio.toStringAsFixed(1)}:1';
  } else if (GarnishMath.ratioMeetsWCAGAA(ratio)) {
    return '✅ Good (AA): ${ratio.toStringAsFixed(1)}:1';
  }
  return '❌ Poor: ${ratio.toStringAsFixed(1)}:1';
}
```

### Smart text color

```dart
Color bestTextColor(Color background) =>
    background.classify() == ColorClassification.light
        ? Colors.black
        : Colors.white;
```

---

## 🔗 Related

- **[Core API](Core-API.md)** — how `GarnishMath` powers the main functions.
- **[GarnishColor](GarnishColor.md)** — color manipulation built on this math.
- **[Recipes](Recipes.md)** — practical, copy-paste patterns.
