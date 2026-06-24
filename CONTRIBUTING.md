# Contributing

Thanks for your interest in improving Garnish for Flutter!

## Getting set up

```bash
flutter pub get
flutter analyze
flutter test
```

## Guidelines

- Keep the public API aligned with the original
  [SwiftUI Garnish](https://github.com/Aeastr/Garnish) where it makes sense;
  document any intentional Dart/Flutter divergences in the README.
- Run `flutter analyze` and `flutter test` before opening a pull request — both
  must be clean.
- Add or update tests for any behavior change.
- Prefer the modern floating-point `Color` API (`.r`/`.g`/`.b`/`.a`,
  `Color.from`) over the deprecated integer accessors.

## Reporting issues

Open an issue describing the problem, the expected behavior, and a minimal
reproduction (a small color + parameter combination is usually enough).
