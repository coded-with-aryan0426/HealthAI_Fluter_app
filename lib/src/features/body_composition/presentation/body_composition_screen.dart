import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../application/body_provider.dart';
import '../../../database/models/body_entry_doc.dart';
import '../../../features/profile/application/user_provider.dart';

const _kBodyColor    = Color(0xFF00C9A7);
const _kBodyColorAlt = Color(0xFF845EC2);

// ── Metric enum ───────────────────────────────────────────────────────────────
enum _Metric { weight, bodyFat, bmi }

// ── Goal Weight Provider (in-memory, persisted via UserDoc) ───────────────────
final _goalWeightProvider = StateProvider<double?>((ref) {
  // Pre-populate from user profile if set
  return null;
});

class BodyCompositionScreen extends ConsumerStatefulWidget {
  const BodyCompositionScreen({super.key});

  @override
  ConsumerState<BodyCompositionScreen> createState() =>
      _BodyCompositionScreenState();
}

class _BodyCompositionScreenState extends ConsumerState<BodyCompositionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  _Metric _selectedMetric = _Metric.weight;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(bodyEntriesProvider);
    final latest  = ref.watch(latestBodyEntryProvider);
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final user    = ref.watch(userProvider);
    final goalWeight = ref.watch(_goalWeightProvider);

    // Compute BMI if height available
    final heightCm = user.heightCm;
    double? bmi;
    if (latest != null && latest.weightKg > 0 && heightCm != null && heightCm > 0) {
      final hm = heightCm / 100.0;
      bmi = latest.weightKg / (hm * hm);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepObsidian : AppColors.cloudGray,
      body: CustomScrollView(
        physics: scrollPhysics,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Body Composition',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            actions: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.target),
                onPressed: () => _showGoalWeightSheet(context, isDark, latest),
                tooltip: 'Set Goal Weight',
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.plus),
                onPressed: () => _showLogSheet(context, isDark),
                tooltip: 'Log Entry',
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // ── Stats Hero ───────────────────────────────────────
              _StatsHero(latest: latest, entries: entries, isDark: isDark)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.08, duration: 500.ms,
                      curve: Curves.easeOutCubic),

              const SizedBox(height: 20),

              // ── Metric Chip Selector + Chart ─────────────────────
              if (entries.length >= 2) ...[
                _MetricChipRow(
                  selected: _selectedMetric,
                  hasBf: entries.any((e) => e.bodyFatPct > 0),
                  hasBmi: heightCm != null && heightCm > 0,
                  isDark: isDark,
                  onSelect: (m) => setState(() => _selectedMetric = m),
                ).animate().fadeIn(delay: 120.ms, duration: 350.ms),

                const SizedBox(height: 12),

                _MetricChart(
                  entries: entries,
                  metric: _selectedMetric,
                  heightCm: heightCm,
                  isDark: isDark,
                ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

                const SizedBox(height: 20),
              ],

              // ── BMI Banner ───────────────────────────────────────
              if (bmi != null) ...[
                _BmiBanner(
                  bmi: bmi,
                  isDark: isDark,
                  user: ref.read(userProvider),
                ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

                const SizedBox(height: 20),
              ],

              // ── Goal Weight Progress ──────────────────────────────
              if (goalWeight != null && entries.isNotEmpty) ...[
                _GoalWeightCard(
                  entries: entries,
                  goalWeight: goalWeight,
                  isDark: isDark,
                  notifier: ref.read(bodyEntriesProvider.notifier),
                ).animate().fadeIn(delay: 280.ms, duration: 400.ms),

                const SizedBox(height: 20),
              ],

              // ── Body Fat & Waist strip ────────────────────────────
              if (latest != null) ...[
                _MeasurementStrip(entry: latest, isDark: isDark)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 20),
              ],

              // ── Log History ──────────────────────────────────────
              if (entries.isNotEmpty)
                _HistoryList(
                    entries: entries,
                    isDark: isDark,
                    onDelete: (id) {
                      ref
                          .read(bodyEntriesProvider.notifier)
                          .deleteEntry(id);
                    }).animate().fadeIn(delay: 360.ms, duration: 400.ms),

              // ── Empty state ──────────────────────────────────────
              if (entries.isEmpty)
                _EmptyState(
                        isDark: isDark,
                        onLog: () => _showLogSheet(context, isDark))
                    .animate()
                    .fadeIn(duration: 500.ms),

              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  void _showLogSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogEntrySheet(isDark: isDark),
    );
  }

  void _showGoalWeightSheet(
      BuildContext context, bool isDark, BodyEntryDoc? latest) {
    HapticFeedback.lightImpact();
    final ctrl = TextEditingController(
      text: ref.read(_goalWeightProvider)?.toStringAsFixed(1) ??
          (latest != null ? latest.weightKg.toStringAsFixed(1) : ''),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoalGlass : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(PhosphorIconsFill.target,
                      color: _kBodyColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Set Goal Weight',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Goal Weight (kg)',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.cloudGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final v = double.tryParse(ctrl.text);
                    if (v != null && v > 0) {
                      HapticFeedback.mediumImpact();
                      ref.read(_goalWeightProvider.notifier).state = v;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Goal weight set to ${v.toStringAsFixed(1)} kg ✓'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: _kBodyColor.withValues(alpha: 0.9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin:
                            const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBodyColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: _kBodyColor.withValues(alpha: 0.4),
                  ),
                  child: const Text('Save Goal',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Metric Chip Row ───────────────────────────────────────────────────────────
class _MetricChipRow extends StatelessWidget {
  final _Metric selected;
  final bool hasBf;
  final bool hasBmi;
  final bool isDark;
  final ValueChanged<_Metric> onSelect;

  const _MetricChipRow({
    required this.selected,
    required this.hasBf,
    required this.hasBmi,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      (_Metric.weight, 'Weight kg'),
      if (hasBf) (_Metric.bodyFat, 'Body Fat %'),
      if (hasBmi) (_Metric.bmi, 'BMI'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: chips.map((chip) {
          final (metric, label) = chip;
          final isSelected = selected == metric;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppAnimatedPressable(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(metric);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _kBodyColor
                      : _kBodyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: _kBodyColor.withValues(alpha: 0.25)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _kBodyColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : _kBodyColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Metric Chart ──────────────────────────────────────────────────────────────
class _MetricChart extends StatelessWidget {
  final List<BodyEntryDoc> entries;
  final _Metric metric;
  final double? heightCm;
  final bool isDark;

  const _MetricChart({
    required this.entries,
    required this.metric,
    required this.heightCm,
    required this.isDark,
  });

  String _metricLabel() {
    switch (metric) {
      case _Metric.weight:  return 'WEIGHT TREND';
      case _Metric.bodyFat: return 'BODY FAT TREND';
      case _Metric.bmi:     return 'BMI TREND';
    }
  }

  String _unitLabel() {
    switch (metric) {
      case _Metric.weight:  return 'kg';
      case _Metric.bodyFat: return '%';
      case _Metric.bmi:     return '';
    }
  }

  Color _chartColor() {
    switch (metric) {
      case _Metric.weight:  return _kBodyColor;
      case _Metric.bodyFat: return _kBodyColorAlt;
      case _Metric.bmi:     return AppColors.softIndigo;
    }
  }

  double _valueFor(BodyEntryDoc e) {
    switch (metric) {
      case _Metric.weight:
        return e.weightKg;
      case _Metric.bodyFat:
        return e.bodyFatPct;
      case _Metric.bmi:
        if (e.weightKg <= 0 || heightCm == null || heightCm! <= 0) return 0;
        final hm = heightCm! / 100.0;
        return e.weightKg / (hm * hm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = entries.take(14).toList().reversed.toList();
    final values = data.map(_valueFor).where((v) => v > 0).toList();
    if (values.length < 2) return const SizedBox.shrink();

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final color = _chartColor();
    final unit  = _unitLabel();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        child: Container(
          key: ValueKey(metric),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoalGlass : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _metricLabel(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${minV.toStringAsFixed(1)}$unit – ${maxV.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LineChartPainter(
                    entries: data,
                    getVal: _valueFor,
                    minVal: minV - (maxV - minV) * 0.1,
                    maxVal: maxV + (maxV - minV) * 0.1,
                    color: color,
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d').format(data.first.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(data.last.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BMI Banner ────────────────────────────────────────────────────────────────
class _BmiBanner extends ConsumerWidget {
  final double bmi;
  final bool isDark;
  final dynamic user;

  const _BmiBanner({
    required this.bmi,
    required this.isDark,
    required this.user,
  });

  static const _categories = [
    (0.0,  18.5, 'Underweight', Color(0xFF00B4D8)),
    (18.5, 25.0, 'Normal',      Color(0xFF00C9A7)),
    (25.0, 30.0, 'Overweight',  Color(0xFFFF9F43)),
    (30.0, 100.0,'Obese',       Color(0xFFFF4B4B)),
  ];

  String _category() {
    for (final c in _categories) {
      if (bmi >= c.$1 && bmi < c.$2) return c.$3;
    }
    return 'Obese';
  }

  Color _color() {
    for (final c in _categories) {
      if (bmi >= c.$1 && bmi < c.$2) return c.$4;
    }
    return const Color(0xFFFF4B4B);
  }

  void _showBmiModal(BuildContext context) {
    HapticFeedback.lightImpact();
    final category = _category();
    final color = _color();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // BMI value + category
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BMI',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color.withValues(alpha: 0.7))),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BMI scale
            Column(
              children: _categories.map((c) {
                final isActive = bmi >= c.$1 && bmi < c.$2;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? c.$4.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? Border.all(color: c.$4.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: c.$4,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        c.$3,
                        style: TextStyle(
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? c.$4
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppColors.lightTextSecondary),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        c.$2 < 100
                            ? '${c.$1.toStringAsFixed(1)} – ${c.$2.toStringAsFixed(1)}'
                            : '≥ ${c.$1.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Icon(PhosphorIconsFill.arrowLeft,
                            size: 12, color: c.$4),
                        Text(' You',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: c.$4)),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // AI tip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softIndigo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.softIndigo.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(PhosphorIconsFill.sparkle,
                      color: AppColors.softIndigo, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _aiTip(category),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.75)
                            : AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _aiTip(String category) {
    switch (category) {
      case 'Underweight':
        return 'Focus on nutrient-dense foods and strength training to build lean mass. Aim for a calorie surplus of ~300–500 kcal/day.';
      case 'Normal':
        return 'Great work! Maintain your BMI with balanced nutrition and consistent activity. Focus on body composition over raw weight.';
      case 'Overweight':
        return 'A modest calorie deficit of 300–500 kcal/day combined with 3–4 workouts per week can help you reach a healthy BMI.';
      default:
        return 'Consult a healthcare professional for a personalised plan. Consistent small steps — nutrition and movement — make a big difference.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = _category();
    final color = _color();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppAnimatedPressable(
        onTap: () => _showBmiModal(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoalGlass : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(PhosphorIconsFill.heartbeat,
                        color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'BMI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // BMI scale bar
              LayoutBuilder(builder: (_, bc) {
                const minBmi = 15.0;
                const maxBmi = 40.0;
                final pct = ((bmi - minBmi) / (maxBmi - minBmi))
                    .clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // Background gradient bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00B4D8),
                            Color(0xFF00C9A7),
                            Color(0xFFFF9F43),
                            Color(0xFFFF4B4B),
                          ],
                        ),
                      ),
                    ),
                    // Indicator
                    Positioned(
                      left: (bc.maxWidth * pct - 6).clamp(0.0, bc.maxWidth - 12),
                      top: -3,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.charcoalGlass : Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('15',
                      style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.lightTextSecondary)),
                  Text('18.5',
                      style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.lightTextSecondary)),
                  Text('25',
                      style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.lightTextSecondary)),
                  Text('30',
                      style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.lightTextSecondary)),
                  Text('40',
                      style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.lightTextSecondary)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(PhosphorIconsRegular.info,
                      size: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : AppColors.lightTextSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Tap to learn more',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.35)
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Goal Weight Progress Card ─────────────────────────────────────────────────
class _GoalWeightCard extends StatelessWidget {
  final List<BodyEntryDoc> entries;
  final double goalWeight;
  final bool isDark;
  final BodyEntriesNotifier notifier;

  const _GoalWeightCard({
    required this.entries,
    required this.goalWeight,
    required this.isDark,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final current = entries.first.weightKg;
    final start = entries.isNotEmpty ? entries.last.weightKg : current;

    // Progress: how much of the gap from start → goal has been covered
    final totalGap = (start - goalWeight).abs();
    final covered = (start - current).abs();
    final progress = totalGap == 0
        ? 1.0
        : (covered / totalGap).clamp(0.0, 1.0);

    final remaining = (current - goalWeight).abs();
    final isGoalReached = remaining < 0.1;

    // Estimated time
    final estDate = notifier.estimatedGoalDate(goalWeight);
    String etaLabel = '';
    if (estDate != null && !isGoalReached) {
      final daysLeft = estDate.difference(DateTime.now()).inDays;
      if (daysLeft > 0) {
        if (daysLeft < 7) {
          etaLabel = '~$daysLeft days at current rate';
        } else {
          final weeksLeft = (daysLeft / 7).ceil();
          etaLabel = '~$weeksLeft weeks at current rate';
        }
      }
    }

    final isLosing = goalWeight < current;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _kBodyColor.withValues(alpha: isDark ? 0.2 : 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kBodyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(PhosphorIconsFill.target,
                      color: _kBodyColor, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'GOAL WEIGHT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: _kBodyColor.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(),
                if (isGoalReached)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dynamicMint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Goal Reached! 🎉',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dynamicMint,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Current → Goal row
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : AppColors.lightTextSecondary,
                        )),
                    Text(
                      '${current.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Icon(
                  isLosing
                      ? PhosphorIconsFill.arrowRight
                      : PhosphorIconsFill.arrowRight,
                  color: _kBodyColor,
                  size: 16,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goal',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : AppColors.lightTextSecondary,
                        )),
                    Text(
                      '${goalWeight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _kBodyColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (!isGoalReached)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Remaining',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.45)
                                : AppColors.lightTextSecondary,
                          )),
                      Text(
                        '${remaining.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Progress bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: _kBodyColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: v.clamp(0.0, 1.0),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isGoalReached
                              ? [
                                  AppColors.dynamicMint,
                                  AppColors.dynamicMint
                                ]
                              : [_kBodyColor, _kBodyColor.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: _kBodyColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}% of the way',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kBodyColor,
                  ),
                ),
                if (etaLabel.isNotEmpty)
                  Text(
                    etaLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.lightTextSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Hero ────────────────────────────────────────────────────────────────
class _StatsHero extends ConsumerWidget {
  final BodyEntryDoc? latest;
  final List<BodyEntryDoc> entries;
  final bool isDark;

  const _StatsHero({
    required this.latest,
    required this.entries,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(bodyEntriesProvider.notifier);
    final delta7  = notifier.weightDelta(7);
    final delta30 = notifier.weightDelta(30);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0D2B26), const Color(0xFF0A1F1C)]
                : [const Color(0xFFE0FAF5), const Color(0xFFD0F0E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
              color: _kBodyColor.withValues(alpha: isDark ? 0.25 : 0.3)),
          boxShadow: [
            BoxShadow(
              color: _kBodyColor.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kBodyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(PhosphorIconsFill.scales,
                      color: _kBodyColor, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT WEIGHT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: _kBodyColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      latest != null
                          ? '${latest!.weightKg.toStringAsFixed(1)} kg'
                          : '—',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (latest != null)
                  Text(
                    DateFormat('MMM d').format(latest!.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.lightTextSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _DeltaChip(label: '7-day', delta: delta7, isDark: isDark),
                const SizedBox(width: 10),
                _DeltaChip(label: '30-day', delta: delta30, isDark: isDark),
                const Spacer(),
                Text(
                  '${entries.length} logs',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kBodyColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String label;
  final double delta;
  final bool isDark;

  const _DeltaChip(
      {required this.label, required this.delta, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUp  = delta > 0;
    final color = isUp ? AppColors.danger : AppColors.dynamicMint;
    final icon  = isUp
        ? PhosphorIconsFill.arrowUp
        : PhosphorIconsFill.arrowDown;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: delta == 0
            ? Colors.grey.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: delta == 0
              ? Colors.grey.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (delta != 0) Icon(icon, size: 11, color: color),
          if (delta != 0) const SizedBox(width: 3),
          Text(
            delta == 0
                ? '$label: —'
                : '$label: ${delta.abs().toStringAsFixed(1)}kg',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: delta == 0 ? Colors.grey : color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Line Chart Painter ────────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<BodyEntryDoc> entries;
  final double Function(BodyEntryDoc) getVal;
  final double minVal;
  final double maxVal;
  final Color color;
  final bool isDark;

  const _LineChartPainter({
    required this.entries,
    required this.getVal,
    required this.minVal,
    required this.maxVal,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final valid = entries.where((e) => getVal(e) > 0).toList();
    if (valid.length < 2) return;

    final range = maxVal - minVal;
    if (range <= 0) return;

    final xStep = size.width / (valid.length - 1);

    Offset point(int i) {
      final x = i * xStep;
      final y = size.height -
          ((getVal(valid[i]) - minVal) / range) * size.height;
      return Offset(x, y.clamp(0.0, size.height));
    }

    // Fill gradient
    final fillPath = Path();
    fillPath.moveTo(point(0).dx, size.height);
    for (int i = 0; i < valid.length; i++) {
      fillPath.lineTo(point(i).dx, point(i).dy);
    }
    fillPath.lineTo(point(valid.length - 1).dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(point(0).dx, point(0).dy);
    for (int i = 1; i < valid.length; i++) {
      linePath.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = color;
    final dotBg = Paint()
      ..color = isDark ? const Color(0xFF1A1D24) : Colors.white;
    for (int i = 0; i < valid.length; i++) {
      final p = point(i);
      canvas.drawCircle(p, 5, dotBg);
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => true;
}

// ── Measurement Strip ─────────────────────────────────────────────────────────
class _MeasurementStrip extends StatelessWidget {
  final BodyEntryDoc entry;
  final bool isDark;

  const _MeasurementStrip({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (entry.bodyFatPct > 0)
            Expanded(
              child: _MeasureCard(
                label: 'BODY FAT',
                value: '${entry.bodyFatPct.toStringAsFixed(1)}%',
                icon: PhosphorIconsFill.percent,
                color: _kBodyColorAlt,
                isDark: isDark,
              ),
            ),
          if (entry.bodyFatPct > 0 && entry.waistCm > 0)
            const SizedBox(width: 12),
          if (entry.waistCm > 0)
            Expanded(
              child: _MeasureCard(
                label: 'WAIST',
                value: '${entry.waistCm.toStringAsFixed(1)} cm',
                icon: PhosphorIconsFill.ruler,
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
          if (entry.waistCm > 0 && entry.hipCm > 0)
            const SizedBox(width: 12),
          if (entry.hipCm > 0)
            Expanded(
              child: _MeasureCard(
                label: 'HIP',
                value: '${entry.hipCm.toStringAsFixed(1)} cm',
                icon: PhosphorIconsFill.ruler,
                color: AppColors.softIndigo,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _MeasureCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MeasureCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History List ──────────────────────────────────────────────────────────────
class _HistoryList extends StatelessWidget {
  final List<BodyEntryDoc> entries;
  final bool isDark;
  final void Function(int id) onDelete;

  const _HistoryList({
    required this.entries,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...entries.take(20).toList().asMap().entries.map((e) {
            final i     = e.key;
            final entry = e.value;
            return Dismissible(
              key: ValueKey(entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(PhosphorIconsFill.trash,
                    color: AppColors.danger, size: 20),
              ),
              onDismissed: (_) => onDelete(entry.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.charcoalGlass : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _kBodyColor.withValues(alpha: isDark ? 0.12 : 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _kBodyColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(PhosphorIconsFill.scales,
                          color: _kBodyColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE, MMM d, yyyy')
                                .format(entry.date),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            _subtitle(entry),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      entry.weightKg > 0
                          ? '${entry.weightKg.toStringAsFixed(1)} kg'
                          : '—',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kBodyColor,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: Duration(milliseconds: i * 50))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.06, duration: 300.ms),
            );
          }),
        ],
      ),
    );
  }

  String _subtitle(BodyEntryDoc e) {
    final parts = <String>[];
    if (e.bodyFatPct > 0) parts.add('${e.bodyFatPct.toStringAsFixed(1)}% fat');
    if (e.waistCm > 0) parts.add('${e.waistCm.toStringAsFixed(0)}cm waist');
    if (e.note.isNotEmpty) parts.add(e.note);
    return parts.isEmpty ? 'Weight only' : parts.join(' · ');
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onLog;

  const _EmptyState({required this.isDark, required this.onLog});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kBodyColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(PhosphorIconsFill.scales,
                color: _kBodyColor, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'No measurements yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your first body measurement\nto start tracking your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onLog,
              icon: const Icon(PhosphorIconsFill.plus, size: 18),
              label: const Text('Log Measurement',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBodyColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                shadowColor: _kBodyColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Log Entry Sheet ───────────────────────────────────────────────────────────
class _LogEntrySheet extends ConsumerStatefulWidget {
  final bool isDark;
  const _LogEntrySheet({required this.isDark});

  @override
  ConsumerState<_LogEntrySheet> createState() => _LogEntrySheetState();
}

class _LogEntrySheetState extends ConsumerState<_LogEntrySheet> {
  final _weightCtrl = TextEditingController();
  final _fatCtrl    = TextEditingController();
  final _waistCtrl  = TextEditingController();
  final _hipCtrl    = TextEditingController();
  final _noteCtrl   = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final latest = ref.read(latestBodyEntryProvider);
      if (latest != null) {
        if (latest.weightKg > 0)
          _weightCtrl.text = latest.weightKg.toStringAsFixed(1);
        if (latest.bodyFatPct > 0)
          _fatCtrl.text = latest.bodyFatPct.toStringAsFixed(1);
        if (latest.waistCm > 0)
          _waistCtrl.text = latest.waistCm.toStringAsFixed(1);
        if (latest.hipCm > 0)
          _hipCtrl.text = latest.hipCm.toStringAsFixed(1);
      }
    });
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _fatCtrl.dispose();
    _waistCtrl.dispose();
    _hipCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final weightText = _weightCtrl.text.trim();
    if (weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight is required')));
      return;
    }
    final weight = double.tryParse(weightText) ?? 0;
    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid weight')));
      return;
    }

    setState(() => _saving = true);
    await ref.read(bodyEntriesProvider.notifier).addEntry(
          weightKg: weight,
          bodyFatPct: double.tryParse(_fatCtrl.text) ?? 0,
          waistCm: double.tryParse(_waistCtrl.text) ?? 0,
          hipCm: double.tryParse(_hipCtrl.text) ?? 0,
          note: _noteCtrl.text.trim(),
        );
    setState(() => _saving = false);
    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${weight.toStringAsFixed(1)} kg logged ✓'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _kBodyColor.withValues(alpha: 0.9),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  const Icon(PhosphorIconsFill.scales,
                      color: _kBodyColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Log Measurement',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  _FieldLabel('Weight (kg) *'),
                  _NumField(
                      controller: _weightCtrl,
                      hint: 'e.g. 75.5',
                      isDark: widget.isDark),
                  const SizedBox(height: 16),
                  _FieldLabel('Body Fat (%)'),
                  _NumField(
                      controller: _fatCtrl,
                      hint: 'e.g. 18.2',
                      isDark: widget.isDark),
                  const SizedBox(height: 16),
                  _FieldLabel('Waist (cm)'),
                  _NumField(
                      controller: _waistCtrl,
                      hint: 'e.g. 82',
                      isDark: widget.isDark),
                  const SizedBox(height: 16),
                  _FieldLabel('Hip (cm)'),
                  _NumField(
                      controller: _hipCtrl,
                      hint: 'e.g. 96',
                      isDark: widget.isDark),
                  const SizedBox(height: 16),
                  _FieldLabel('Notes'),
                  TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      hintText: 'Optional note',
                      hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.35)),
                      filled: true,
                      fillColor: widget.isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.cloudGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBodyColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 6,
                        shadowColor: _kBodyColor.withValues(alpha: 0.4),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;

  const _NumField(
      {required this.controller, required this.hint, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.cloudGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
