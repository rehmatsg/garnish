# CLAUDE.md

Guidance for Claude Code (and other AI agents) working in this repository.

## What this is

`garnish` is a **Flutter/Dart port** of the SwiftUI package
[Garnish](https://github.com/Aeastr/Garnish) by Aether — intelligent color
utilities for accessibility, contrast optimization, and visual harmony
(WCAG 2.1 luminance/contrast math, contrasting-color generation, and palette
expansion). It is a pure Dart library that depends only on the Flutter SDK.

## Commands

```bash
flutter pub get          # install deps
flutter analyze          # static analysis — must be clean before committing
flutter test             # run the test suite (test/garnish_test.dart)
dart format lib test     # format (CI/pub expect formatted code)

# Example app
cd example && flutter pub get
flutter create .         # first run only — generate platform runners
flutter run
```

> Note: in this environment `flutter analyze` may print Xcode-license noise from
> its git probe. Use `dart analyze` for a clean signal.

## Architecture

Two public entry points (libraries):

- `package:garnish/garnish.dart` — core. Re-exports everything in `lib/src/`
  except the expansion module.
- `package:garnish/garnish_expansion.dart` — optional palette expand/contract
  utilities (`GarnishColorExpansion`). Kept separate to mirror the original
  Swift `GarnishExpansion` product.

`lib/src/` files (one concern each):

| File | Contents |
|------|----------|
| `garnish_base.dart` | `Garnish` (contrast generation), `ContrastDirection`, `BlendStyle`, `BlendRange` |
| `garnish_math.dart` | `GarnishMath`, `BrightnessMethod`, `ColorClassification` |
| `garnish_color.dart` | `GarnishColor`, `ColorComponents` |
| `garnish_error.dart` | `GarnishError`, `GarnishErrorKind` |
| `color_extensions.dart` | `Color` extension: `hsb`, `adjustBrightness`, `adjustLuminance`, `toHex` |
| `color_convenience_extensions.dart` | `Color` extension: contrast/analysis conveniences |
| `font_extensions.dart` | `Color.recommendedFontWeight` |
| `garnish_color_expansion.dart` | `GarnishColorExpansion` (exported via the expansion library) |

Static utility classes use `abstract final class` (namespacing, non-instantiable).
Enums are top-level (not nested), and use enhanced-enum members where the Swift
original had computed properties (e.g. `BlendStyle.minimumBlend`,
`ColorClassification.brightness`).

## Porting conventions (keep these consistent)

- **Modern `Color` API only.** Use `color.r/.g/.b/.a` (doubles 0–1) and
  `Color.from(alpha:, red:, green:, blue:)`. Never use the deprecated
  `.red/.green/.blue/.value/.opacity` integer accessors. SDK floor is Flutter
  ≥3.27 / Dart ≥3.6 for this reason.
- **Non-nullable returns.** Swift returns optionals because UIKit/AppKit color
  extraction can fail; Flutter's `Color` can't. So math/generation functions
  return non-null. The only exceptions: `GarnishColor.fromHex` → `Color?`
  (parsing fails), and `Color.recommendedFontWeight` throws `GarnishError` on an
  empty range.
- **Type mappings.** SwiftUI `ColorScheme` → Flutter `Brightness`;
  `Font.Weight` → `FontWeight`; `CGFloat` → `double`; `Color` → `Color`.
- **No overloads.** Dart lacks overloading; the ratio-based WCAG checks are
  `ratioMeetsWCAGAA` / `ratioMeetsWCAGAAA` (vs the color-pair `meetsWCAGAA*`).
- **Parameter naming.** `using method:` → `method:`; `against:` is a named arg;
  brightness/luminance adjustments use `by:`; blending uses `ratio:`. `with` is
  a Dart keyword, so it's never a parameter name (use positional or `other`).
- **HSB / hue units.** `HSVColor` hue is **0–360 degrees** (SwiftUI's
  `Color(hue:)` is 0–1). When porting expansion math, do **not** divide hue by
  360; normalize into `[0, 360)` instead.
- **num vs double.** `double.clamp(...)` returns `num`; append `.toDouble()`
  before passing to a `double` parameter.

## Maintaining parity with upstream

The upstream source lives at <https://github.com/Aeastr/Garnish> (`Sources/`).
When porting a change, replicate the **algorithm** (e.g. the 5-iteration binary
blend search in `Garnish._findOptimalBlend`) rather than the Swift type
ceremony. Document any intentional behavioral divergence in `README.md`
("Differences from the Swift package") and the relevant `docs/` page.

`GarnishDemo.swift` (the SwiftUI playground) is intentionally **not** ported —
the Flutter equivalent is the `example/` app.

## Conventions

- Keep the public API documented (`///` dartdoc on exported members).
- Add/update tests in `test/garnish_test.dart` for any behavior change; prefer
  `closeTo`/`toARGB32()` for color comparisons (avoid float-equality flakiness).
- Credit the original author/project; the port is MIT with dual copyright.
