import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../application/weekly_nutrition_insight_provider.dart';
import '../application/nutrition_targets_provider.dart';
import '../application/meal_provider.dart';

class WeeklyNutritionReportScreen extends ConsumerWidget {
  const WeeklyNutritionReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insightAsync = ref.watch(weeklyNutritionInsightProvider);
    final targets = ref.watch(nutritionTargetsProvider);

    // Compute last 7 days of meals for the bar chart
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepObsidian : const Color(0xFFF7F8FC),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 60,
            backgroundColor: isDark ? AppColors.deepObsidian : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
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
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/nutrition-tab'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                'Weekly Report',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(PhosphorIconsRegular.arrowsClockwise,
                      color: AppColors.dynamicMint, size: 16),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(weeklyNutritionInsightProvider.notifier).refresh();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 7-day calorie bar chart ──────────────────────────────────
              _WeeklyCalorieChart(
                weekDays: weekDays,
                target: targets.calories,
                isDark: isDark,
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // ── AI Weekly Report card ────────────────────────────────────
              insightAsync.when(
                loading: () => _ReportLoadingCard(isDark: isDark)
                    .animate()
                    .fadeIn(delay: 100.ms),
                error: (_, __) => _NoDataCard(isDark: isDark)
                    .animate()
                    .fadeIn(delay: 100.ms),
                data: (insight) => insight == null
                    ? _NoDataCard(isDark: isDark).animate().fadeIn(delay: 100.ms)
                    : _WeeklyInsightCard(
                        insight: insight,
                        isDark: isDark,
                      ).animate().fadeIn(delay: 100.ms),
              ),

              const SizedBox(height: 20),

              // ── Macro averages ──────────────────────────────────────────
              _MacroAveragesCard(
                weekDays: weekDays,
                targets: targets,
                isDark: isDark,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Weekly Calorie Chart ──────────────────────────────────────────────────────

class _WeeklyCalorieChart extends ConsumerWidget {
  final List<DateTime> weekDays;
  final int target;
  final bool isDark;

  const _WeeklyCalorieChart({
    required this.weekDays,
    required this.target,
    required this.isDark,
  });

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _shortLabel(DateTime d) {
    return _dayLabels[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gather calories per day
    final dailyTotals = weekDays.map((day) {
      final meals = ref.watch(mealsForDateProvider(day));
      return meals.fold(0, (s, m) => s + m.calories);
    }).toList();

    final maxVal = (dailyTotals.reduce((a, b) => a > b ? a : b))
        .clamp(target, 999999)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('CALORIES THIS WEEK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.dynamicMint.withValues(alpha: 0.8),
                    )),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Goal: $target kcal',
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.dynamicMint,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final cal = dailyTotals[i];
                  final barH = maxVal > 0
                      ? (cal / maxVal * 100).clamp(4.0, 100.0)
                      : 4.0;
                  final isToday = weekDays[i].day == DateTime.now().day &&
                      weekDays[i].month == DateTime.now().month;
                  final overTarget = cal > target;
                  final barColor = cal == 0
                      ? (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06))
                      : overTarget
                          ? AppColors.warning
                          : AppColors.dynamicMint;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (cal > 0 && isToday)
                          Text('$cal',
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dynamicMint))
                        else if (cal > 0)
                          Text('$cal',
                              style: TextStyle(
                                  fontSize: 8,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black26))
                        else
                          const SizedBox(height: 12),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: barH),
                          duration: Duration(milliseconds: 600 + i * 80),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => Container(
                            height: v,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: cal > 0
                                  ? [
                                      BoxShadow(
                                        color: barColor.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _shortLabel(weekDays[i]),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isToday
                                ? AppColors.dynamicMint
                                : isDark
                                    ? Colors.white38
                                    : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            // Target line label
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                    width: 20,
                    height: 2,
                    color: AppColors.dynamicMint.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text('Daily target',
                    style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38)),
                const SizedBox(width: 16),
                Container(
                    width: 20,
                    height: 2,
                    color: AppColors.warning.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text('Over target',
                    style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly AI Insight Card ────────────────────────────────────────────────────

class _WeeklyInsightCard extends StatelessWidget {
  final dynamic insight;
  final bool isDark;

  const _WeeklyInsightCard({required this.insight, required this.isDark});

  Color get _gradeColor {
    switch (insight.weekGrade) {
      case 'A': return AppColors.dynamicMint;
      case 'B': return const Color(0xFF4CAF50);
      case 'C': return AppColors.warning;
      case 'D': return const Color(0xFFFF7043);
      default:  return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: _gradeColor.withValues(alpha: isDark ? 0.25 : 0.2)),
          boxShadow: [
            BoxShadow(
              color: _gradeColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _gradeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(insight.weekGrade,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _gradeColor,
                          )),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WEEKLY GRADE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: _gradeColor.withValues(alpha: 0.8),
                            )),
                        const SizedBox(height: 2),
                        Text(insight.headline,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Row(
                children: [
                  _StatBadge(
                    label: 'Avg Calories',
                    value: '${insight.avgCalories.round()}',
                    unit: 'kcal',
                    color: AppColors.dynamicMint,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _StatBadge(
                    label: 'Avg Protein',
                    value: '${insight.avgProtein.round()}g',
                    unit: 'protein',
                    color: AppColors.danger,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _StatBadge(
                    label: 'Consistency',
                    value: '${insight.consistencyScore}%',
                    unit: 'logged',
                    color: AppColors.softIndigo,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // Key insight
            if (insight.keyInsight.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.dynamicMint.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(PhosphorIconsFill.lightbulb,
                          color: AppColors.dynamicMint, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          insight.keyInsight,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Achievements
            if (insight.achievements.isNotEmpty) ...[
              _SectionHeader(label: 'ACHIEVEMENTS', color: AppColors.dynamicMint),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Column(
                  children: (insight.achievements as List<dynamic>)
                      .take(3)
                      .map<Widget>((a) => _ListItem(
                            text: a.toString(),
                            icon: PhosphorIconsFill.star,
                            color: AppColors.dynamicMint,
                            isDark: isDark,
                          ))
                      .toList(),
                ),
              ),
            ],

            // Improvements
            if (insight.improvements.isNotEmpty) ...[
              _SectionHeader(label: 'IMPROVEMENTS', color: AppColors.warning),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Column(
                  children: (insight.improvements as List<dynamic>)
                      .take(3)
                      .map<Widget>((a) => _ListItem(
                            text: a.toString(),
                            icon: PhosphorIconsFill.arrowUp,
                            color: AppColors.warning,
                            isDark: isDark,
                          ))
                      .toList(),
                ),
              ),
            ],

            // Next week focus
            if (insight.nextWeekFocus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softIndigo.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.softIndigo.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEXT WEEK\'S FOCUS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.softIndigo.withValues(alpha: 0.8),
                          )),
                      const SizedBox(height: 6),
                      Text(
                        insight.nextWeekFocus,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Text(label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: color.withValues(alpha: 0.8),
          )),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _ListItem({
    required this.text,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 11, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isDark;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(unit,
                style: TextStyle(
                    fontSize: 9,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Macro Averages Card ───────────────────────────────────────────────────────

class _MacroAveragesCard extends ConsumerWidget {
  final List<DateTime> weekDays;
  final dynamic targets;
  final bool isDark;

  const _MacroAveragesCard({
    required this.weekDays,
    required this.targets,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int totalProtein = 0, totalCarbs = 0, totalFat = 0, loggedDays = 0;

    for (final day in weekDays) {
      final meals = ref.watch(mealsForDateProvider(day));
      if (meals.isNotEmpty) {
        loggedDays++;
        totalProtein += meals.fold(0, (s, m) => s + m.proteinGrams);
        totalCarbs += meals.fold(0, (s, m) => s + m.carbsGrams);
        totalFat += meals.fold(0, (s, m) => s + m.fatGrams);
      }
    }

    final days = loggedDays > 0 ? loggedDays : 1;
    final avgProtein = totalProtein ~/ days;
    final avgCarbs = totalCarbs ~/ days;
    final avgFat = totalFat ~/ days;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('AVG DAILY MACROS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.softIndigo.withValues(alpha: 0.8),
                    )),
                const Spacer(),
                Text('Based on $loggedDays days logged',
                    style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
            const SizedBox(height: 16),
            _MacroRow(
              label: 'Protein',
              avg: avgProtein,
              goal: targets.proteinG,
              color: AppColors.danger,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _MacroRow(
              label: 'Carbs',
              avg: avgCarbs,
              goal: targets.carbsG,
              color: AppColors.warning,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _MacroRow(
              label: 'Fat',
              avg: avgFat,
              goal: targets.fatG,
              color: AppColors.softIndigo,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final int avg;
  final int goal;
  final Color color;
  final bool isDark;

  const _MacroRow({
    required this.label,
    required this.avg,
    required this.goal,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (avg / goal).clamp(0.0, 1.0) : 0.0;
    final over = avg > goal;

    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54)),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: over ? AppColors.warning : color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: (over ? AppColors.warning : color)
                              .withValues(alpha: 0.3),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text('${avg}g / ${goal}g',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: over ? AppColors.warning : color)),
        ),
      ],
    );
  }
}

// ── Loading / No-data states ──────────────────────────────────────────────────

class _ReportLoadingCard extends StatelessWidget {
  final bool isDark;
  const _ReportLoadingCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.2 : 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dynamicMint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColors.dynamicMint),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Generating weekly report...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    )),
                const SizedBox(height: 2),
                Text('AI is analysing your nutrition',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDataCard extends StatelessWidget {
  final bool isDark;
  const _NoDataCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dynamicMint.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsFill.chartBar,
                  color: AppColors.dynamicMint, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Not enough data yet',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                )),
            const SizedBox(height: 8),
            Text(
              'Log meals for a few days this week to unlock your AI-powered weekly nutrition report.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
