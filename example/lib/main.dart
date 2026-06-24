import 'package:flutter/material.dart';
import 'package:garnish/garnish.dart';
import 'package:garnish/garnish_expansion.dart';

void main() => runApp(const GarnishExampleApp());

/// A shared palette of seed colors used across the demo tabs.
const kSwatches = <Color>[
  Color(0xFF4F46E5), // indigo
  Color(0xFF2563EB), // blue
  Color(0xFF0EA5E9), // sky
  Color(0xFF10B981), // emerald
  Color(0xFFF59E0B), // amber
  Color(0xFFEF4444), // red
  Color(0xFFEC4899), // pink
  Color(0xFF8B5CF6), // violet
  Color(0xFF111827), // near-black
  Color(0xFF6B7280), // grey
  Color(0xFFF3F4F6), // near-white
  Color(0xFFFFFFFF), // white
];

class GarnishExampleApp extends StatelessWidget {
  const GarnishExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garnish',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4F46E5),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    ContrastTab(),
    AnalysisTab(),
    PaletteTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garnish'), centerTitle: true),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.contrast_outlined),
            selectedIcon: Icon(Icons.contrast),
            label: 'Contrast',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: 'Palette',
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Contrast tab — generate a readable shade of a color against itself.
// ===========================================================================

class ContrastTab extends StatefulWidget {
  const ContrastTab({super.key});

  @override
  State<ContrastTab> createState() => _ContrastTabState();
}

class _ContrastTabState extends State<ContrastTab> {
  Color _base = kSwatches.first;
  double _targetRatio = GarnishMath.wcagAAThreshold;
  ContrastDirection _direction = ContrastDirection.auto;
  BlendStyle? _blendStyle;

  @override
  Widget build(BuildContext context) {
    final shade = Garnish.contrastingShade(
      _base,
      targetRatio: _targetRatio,
      direction: _direction,
      blendStyle: _blendStyle,
    );
    final achieved = _base.contrastRatio(shade);
    final weight = shade.recommendedFontWeight(against: _base);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live preview.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _base,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aa',
                  style: TextStyle(
                      color: shade, fontSize: 56, fontWeight: weight)),
              Text(
                'A contrasting shade of the same color, generated to stay '
                'readable on top of it.',
                style: TextStyle(color: shade, fontSize: 15),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Pill(text: '#${_base.toHex()}', color: shade),
                  const SizedBox(width: 8),
                  _Pill(text: '→ #${shade.toHex()}', color: shade),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoRow(
            label: 'Achieved contrast',
            value: '${achieved.toStringAsFixed(2)}:1'),
        _InfoRow(label: 'Recommended weight', value: _weightName(weight)),
        const SizedBox(height: 16),

        const _SectionTitle('Base color'),
        SwatchPicker(
          selected: _base,
          onSelected: (c) => setState(() => _base = c),
        ),
        const SizedBox(height: 20),

        LabeledSlider(
          title: 'Target ratio',
          value: _targetRatio,
          min: 1,
          max: 21,
          divisions: 40,
          valueLabel: '${_targetRatio.toStringAsFixed(1)}:1',
          onChanged: (v) => setState(() => _targetRatio = v),
        ),
        const SizedBox(height: 12),

        const _SectionTitle('Direction'),
        ChipRow<ContrastDirection>(
          selected: _direction,
          choices: [
            for (final d in ContrastDirection.values) Choice(d, d.name),
          ],
          onSelected: (d) => setState(() => _direction = d),
        ),
        const SizedBox(height: 16),

        const _SectionTitle('Blend style'),
        ChipRow<BlendStyle?>(
          selected: _blendStyle,
          choices: [
            const Choice(null, 'default'),
            for (final b in BlendStyle.values) Choice(b, b.name),
          ],
          onSelected: (b) => setState(() => _blendStyle = b),
        ),
      ],
    );
  }
}

// ===========================================================================
// Analysis tab — inspect a foreground/background pair.
// ===========================================================================

class AnalysisTab extends StatefulWidget {
  const AnalysisTab({super.key});

  @override
  State<AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends State<AnalysisTab> {
  Color _foreground = const Color(0xFF111827);
  Color _background = const Color(0xFFF3F4F6);
  BrightnessMethod _method = BrightnessMethod.luminance;

  @override
  Widget build(BuildContext context) {
    final ratio = _foreground.contrastRatio(_background);
    final aa = _foreground.meetsWCAGAA(_background);
    final aaa = _foreground.meetsWCAGAAA(_background);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            'Sample text',
            style: TextStyle(
                color: _foreground, fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text('${ratio.toStringAsFixed(2)}:1',
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold)),
              const Text('contrast ratio'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WcagBadge(label: 'AA', pass: aa),
            const SizedBox(width: 8),
            WcagBadge(label: 'AAA', pass: aaa),
          ],
        ),
        const SizedBox(height: 16),
        _InfoRow(
          label: 'Foreground luminance',
          value: _foreground.brightness(method: _method).toStringAsFixed(3),
        ),
        _InfoRow(
          label: 'Background luminance',
          value: _background.brightness(method: _method).toStringAsFixed(3),
        ),
        _InfoRow(
          label: 'Background is',
          value: _background.classify() == ColorClassification.light
              ? 'Light'
              : 'Dark',
        ),
        _InfoRow(label: 'Foreground hex', value: '#${_foreground.toHex()}'),
        _InfoRow(label: 'Background hex', value: '#${_background.toHex()}'),
        const SizedBox(height: 16),
        const _SectionTitle('Brightness method'),
        ChipRow<BrightnessMethod>(
          selected: _method,
          choices: [
            for (final m in BrightnessMethod.values) Choice(m, m.name),
          ],
          onSelected: (m) => setState(() => _method = m),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Foreground'),
        SwatchPicker(
          selected: _foreground,
          onSelected: (c) => setState(() => _foreground = c),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Background'),
        SwatchPicker(
          selected: _background,
          onSelected: (c) => setState(() => _background = c),
        ),
      ],
    );
  }
}

