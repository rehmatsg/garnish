# GarnishColorExpansion

Grow a small set of seed colors into a larger, harmonious palette — or contract
a large set down to a representative few. This is the optional expansion module,
ported from the Swift package's `GarnishExpansion` product.

```dart
import 'package:garnish/garnish_expansion.dart';
```

---

## 🌱 Expanding

### `expand(colors, {to})`

The main entry point. Uses a **Harmonic Flow** strategy that repeats and subtly
varies the source colors to preserve family coherence.

```dart
final palette = GarnishColorExpansion.expand([Colors.indigo, Colors.teal], to: 8);
// 8 colors that stay in the indigo→teal family
```

Behavior by input:
- `colors.length >= to` → contracts instead (see below).
- a single color → generates variations of it.
- multiple colors → harmonic-flow expansion.

### `generateVariations(color, {count})`

Produces `count` harmonious variations of one color by gently sweeping hue,
saturation, and brightness.

```dart
final shades = GarnishColorExpansion.generateVariations(Colors.purple, count: 6);
```

### `linearInterpolation(colors, {to})`

A smooth HSB gradient between the source colors (shortest-path hue blending).

```dart
final ramp = GarnishColorExpansion.linearInterpolation([Colors.red, Colors.blue], to: 10);
```

### `simpleRepeat(colors, {to})`

Cycles through the source colors with no variation.

```dart
GarnishColorExpansion.simpleRepeat([Colors.red, Colors.blue], to: 5);
// [red, blue, red, blue, red]
```

---

## 🍂 Contracting

### `contract(colors, {to})`

Samples a larger palette down to `to` entries (evenly across the array; for
`to == 1`, returns the most representative color).

```dart
final fewer = GarnishColorExpansion.contract(bigPalette, to: 4);
```

### `selectPrimaryColor(colors)`

Returns the most representative color — the **median by luminance**.

```dart
final primary = GarnishColorExpansion.selectPrimaryColor([Colors.red, Colors.green, Colors.blue]);
```

### `contractToSolid(colors)`

Convenience for collapsing a palette to a single color (alias of
`selectPrimaryColor`).

```dart
final solid = GarnishColorExpansion.contractToSolid(palette);
```

---

## 🟦 Gradient helpers

### `expandToGradientMesh(color, {size = 16, spread = 0.35})`

Expands one color into `size` colors — handy for mesh / animated gradients
(`16` = a 4×4 mesh by default). Unlike the hue-shifting `generateVariations`,
this produces a **hue-stable shade/tint ramp** (the "shade + tint" trick behind
SwiftUI's `Color.gradient`): darker stops scale toward black, lighter stops
blend toward white, and hue stays constant. The work happens in RGB space to
avoid the perceptual kink HSL lightness has around `0.5`.

`spread` is the dial for how far stops drift from `color` (clamped to `[0, 1]`):
`0.1`–`0.15` gives a subtle, SwiftUI-like feel, while `0.3`–`0.4` gives a
tighter, more pronounced ramp. Stops run darkest → lightest.

```dart
final mesh   = GarnishColorExpansion.expandToGradientMesh(Colors.teal); // 16 colors
final subtle = GarnishColorExpansion.expandToGradientMesh(Colors.teal, size: 5, spread: 0.12);
```

### `expandForGradient(colors)`

Expands any input to 16 colors for gradient backgrounds.

```dart
final gradientColors = GarnishColorExpansion.expandForGradient([Colors.blue, Colors.purple]);
```

---

## 🎯 Example: a swatch strip

```dart
import 'package:flutter/material.dart';
import 'package:garnish/garnish.dart';
import 'package:garnish/garnish_expansion.dart';

Widget swatchStrip(Color base) {
  final palette = GarnishColorExpansion.expandToGradientMesh(base, size: 8);
  return Row(
    children: [
      for (final color in palette)
        Expanded(
          child: Container(
            height: 48,
            color: color,
            alignment: Alignment.center,
            child: Text(
              color.toHex(),
              style: TextStyle(color: color.contrastingShade(), fontSize: 9),
            ),
          ),
        ),
    ],
  );
}
```

---

## 🔗 Related

- **[Core API](Core-API.md)** — contrast generation for text on these swatches.
- **[GarnishColor](GarnishColor.md)** — `blend`, `adjustLuminance`, `toHex`.
- **[Recipes](Recipes.md)** — more end-to-end patterns.
