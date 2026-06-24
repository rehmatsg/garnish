# Recipes

Practical, copy-paste patterns for using Garnish in real Flutter UIs.

```dart
import 'package:flutter/material.dart';
import 'package:garnish/garnish.dart';
```

---

## Adaptive text on any background

Always-readable text, whatever the background:

```dart
class AdaptiveLabel extends StatelessWidget {
  const AdaptiveLabel(this.text, {required this.background, super.key});

  final String text;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final foreground = Garnish.contrastingColor(Colors.black, against: background);
    return Container(
      color: background,
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontWeight: foreground.recommendedFontWeight(against: background),
        ),
      ),
    );
  }
}
```

---

## An accessible colored button

Foreground color and weight both derive from the button color:

```dart
class GarnishButton extends StatelessWidget {
  const GarnishButton({required this.label, required this.color, this.onPressed, super.key});

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = Garnish.contrastingColor(Colors.white, against: color);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: fg),
      child: Text(
        label,
        style: TextStyle(fontWeight: fg.recommendedFontWeight(against: color)),
      ),
    );
  }
}
```

---

## A WCAG contrast badge

Show live AA/AAA status for a foreground/background pair:

```dart
class ContrastBadge extends StatelessWidget {
  const ContrastBadge({required this.foreground, required this.background, super.key});

  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final ratio = foreground.contrastRatio(background);
    final (label, color) = switch (ratio) {
      >= GarnishMath.wcagAAAThreshold => ('AAA · ${ratio.toStringAsFixed(1)}:1', Colors.green),
      >= GarnishMath.wcagAAThreshold => ('AA · ${ratio.toStringAsFixed(1)}:1', Colors.teal),
      _ => ('Fail · ${ratio.toStringAsFixed(1)}:1', Colors.red),
    };
    return Chip(label: Text(label), backgroundColor: color.withValues(alpha: 0.15));
  }
}
```

---

## Deterministic colors for tags / avatars

Map any string to a stable, readable chip color:

```dart
Color colorForLabel(String label) {
  final hue = (label.hashCode % 360).abs().toDouble();
  return HSVColor.fromAHSV(1, hue, 0.6, 0.8).toColor();
}

Widget tag(String label) {
  final bg = colorForLabel(label);
  return Chip(
    backgroundColor: bg,
    label: Text(label, style: TextStyle(color: bg.contrastingShade())),
  );
}
```

---

## Brand gradient background

Turn one brand color into a harmonious gradient:

```dart
import 'package:garnish/garnish_expansion.dart';

Widget brandGradient(Color brand, {Widget? child}) {
  final colors = GarnishColorExpansion.expandToGradientMesh(brand, size: 4);
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: child,
  );
}
```

---

## Theme-aware tinting

Nudge a color toward the current theme's brightness:

```dart
Color tintForTheme(Color base, Brightness brightness) {
  final delta = brightness == Brightness.dark ? -0.2 : 0.1;
  return GarnishColor.adjustBrightness(base, by: delta);
}
```

---

## AppBar that adapts to its background

```dart
AppBar garnishAppBar(String title, Color background) {
  final fg = Garnish.contrastingColor(Colors.white, against: background);
  return AppBar(
    backgroundColor: background,
    foregroundColor: fg,
    title: Text(
      title,
      style: TextStyle(fontWeight: fg.recommendedFontWeight(against: background)),
    ),
  );
}
```

---

## Validate a designer-supplied palette

```dart
List<String> auditPalette(Map<String, (Color fg, Color bg)> pairs) {
  return [
    for (final entry in pairs.entries)
      if (!entry.value.$1.meetsWCAGAA(entry.value.$2))
        '${entry.key}: only ${entry.value.$1.contrastRatio(entry.value.$2).toStringAsFixed(1)}:1',
  ];
}
```

---

## 🔗 Related

- **[Getting Started](Getting-Started.md)** · **[Core API](Core-API.md)**
- **[GarnishMath](GarnishMath.md)** · **[GarnishColor](GarnishColor.md)** · **[Expansion](Expansion.md)**
