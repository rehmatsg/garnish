# Changelog

## 1.1.0

### Changed

- **`GarnishColorExpansion.expandToGradientMesh`** now produces a hue-stable
  shade/tint ramp (the "shade + tint" trick behind SwiftUI's `Color.gradient`)
  instead of delegating to the hue-shifting `generateVariations`. Stops run
  darkest → lightest with hue held constant, computed in RGB space to avoid the
  perceptual kink HSL lightness has around `0.5`. A new `spread` parameter
  (default `0.35`, clamped to `[0, 1]`) dials how far stops drift from the seed
  — `0.1`–`0.15` for a subtle feel, `0.3`–`0.4` for a tighter ramp. Use
  `generateVariations` directly for the previous hue-shifting behavior.

## 1.0.0

Initial release — a Flutter/Dart port of the SwiftUI package
[Garnish](https://github.com/Aeastr/Garnish) by Aether.

### Added

- **`Garnish`** — `contrastingShade`, `contrastingColor`, and `hasGoodContrast`,
  with `ContrastDirection` and `BlendStyle` controls plus `minimumBlend` /
  `blendRange` tuning.
- **`GarnishMath`** — `relativeLuminance`, `rgbBrightness`, `brightness`,
  `contrastRatio`, `classify`, `colorScheme`, and WCAG AA/AAA validation
  (`meetsWCAGAA`/`meetsWCAGAAA` and the `ratioMeets*` variants).
- **`GarnishColor`** — `blend`, `averageColor`, `extractColorComponents`,
  `adjustBrightness`, `adjustLuminance`, `toHex`, and `fromHex`.
- **`Color` extensions** — `hsb`, `adjustBrightness`, `adjustLuminance`,
  `toHex`, `contrastingShade`, `optimized`, `classify`, `colorScheme`,
  `relativeLuminance`, `brightness`, `contrastRatio`, `meetsWCAGAA`,
  `meetsWCAGAAA`, and `recommendedFontWeight`.
- **`GarnishColorExpansion`** (via `package:garnish/garnish_expansion.dart`) —
  `expand`, `contract`, `linearInterpolation`, `simpleRepeat`,
  `generateVariations`, `selectPrimaryColor`, `expandToGradientMesh`,
  `expandForGradient`, and `contractToSolid`.
- **`GarnishError`** — error type mirroring the original package.
- Example app and a full test suite.
