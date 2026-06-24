# Error Handling

The Flutter port takes a different approach to failure than the Swift original,
because Flutter's `Color` is a plain value type whose channels are always
available.

## 🎯 Non-nullable by default

In the Swift package, many functions return optionals (`Color?`, `CGFloat?`)
because `UIColor`/`NSColor` component extraction can fail. In Flutter that never
happens, so Garnish's math and generation APIs return **non-nullable** values:

```dart
final Color  shade     = Garnish.contrastingShade(Colors.blue);
final double luminance = GarnishMath.relativeLuminance(Colors.blue);
final Color  optimized = Garnish.contrastingColor(Colors.red, against: Colors.blue);
```

No `??` fallbacks or `if (x != null)` checks required for these.

### The two exceptions

1. **`GarnishColor.fromHex(String)` returns `Color?`** — parsing user input can
   genuinely fail:

   ```dart
   final color = GarnishColor.fromHex(userInput) ?? Colors.black;

   if (GarnishColor.fromHex(userInput) case final color?) {
     applyTheme(color);
   } else {
     showInvalidHexMessage();
   }
   ```

2. **`Color.recommendedFontWeight(...)` throws `GarnishError`** — when given an
   empty `fontWeightRange` (a programming error):

   ```dart
   try {
     final weight = textColor.recommendedFontWeight(against: background);
   } on GarnishError catch (e) {
     debugPrint(e.errorDescription);
   }
   ```

---

## 🧰 The `GarnishError` type

`GarnishError` mirrors the original package's error enum for parity. Each
instance carries a [`GarnishErrorKind`] and three descriptive getters:

```dart
final error = GarnishError.invalidParameter('fontWeightRange', value: const []);

error.kind;                // GarnishErrorKind.invalidParameter
error.errorDescription;    // "Invalid value '[]' provided for parameter 'fontWeightRange'."
error.failureReason;       // why it happened
error.recoverySuggestion;  // how to fix it
```

`GarnishErrorKind` cases:

| Kind | Meaning |
|------|---------|
| `colorComponentExtractionFailed` | Could not read a color's components |
| `colorSpaceConversionFailed` | Could not convert to the required color space |
| `missingRequiredParameter` | A required parameter was not provided |
| `invalidParameter` | A parameter value was out of range/format |
| `invalidColorCalculation` | A calculation produced invalid values |

> The extraction/conversion kinds exist for API parity and for callers building
> stricter validation on top of Garnish; the core library does not throw them.

---

## 🛡️ Defensive patterns

### Graceful hex parsing

```dart
Color parseOrDefault(String hex, {Color fallback = Colors.black}) =>
    GarnishColor.fromHex(hex) ?? fallback;
```

### Filtering a list of hex strings

```dart
final colors = hexStrings
    .map(GarnishColor.fromHex)
    .whereType<Color>() // drops the nulls
    .toList();
```

### Validating font-weight ranges

```dart
FontWeight safeWeight(Color fg, Color bg, List<FontWeight> range) {
  if (range.isEmpty) return FontWeight.w400;
  return fg.recommendedFontWeight(against: bg, fontWeightRange: range);
}
```

---

## 🧪 Testing

```dart
test('contrast operations always return a usable color', () {
  for (final bg in [Colors.red, Colors.blue, Colors.white, Colors.black]) {
    final fg = Garnish.contrastingColor(Colors.black, against: bg);
    expect(GarnishMath.contrastRatio(fg, bg), greaterThan(1.0));
  }
});

test('fromHex returns null for malformed input', () {
  expect(GarnishColor.fromHex('zzz'), isNull);
});

test('recommendedFontWeight throws on empty range', () {
  expect(
    () => Colors.black.recommendedFontWeight(against: Colors.white, fontWeightRange: []),
    throwsA(isA<GarnishError>()),
  );
});
```

---

## 🔗 Related

- **[Core API](Core-API.md)** — return types of the main functions.
- **[GarnishColor](GarnishColor.md)** — where `fromHex` lives.
