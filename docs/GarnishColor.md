# GarnishColor

`GarnishColor` provides advanced color-manipulation utilities. While the
[Core API](Core-API.md) handles contrast generation, `GarnishColor` offers
fine-grained control over blending, brightness, and conversion.

```dart
import 'package:garnish/garnish.dart';
```

---

## 🎨 Color blending

### `blend(color1, color2, {ratio})`

```dart
final purple = GarnishColor.blend(Colors.red, Colors.blue, ratio: 0.5);
// 50% red, 50% blue

final tintedRed = GarnishColor.blend(Colors.red, Colors.white, ratio: 0.2);
// red with a 20% white tint
```

- `ratio` — `0.0` = 100% `color1`, `1.0` = 100% `color2`.
- All four channels (including alpha) are interpolated linearly.

### `averageColor(colors)`

```dart
final mix = GarnishColor.averageColor([Colors.red, Colors.green, Colors.blue]);
// Component-wise average; returns transparent for an empty list.
```

### `extractColorComponents(color)`

```dart
final c = GarnishColor.extractColorComponents(Colors.indigo);
// ColorComponents(red, green, blue, alpha) — each 0.0–1.0
```

---

## 🔆 Brightness adjustment

### `adjustBrightness(color, {by})`

Scales the RGB channels by a factor of `1.0 + by`.

```dart
final darkerBlue = GarnishColor.adjustBrightness(Colors.blue, by: -0.3); // ×0.7
final lighterRed = GarnishColor.adjustBrightness(Colors.red, by: 0.5);   // ×1.5
```

- `by` — adjustment amount (`-1.0` … `1.0`); `0.0` = no change. Channels are
  clamped to `[0, 1]`.

### `adjustLuminance(color, {by})`

Adjusts brightness in **HSB space**, preserving hue and saturation.

```dart
final brighter = GarnishColor.adjustLuminance(Colors.blue, by: 0.2);
final dimmer = GarnishColor.adjustLuminance(Colors.red, by: -0.3);
```

- `by` is **additive** on the HSB value channel; `0.0` = no change. (This
  matches the original Swift implementation's behavior.)

**`adjustBrightness` vs `adjustLuminance`:**
- `adjustBrightness` — multiplies RGB components directly.
- `adjustLuminance` — works in HSB, keeping hue and saturation intact.

---

## 🔄 Color conversion

### `toHex(color, {includeAlpha})`

```dart
GarnishColor.toHex(Colors.red);                       // "F44336" (Material red)
GarnishColor.toHex(const Color(0xFFFF0000));          // "FF0000"
GarnishColor.toHex(const Color(0xFF0000FF), includeAlpha: true); // "0000FFFF"
```

- Without alpha: `"RRGGBB"`. With alpha: `"RRGGBBAA"`. Uppercase, no `#`.

### `fromHex(hex)`

```dart
GarnishColor.fromHex('FF0000');     // Color
GarnishColor.fromHex('#FF0000');    // leading # allowed
GarnishColor.fromHex('F00');        // 3-digit shorthand
GarnishColor.fromHex('FF0000FF');   // 8-digit RRGGBBAA
GarnishColor.fromHex('nope');       // null (invalid)
```

- Supports `RGB`, `RRGGBB`, `RRGGBBAA`, optional `#`, case-insensitive.
- **Returns `Color?`** — the only Garnish function that can return `null`,
  because parsing can fail.

---

## 🛠️ Practical examples

### Tonal palette from one color

```dart
List<Color> tonalPalette(Color base) => [
      GarnishColor.adjustLuminance(base, by: 0.30),  // lighter
      GarnishColor.adjustLuminance(base, by: 0.15),
      base,                                          // original
      GarnishColor.adjustLuminance(base, by: -0.15),
      GarnishColor.adjustLuminance(base, by: -0.30), // darker
    ];
```

### Hover / pressed states

```dart
Color hoverState(Color buttonColor) {
  // Lighten dark colors, darken light ones.
  final delta = buttonColor.classify() == ColorClassification.light ? -0.1 : 0.1;
  return GarnishColor.adjustBrightness(buttonColor, by: delta);
}
```

### Color gradient

```dart
List<Color> gradient(Color start, Color end, int steps) =>
    List.generate(steps, (i) {
      final ratio = i / (steps - 1);
      return GarnishColor.blend(start, end, ratio: ratio);
    });
```

### Persisting colors (with `shared_preferences`)

```dart
Future<void> saveColor(SharedPreferences prefs, String key, Color color) =>
    prefs.setString(key, GarnishColor.toHex(color, includeAlpha: true));

Color? loadColor(SharedPreferences prefs, String key) {
  final hex = prefs.getString(key);
  return hex == null ? null : GarnishColor.fromHex(hex);
}
```

---

## ⚡ Performance notes

- **Blending / brightness** — fast, direct channel math.
- **`adjustLuminance`** — involves an HSB round-trip (slightly heavier).
- **Hex conversion** — minimal overhead; safe for frequent use.

---

## 🔗 Related

- **[Core API](Core-API.md)** — the contrast functions that build on these.
- **[GarnishMath](GarnishMath.md)** — the math foundation.
- **[Expansion](Expansion.md)** — turn a few colors into a full palette.
