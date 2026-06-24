import 'package:flutter/material.dart';
import 'package:garnish/garnish.dart';
import 'package:garnish/garnish_expansion.dart';

void main() => runApp(const GarnishExampleApp());

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
      home: const GarnishDemoPage(),
    );
  }
}

class GarnishDemoPage extends StatefulWidget {
  const GarnishDemoPage({super.key});

  @override
  State<GarnishDemoPage> createState() => _GarnishDemoPageState();
}

class _GarnishDemoPageState extends State<GarnishDemoPage> {
  static const _swatches = <Color>[
    Color(0xFF4F46E5), // indigo
    Color(0xFF2563EB), // blue
    Color(0xFF0EA5E9), // sky
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFFEC4899), // pink
    Color(0xFF111827), // near-black
    Color(0xFFF3F4F6), // near-white
  ];

  Color _base = _swatches.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garnish'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SwatchPicker(
            swatches: _swatches,
            selected: _base,
            onSelected: (color) => setState(() => _base = color),
          ),
          const SizedBox(height: 24),
          _AutoContrastCard(base: _base),
          const SizedBox(height: 24),
          _AnalysisCard(base: _base),
          const SizedBox(height: 24),
          _PaletteCard(base: _base),
        ],
      ),
    );
  }
}

/// A row of selectable color swatches.
class _SwatchPicker extends StatelessWidget {
  const _SwatchPicker({
    required this.swatches,
    required this.selected,
    required this.onSelected,
  });

  final List<Color> swatches;
  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in swatches)
          GestureDetector(
            onTap: () => onSelected(color),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.toARGB32() == selected.toARGB32()
                      // Use a contrasting ring so the selection is visible on
                      // any swatch.
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

/// Demonstrates automatically generated, readable text on any background.
class _AutoContrastCard extends StatelessWidget {
  const _AutoContrastCard({required this.base});

  final Color base;

  @override
  Widget build(BuildContext context) {
    // A shade of the base color that stays readable against the base color.
    final onBase = base.contrastingShade();
    // Garnish recommends a heavier weight when contrast is marginal.
    final weight = onBase.recommendedFontWeight(against: base);
    // Push a neutral toward whichever extreme reads best on the base.
    final neutral = Garnish.contrastingColor(Colors.white, against: base);

    return _SectionCard(
      title: 'Auto Contrast',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The quick brown fox',
              style: TextStyle(
                color: onBase,
                fontSize: 22,
                fontWeight: weight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'jumps over the lazy dog.',
              style: TextStyle(color: neutral, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the mathematical analysis of the selected color.
class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.base});

  final Color base;

  @override
  Widget build(BuildContext context) {
    final luminance = base.relativeLuminance();
    final classification = base.classify();
    final vsWhite = base.contrastRatio(Colors.white);
    final vsBlack = base.contrastRatio(Colors.black);

    return _SectionCard(
      title: 'Color Analysis',
      child: Column(
        children: [
          _InfoRow(label: 'Hex', value: '#${base.toHex()}'),
          _InfoRow(
            label: 'Relative luminance',
            value: luminance.toStringAsFixed(3),
          ),
          _InfoRow(
            label: 'Classification',
            value:
                classification == ColorClassification.light ? 'Light' : 'Dark',
          ),
          _InfoRow(
            label: 'Contrast vs white',
            value: '${vsWhite.toStringAsFixed(2)}:1',
          ),
          _InfoRow(
            label: 'Contrast vs black',
            value: '${vsBlack.toStringAsFixed(2)}:1',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _WcagBadge(
                label: 'AA on white',
                pass: base.meetsWCAGAA(Colors.white),
              ),
              const SizedBox(width: 8),
              _WcagBadge(
                label: 'AAA on white',
                pass: base.meetsWCAGAAA(Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Generates a harmonious palette from the selected color.
class _PaletteCard extends StatelessWidget {
  const _PaletteCard({required this.base});

  final Color base;

  @override
  Widget build(BuildContext context) {
    final palette = GarnishColorExpansion.expandToGradientMesh(base, size: 8);

    return _SectionCard(
      title: 'Generated Palette',
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                for (final color in palette)
                  Expanded(
                    child: Container(
                      height: 56,
                      color: color,
                      alignment: Alignment.center,
                      child: Text(
                        color.toHex(),
                        style: TextStyle(
                          color: color.contrastingShade(),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small presentational widgets.
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        child,
      ],
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

class _WcagBadge extends StatelessWidget {
  const _WcagBadge({required this.label, required this.pass});

  final String label;
  final bool pass;

  @override
  Widget build(BuildContext context) {
    final color = pass ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(pass ? Icons.check_circle : Icons.cancel,
              size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
