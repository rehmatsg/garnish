<div align="center">
  <img width="128" height="128" src="https://raw.githubusercontent.com/Aeastr/Garnish/main/resources/icons/icon.png" alt="Garnish Icon">
  <h1><b>Garnish</b></h1>
  <p>
    Intelligent color utilities for accessibility, contrast optimization, and visual harmony — for Flutter.
  </p>
</div>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%E2%89%A53.27-02569B?logo=flutter&logoColor=white" alt="Flutter >=3.27"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-%E2%89%A53.6-0175C2?logo=dart&logoColor=white" alt="Dart >=3.6"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>
  <br>
  <img src="https://img.shields.io/badge/iOS-✓-000000?logo=apple&logoColor=white" alt="iOS">
  <img src="https://img.shields.io/badge/Android-✓-3DDC84?logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/Web-✓-F7DF1E?logo=javascript&logoColor=black" alt="Web">
  <img src="https://img.shields.io/badge/macOS-✓-000000?logo=apple&logoColor=white" alt="macOS">
  <img src="https://img.shields.io/badge/Windows-✓-0078D6?logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Linux-✓-FCC624?logo=linux&logoColor=black" alt="Linux">
</p>

> **A Flutter/Dart port of the SwiftUI package [Garnish](https://github.com/Aeastr/Garnish) by [Aether](https://github.com/Aeastr).**
> All credit for the original concept, algorithms, and API design goes to the original author. See [Credits](#credits).

| <img src="https://raw.githubusercontent.com/Aeastr/Garnish/main/resources/icons/autoContrast.png" width="64"> | <img src="https://raw.githubusercontent.com/Aeastr/Garnish/main/resources/icons/colorMath.png" width="64"> | <img src="https://raw.githubusercontent.com/Aeastr/Garnish/main/resources/icons/colorAnalysis.png" width="64"> |
|:---:|:---:|:---:|
| **Auto Contrast** | **Color Math** | **Color Analysis** |
| Automatically generate readable text colors from any background | Calculate luminance, brightness, and contrast ratios with WCAG standards | Classify colors as light/dark and validate accessibility compliance |


## Overview

- **Contrast Optimization** — Generate colors that meet WCAG accessibility standards
- **Dynamic Color Adaptation** — Colors that work beautifully in light and dark themes
- **Mathematical Color Analysis** — Precise luminance, brightness, and contrast calculations
- **Smart Color Generation** — Create contrasting shades and optimized color combinations
- **Font Weight Optimization** — Improved readability through accessibility-first recommendations
- **Palette Expansion** — Grow a few colors into a harmonious palette (optional module)


## Installation

Add Garnish to your `pubspec.yaml`:

```yaml
dependencies:
  garnish:
    git: https://github.com/rehmatsg/garnish.git
```

Then run `flutter pub get`.

> Targets Flutter `>=3.27` / Dart `>=3.6` and uses the modern floating-point
> `Color` API (`.r`/`.g`/`.b`/`.a`, `Color.from`).

See **[Getting Started](docs/Getting-Started.md)** for a detailed walkthrough.


## Usage

```dart
import 'package:flutter/material.dart';
import 'package:garnish/garnish.dart';

// Generate an accessible text color for any background.
final textColor = Garnish.contrastingColor(Colors.black, against: backgroundColor);

// Create a contrasting shade of the same color.
final shade = Garnish.contrastingShade(Colors.blue);

// Check accessibility compliance.
final isAccessible = Garnish.hasGoodContrast(foreground, background);
```

Most APIs are also available as extensions directly on `Color`:

```dart
final shade = Colors.blue.contrastingShade();
final ratio = Colors.white.contrastRatio(Colors.black); // ~21.0
final ok    = foreground.meetsWCAGAA(background);
final hex    = Colors.indigo.toHex();                    // "3F51B5"
final scheme = backgroundColor.colorScheme();            // Brightness.light / .dark
```

See **[docs/](docs/)** for the full API reference.


## Example

A runnable demo lives in [`example/`](example/). It lets you pick a base color
and watch Garnish generate readable text, analyze contrast against white/black,
flag WCAG AA/AAA compliance, and build a harmonious palette in real time.

```bash
cd example
flutter create .   # first run only — generates the platform runners
flutter run
```


## How It Works

Garnish uses WCAG 2.1 luminance calculations to determine optimal contrast
ratios. The core algorithm calculates relative luminance using the sRGB color
space formula, then generates contrasting colors that meet accessibility
thresholds (4.5:1 for AA, 7:1 for AAA compliance) via a short binary search over
blend amounts toward black or white.


## Modules

| Library | Import | Contents |
|---|---|---|
| **Core** | `package:garnish/garnish.dart` | `Garnish`, `GarnishMath`, `GarnishColor`, `GarnishError`, and `Color` extensions |
| **Expansion** | `package:garnish/garnish_expansion.dart` | `GarnishColorExpansion` — palette expand/contract utilities |


## Documentation

| Guide | What's inside |
|---|---|
| [Getting Started](docs/Getting-Started.md) | Install, first operation, theming, advanced config |
| [Core API](docs/Core-API.md) | `Garnish` contrast generation reference |
| [GarnishMath](docs/GarnishMath.md) | Luminance, contrast ratio, classification, WCAG checks |
| [GarnishColor](docs/GarnishColor.md) | Blend, average, brightness/luminance, hex conversion |
| [Expansion](docs/Expansion.md) | Palette expand/contract strategies |
| [Recipes](docs/Recipes.md) | Copy-paste Flutter widgets & patterns |
| [Error Handling](docs/Error-Handling.md) | Null-safety model & `GarnishError` |


## API at a glance

`Garnish`
- `contrastingShade(color, {...})` → `Color`
- `contrastingColor(color, {required against, ...})` → `Color`
- `hasGoodContrast(a, b)` → `bool`

`GarnishMath`
- `relativeLuminance(color)`, `rgbBrightness(color)`, `brightness(color, {method})`
- `contrastRatio(a, b)`
- `classify(color, {threshold, method})`, `colorScheme(color, {method})`
- `meetsWCAGAA(a, b)` / `meetsWCAGAAA(a, b)` and `ratioMeetsWCAGAA(r)` / `ratioMeetsWCAGAAA(r)`

`GarnishColor`
- `blend(a, b, {ratio})`, `averageColor(colors)`, `extractColorComponents(color)`
- `adjustBrightness(color, {by})`, `adjustLuminance(color, {by})`
- `toHex(color, {includeAlpha})`, `fromHex(string)`

`Color` extensions
- `contrastingShade()`, `optimized(bg, {targetRatio})`
- `classify(...)`, `colorScheme(...)`, `relativeLuminance()`, `brightness(...)`
- `contrastRatio(other)`, `meetsWCAGAA(other)`, `meetsWCAGAAA(other)`
- `hsb`, `adjustBrightness({by})`, `adjustLuminance({by})`, `toHex({includeAlpha})`
- `recommendedFontWeight({required against, fontWeightRange, debugStatements})`

`GarnishColorExpansion` (expansion library)
- `expand(colors, {to})`, `contract(colors, {to})`, `linearInterpolation(colors, {to})`
- `simpleRepeat(colors, {to})`, `generateVariations(color, {count})`
- `selectPrimaryColor(colors)`, `expandToGradientMesh(color, {size, spread})`, `expandForGradient(colors)`, `contractToSolid(colors)`


## Differences from the Swift package

This is a faithful port, with a few idiomatic adaptations for Dart/Flutter:

- **Non-nullable returns.** In Swift many functions return optionals because
  `UIColor`/`NSColor` component extraction can fail. Flutter's `Color` always
  exposes its channels, so the math and generation functions return
  non-nullable values. Only `GarnishColor.fromHex` (parsing can fail) returns
  `Color?`.
- **Top-level enums.** `ContrastDirection`, `BlendStyle`, `BrightnessMethod`,
  and `ColorClassification` are top-level (not nested inside their classes).
- **`ColorScheme` → `Brightness`.** SwiftUI's `ColorScheme` maps to Flutter's
  `Brightness` enum.
- **No overloads.** Dart lacks method overloading, so the ratio-based checks
  are named `ratioMeetsWCAGAA` / `ratioMeetsWCAGAAA`.
- **Parameter naming.** `using method:` → `method:`, `against:` is a named
  argument, `by:` is used for brightness/luminance adjustments.


## Credits

Garnish for Flutter is a port of the original **SwiftUI [Garnish](https://github.com/Aeastr/Garnish)** package created by **[Aether (@Aeastr)](https://github.com/Aeastr)**.

All credit for the original design, algorithms, documentation, and API goes to
the original author. This project simply adapts those ideas to Flutter/Dart. If
you find Garnish useful, please ⭐ and support the
**[original repository](https://github.com/Aeastr/Garnish)**.


## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.


## License

MIT — see [LICENSE](LICENSE). The original Swift package is also MIT licensed,
© Aether.
