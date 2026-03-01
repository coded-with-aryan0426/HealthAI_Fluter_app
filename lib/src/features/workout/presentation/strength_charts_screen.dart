import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../application/strength_chart_provider.dart';

// ── Active chart tab provider ─────────────────────────────────────────────────
enum _ChartTab { volume, oneRM, reps }

final _chartTabProvider = StateProvider<_ChartTab>((ref) => _ChartTab.oneRM);

class StrengthChartsScreen extends ConsumerWidget {
  const StrengthChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedExercise = ref.watch(selectedExerciseProvider);
    final data = ref.watch(strengthChartDataProvider(selectedExercise));
    final activeTab = ref.watch(_chartTabProvider);

    // Auto-select first exercise if none selected
    if (selectedExercise.isEmpty && data.exerciseNames.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedExerciseProvider.notifier).state =
            data.exerciseNames.first;
      });
    }

      return Scaffold(
        backgroundColor:
            isDark ? AppColors.deepObsidian : const Color(0xFFF7F8FC),
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 110,
              backgroundColor:
                  isDark ? AppColors.deepObsidian : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(PhosphorIconsRegular.arrowLeft,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      size: 18),
                ),
                onPressed: () => context.pop(),
              ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 44),
              title: Text(
                'Strength Charts',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
        body: data.exerciseNames.isEmpty
            ? _EmptyState(isDark: isDark)
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Exercise picker ──────────────────────────────────────
                    _ExercisePicker(
                      names: data.exerciseNames,
                      selected: selectedExercise,
                      isDark: isDark,
                      onSelect: (name) {
                        HapticFeedback.selectionClick();
                        ref.read(selectedExerciseProvider.notifier).state =
                            name;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Chart Tab Switcher ───────────────────────────────────
                    _ChartTabBar(
                      activeTab: activeTab,
                      isDark: isDark,
                      onSelect: (tab) {
                        HapticFeedback.selectionClick();
                        ref.read(_chartTabProvider.notifier).state = tab;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Chart (animated switch on tab change) ────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(activeTab),
                        child: _buildActiveChart(
                          activeTab: activeTab,
                          points: data.selectedHistory.points,
                          weeklyVolume: data.weeklyVolume,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── All-time PRs ─────────────────────────────────────────
                    if (data.prs.isNotEmpty) ...[
                      _SectionHeader(
                          title: 'All-Time PRs',
                          subtitle: 'By estimated 1RM',
                          isDark: isDark),
                      const SizedBox(height: 12),
                      ...data.prs.take(10).toList().asMap().entries.map(
                            (e) => _PRRow(
                              pr: e.value,
                              rank: e.key + 1,
                              isDark: isDark,
                            )
                                .animate(
                                    delay: Duration(milliseconds: 60 * e.key))
                                .fadeIn(duration: 350.ms)
                                .slideX(begin: 0.05, end: 0),
                          ),
                    ],
                    ],
                  ),
                ),
        ),
      );
    }

    Widget _buildActiveChart({
    required _ChartTab activeTab,
    required List<ExerciseDataPoint> points,
    required List<WeeklyVolumeBar> weeklyVolume,
    required bool isDark,
  }) {
    switch (activeTab) {
      case _ChartTab.volume:
        return _WeeklyVolumeBarChart(
          bars: weeklyVolume,
          accent: AppColors.warning,
          isDark: isDark,
        );
      case _ChartTab.oneRM:
        return _OneRMLineChart(
          points: points,
          accent: AppColors.dynamicMint,
          isDark: isDark,
        );
      case _ChartTab.reps:
        return _RepsLineChart(
          points: points,
          accent: AppColors.softIndigo,
          isDark: isDark,
        );
    }
  }
}

// ── Exercise picker (horizontal chips) ───────────────────────────────────────