// ===========================================================================
// Palette tab — expand a seed color into a palette.
// ===========================================================================

enum _Strategy { gradientMesh, variations, linear, expand, repeat }

class PaletteTab extends StatefulWidget {
  const PaletteTab({super.key});

  @override
  State<PaletteTab> createState() => _PaletteTabState();
}

class _PaletteTabState extends State<PaletteTab> {
  Color _base = kSwatches.first;
  int _count = 8;
  _Strategy _strategy = _Strategy.gradientMesh;

  List<Color> _palette() {
    final pair = [_base, _base.contrastingShade()];
    switch (_strategy) {
      case _Strategy.gradientMesh:
        return GarnishColorExpansion.expandToGradientMesh(_base, size: _count);
      case _Strategy.variations:
        return GarnishColorExpansion.generateVariations(_base, count: _count);
      case _Strategy.linear:
        return GarnishColorExpansion.linearInterpolation(pair, to: _count);
      case _Strategy.expand:
        return GarnishColorExpansion.expand(pair, to: _count);
      case _Strategy.repeat:
        return GarnishColorExpansion.simpleRepeat(pair, to: _count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Wrap(
            children: [
              for (final color in palette)
                Container(
                  width: MediaQuery.sizeOf(context).width / 4 - 8,
                  height: 72,
                  color: color,
                  alignment: Alignment.center,
                  child: Text(
                    color.toHex(),
                    style: TextStyle(
                      color: color.contrastingShade(),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle('Seed color'),
        SwatchPicker(
          selected: _base,
          onSelected: (c) => setState(() => _base = c),
        ),
        const SizedBox(height: 20),
        LabeledSlider(
          title: 'Count',
          value: _count.toDouble(),
          min: 2,
          max: 16,
          divisions: 14,
          valueLabel: '$_count',
          onChanged: (v) => setState(() => _count = v.round()),
        ),
        const SizedBox(height: 12),
        const _SectionTitle('Strategy'),
        ChipRow<_Strategy>(
          selected: _strategy,
          choices: const [
            Choice(_Strategy.gradientMesh, 'gradient mesh'),
            Choice(_Strategy.variations, 'variations'),
            Choice(_Strategy.linear, 'linear'),
            Choice(_Strategy.expand, 'expand'),
            Choice(_Strategy.repeat, 'repeat'),
          ],
          onSelected: (s) => setState(() => _strategy = s),
        ),
      ],
    );
  }
}

// ===========================================================================
// Reusable presentational widgets.
// ===========================================================================

/// A row of selectable color swatches.
class SwatchPicker extends StatelessWidget {
  const SwatchPicker(
      {required this.selected, required this.onSelected, super.key});

  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final color in kSwatches)
          GestureDetector(
            onTap: () => onSelected(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.toARGB32() == selected.toARGB32()
                      ? color.contrastingShade()
                      : Colors.black12,
                  width: color.toARGB32() == selected.toARGB32() ? 3 : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A labeled slider with a trailing value badge.
class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
    super.key,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            Text(valueLabel,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// A choice in a [ChipRow].
class Choice<T> {
  const Choice(this.value, this.label);
  final T value;
  final String label;
}

/// A wrapping row of single-select [ChoiceChip]s.
class ChipRow<T> extends StatelessWidget {
  const ChipRow({
    required this.choices,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Choice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final choice in choices)
          ChoiceChip(
            label: Text(choice.label),
            selected: choice.value == selected,
            onSelected: (_) => onSelected(choice.value),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class WcagBadge extends StatelessWidget {
  const WcagBadge({required this.label, required this.pass, super.key});
  final String label;
  final bool pass;

  @override
  Widget build(BuildContext context) {
    final color = pass ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(pass ? Icons.check_circle : Icons.cancel,
              size: 18, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// A small rounded label used inside the contrast preview.
class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

String _weightName(FontWeight w) => switch (w) {
      FontWeight.w100 => 'Thin (100)',
      FontWeight.w200 => 'Extra-light (200)',
      FontWeight.w300 => 'Light (300)',
      FontWeight.w400 => 'Regular (400)',
      FontWeight.w500 => 'Medium (500)',
      FontWeight.w600 => 'Semibold (600)',
      FontWeight.w700 => 'Bold (700)',
      FontWeight.w800 => 'Extra-bold (800)',
      FontWeight.w900 => 'Black (900)',
      _ => w.toString(),
    };
