# Getting Started

Get up and running with Garnish in minutes. This guide covers installation,
basic setup, and your first color operations.

> This is the Flutter/Dart port of [SwiftUI Garnish](https://github.com/Aeastr/Garnish).

## 📦 Installation

Add Garnish to your `pubspec.yaml`:

```yaml
dependencies:
  garnish:
    git: https://github.com/rehmatsg/garnish.git
```

Then fetch packages:

```bash
flutter pub get
```

### Requirements

| Requirement | Version |
|-------------|---------|
| Flutter     | 3.27+   |
| Dart        | 3.6+    |

Garnish uses the modern floating-point `Color` API (`.r`/`.g`/`.b`/`.a` and
`Color.from`), introduced in Flutter 3.27.

---

## 🚀 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:garnish/garnish.dart';

class ContentView extends StatelessWidget {
  const ContentView({super.key});

  static const backgroundColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    // Generate an accessible text color for any background.
    final textColor = Garnish.contrastingColor(Colors.black, against: backgroundColor);

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Text('Hello, Garnish!', style: TextStyle(color: textColor)),
    );
  }
}
```

That's it! You now have WCAG-compliant text that automatically adjusts for any
background color.

---

## 🎯 Core Concepts

Garnish solves color contrast with two core functions:

**1. Monochromatic contrast** — "Give me a better shade of the same color"

```dart
final contrastingBlue = Garnish.contrastingShade(Colors.blue);
```

**2. Bi-chromatic optimization** — "Make this color work better against that background"

```dart
final readableText = Garnish.contrastingColor(Colors.black, against: backgroundColor);
```

> **Note on null safety:** unlike the Swift package (which returns optionals),
> these functions return non-nullable `Color` values because Flutter's `Color`
> always exposes its components. Only `GarnishColor.fromHex` returns `Color?`.

---

## 🏗️ Basic Examples

### Accessibility validation

```dart
final ratio = GarnishMath.contrastRatio(foreground, background);

String status;
if (GarnishMath.meetsWCAGAAA(foreground, background)) {
  status = '✅ Excellent (AAA)';
} else if (GarnishMath.meetsWCAGAA(foreground, background)) {
  status = '✅ Good (AA)';
} else {
  status = '❌ Poor';
}
```

### Dynamic theming

```dart
Color adaptiveBackground(Color base, Brightness brightness) {
  final adjustment = brightness == Brightness.dark ? -0.2 : 0.1;
  return GarnishColor.adjustBrightness(base, by: adjustment);
}

Color textColorFor(Color background) =>
    Garnish.contrastingColor(Colors.black, against: background);
```

### Palette generation

```dart
import 'package:garnish/garnish_expansion.dart';

final palette = GarnishColorExpansion.expand([Colors.indigo], to: 5);
```

---

## 🛠️ Advanced Configuration

### Custom contrast targets

```dart
// WCAG AA (default): 4.5:1
final aa = Garnish.contrastingColor(Colors.red, against: Colors.blue);

// WCAG AAA: 7:1
final aaa = Garnish.contrastingColor(
  Colors.red,
  against: Colors.blue,
  targetRatio: GarnishMath.wcagAAAThreshold,
);

// Custom ratio
final custom = Garnish.contrastingColor(Colors.red, against: Colors.blue, targetRatio: 6.0);
```

### Brightness calculation methods

```dart
// WCAG luminance (recommended for accessibility)
final shade1 = Garnish.contrastingShade(Colors.blue, method: BrightnessMethod.luminance);

// Simple RGB averaging (faster, less accurate)
final shade2 = Garnish.contrastingShade(Colors.blue, method: BrightnessMethod.rgb);
```

### Direction & blend control

```dart
// Bias toward darker shades (shadows) or lighter shades (highlights).
Garnish.contrastingShade(Colors.blue, direction: ContrastDirection.forceDark);

// Control blend intensity.
Garnish.contrastingShade(Colors.blue, blendStyle: BlendStyle.strong);
Garnish.contrastingShade(Colors.blue, minimumBlend: 0.6);
Garnish.contrastingShade(Colors.blue, blendRange: (min: 0.4, max: 0.9));
```

---

## 🔍 Common Patterns

### Extension-based usage

```dart
Widget adaptiveText(String text, Color background) => Container(
      color: background,
      child: Text(
        text,
        style: TextStyle(color: Garnish.contrastingColor(Colors.black, against: background)),
      ),
    );

final ratio = Colors.white.contrastRatio(Colors.black); // ~21.0
final scheme = background.colorScheme();                 // Brightness.light / .dark
```

---

## Next Steps

- **[Core API](Core-API.md)** — Deep dive into the main contrast functions.
- **[GarnishMath](GarnishMath.md)** — Luminance, contrast, and classification.
- **[GarnishColor](GarnishColor.md)** — Blending, brightness, and hex.
- **[Expansion](Expansion.md)** — Generate full palettes from a few colors.
- **[Recipes](Recipes.md)** — Ready-made Flutter widgets and patterns.
- **[Error Handling](Error-Handling.md)** — The null-safety model.
- Browse the [`example/`](../example) app for a live, interactive demo.