class _ExercisePicker extends StatelessWidget {
  final List<String> names;
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelect;
  const _ExercisePicker({
    required this.names,
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final name = names[i];
          final active = name == selected;
          return GestureDetector(
            onTap: () => onSelect(name),
            child: AnimatedContainer(
              duration: 200.ms,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.softIndigo
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                name,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : (isDark
                          ? Colors.white60
                          : AppColors.lightTextSecondary),
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Chart Tab Bar ─────────────────────────────────────────────────────────────

class _ChartTabBar extends StatelessWidget {
  final _ChartTab activeTab;
  final bool isDark;
  final ValueChanged<_ChartTab> onSelect;

  const _ChartTabBar({
    required this.activeTab,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (_ChartTab.volume,  'Volume',  PhosphorIconsFill.chartBar),
      (_ChartTab.oneRM,   '1RM',     PhosphorIconsFill.lightning),
      (_ChartTab.reps,    'Reps',    PhosphorIconsFill.repeat),
    ];

    final descriptions = {
      _ChartTab.volume: 'Total kg lifted per week',
      _ChartTab.oneRM:  'Estimated 1-rep max (Epley)',
      _ChartTab.reps:   'Max reps in best set per session',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: tabs.map((t) {
              final (tab, label, icon) = t;
              final isActive = tab == activeTab;
              Color accent;
              switch (tab) {
                case _ChartTab.volume: accent = AppColors.warning; break;
                case _ChartTab.oneRM:  accent = AppColors.dynamicMint; break;
                case _ChartTab.reps:   accent = AppColors.softIndigo; break;
              }
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark ? AppColors.charcoalGlass : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size: 14,
                            color: isActive
                                ? accent
                                : (isDark ? Colors.white38 : Colors.black38)),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isActive
                                ? accent
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            descriptions[activeTab] ?? '',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  const _SectionHeader(
      {required this.title, required this.subtitle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : AppColors.lightTextSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Weight line chart ─────────────────────────────────────────────────────────

class _WeightLineChart extends StatelessWidget {
  final List<ExerciseDataPoint> points;
  final Color accent;
  final bool isDark;
  const _WeightLineChart(
      {required this.points, required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _NoDataCard(isDark: isDark);

    final spots = points.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.bestWeightKg))
        .toList();
    final maxY =
        points.map((p) => p.bestWeightKg).reduce(math.max) * 1.15;

    return _ChartCard(
      isDark: isDark,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: math.max(1, (points.length / 5).floorToDouble()),
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= points.length) {
                    return const SizedBox.shrink();
                  }
                  final d = points[idx].date;
                  return Text(
                    '${d.day}/${d.month}',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 9),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: accent,
                  strokeWidth: 2,
                  strokeColor: isDark ? Colors.black : Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.25),
                    accent.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} kg',
                        TextStyle(
                            color: accent, fontWeight: FontWeight.bold),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Estimated 1RM line chart ──────────────────────────────────────────────────

class _OneRMLineChart extends StatelessWidget {
  final List<ExerciseDataPoint> points;
  final Color accent;
  final bool isDark;
  const _OneRMLineChart(
      {required this.points, required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _NoDataCard(isDark: isDark);

    final spots = points.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.estimated1RM))
        .toList();
    final maxY =
        points.map((p) => p.estimated1RM).reduce(math.max) * 1.15;

    return _ChartCard(
      isDark: isDark,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: math.max(1, (points.length / 5).floorToDouble()),
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= points.length) {
                    return const SizedBox.shrink();
                  }
                  final d = points[idx].date;
                  return Text(
                    '${d.day}/${d.month}',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 9),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: accent,
                  strokeWidth: 2,
                  strokeColor: isDark ? Colors.black : Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.20),
                    accent.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} kg (1RM)',
                        TextStyle(
                            color: accent, fontWeight: FontWeight.bold),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Weekly volume bar chart ───────────────────────────────────────────────────

class _WeeklyVolumeBarChart extends StatelessWidget {
  final List<WeeklyVolumeBar> bars;
  final Color accent;
  final bool isDark;
  const _WeeklyVolumeBarChart(
      {required this.bars, required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hasData = bars.any((b) => b.volumeKg > 0);
    if (!hasData) return _NoDataCard(isDark: isDark);

    final maxY =
        bars.map((b) => b.volumeKg.toDouble()).reduce(math.max) * 1.2;

    return _ChartCard(
      isDark: isDark,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) {
                  if (v == 0) return const SizedBox.shrink();
                  return Text(
                    v >= 1000
                        ? '${(v / 1000).toStringAsFixed(1)}k'
                        : '${v.toInt()}',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 9),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= bars.length) {
                    return const SizedBox.shrink();
                  }
                  // Show every 2nd label to avoid crowding
                  if (idx % 2 != 0) return const SizedBox.shrink();
                  final d = bars[idx].weekStart;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${d.day}/${d.month}',
                      style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 8),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: bars.asMap().entries.map((e) {
            final isLast = e.key == bars.length - 1;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.volumeKg.toDouble(),
                  color: isLast ? accent : accent.withValues(alpha: 0.45),
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5)),
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.toInt()} kg',
                TextStyle(color: accent, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reps line chart ───────────────────────────────────────────────────────────

class _RepsLineChart extends StatelessWidget {
  final List<ExerciseDataPoint> points;
  final Color accent;
  final bool isDark;
  const _RepsLineChart(
      {required this.points, required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _NoDataCard(isDark: isDark);

    // Compute max reps per session: volume / bestWeightKg ≈ reps (use stored totalVolume / bestWeight)
    final repsPerPoint = points.map((p) {
      if (p.bestWeightKg <= 0) return 0.0;
      return (p.totalVolume / p.bestWeightKg);
    }).toList();

    final spots = repsPerPoint.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final maxY = repsPerPoint.isEmpty
        ? 20.0
        : repsPerPoint.reduce(math.max) * 1.2;

    return _ChartCard(
      isDark: isDark,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: math.max(1, (points.length / 5).floorToDouble()),
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= points.length) {
                    return const SizedBox.shrink();
                  }
                  final d = points[idx].date;
                  return Text(
                    '${d.day}/${d.month}',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 9),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: accent,
                  strokeWidth: 2,
                  strokeColor: isDark ? Colors.black : Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.20),
                    accent.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} reps',
                        TextStyle(
                            color: accent, fontWeight: FontWeight.bold),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── PR row ────────────────────────────────────────────────────────────────────

class _PRRow extends StatelessWidget {
  final dynamic pr; // ExercisePRDoc
  final int rank;
  final bool isDark;
  const _PRRow({required this.pr, required this.rank, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isGold = rank == 1;
    final isSilver = rank == 2;
    final isBronze = rank == 3;
    final medalColor = isGold
        ? const Color(0xFFFFD700)
        : isSilver
            ? const Color(0xFFC0C0C0)
            : isBronze
                ? const Color(0xFFCD7F32)
                : AppColors.softIndigo;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                    color: medalColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pr.exerciseName as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(pr.estimated1RMKg as double).toStringAsFixed(1)} kg',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: medalColor),
              ),
              Text(
                '1RM est.',
                style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : Colors.black38),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(pr.maxWeightKg as double).toStringAsFixed(1)} kg × ${pr.maxReps}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : AppColors.lightTextSecondary),
              ),
              Text(
                'best set',
                style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.white24 : Colors.black26),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared card wrapper ───────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _ChartCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
      ),
      child: child,
    );
  }
}

class _NoDataCard extends StatelessWidget {
  final bool isDark;
  const _NoDataCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Text(
        'Complete a workout to see your progress',
        style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.softIndigo.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsFill.chartLine,
                  size: 38, color: AppColors.softIndigo),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(
              'No workout data yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              'Complete a workout with logged sets to see your strength charts.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white38 : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 180.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
