# Changelog

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
