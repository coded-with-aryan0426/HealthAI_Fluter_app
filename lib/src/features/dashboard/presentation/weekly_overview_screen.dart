import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../application/weekly_stats_provider.dart';
import '../application/weekly_insight_provider.dart';
import '../../../database/models/daily_log_doc.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../../../features/profile/application/user_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Personal-Records provider — computes all-time bests from the 7-day window
// (re-uses WeeklyStats for simplicity; could be extended to all-time later)
// ─────────────────────────────────────────────────────────────────────────────
final _personalRecordsProvider = Provider<List<_PrEntry>>((ref) {
  final stats = ref.watch(weeklyStatsProvider);
  final days = stats.days;

  int maxSteps = 0;
  int maxSleep = 0; // minutes
  int maxCalBurned = 0;
  int maxExercise = 0;
  double maxWeightKg = 0;

  for (final d in days) {
    if (d.stepCount > maxSteps) maxSteps = d.stepCount;
    if (d.sleepMinutes > maxSleep) maxSleep = d.sleepMinutes;
    if (d.caloriesBurned > maxCalBurned) maxCalBurned = d.caloriesBurned;
    if (d.exerciseCompletedMinutes > maxExercise) {
      maxExercise = d.exerciseCompletedMinutes;
    }
  }

  // Heaviest lift from workouts
  for (final w in stats.workouts) {
    for (final ex in w.exercises) {
      for (final s in ex.sets) {
        if (s.weightKg > maxWeightKg) maxWeightKg = s.weightKg;
      }
    }
  }

  return [
    _PrEntry(
      label: 'Best Steps',
      value: '$maxSteps',
      unit: 'steps',
      icon: PhosphorIconsFill.sneaker,
      color: AppColors.dynamicMint,
    ),
    _PrEntry(
      label: 'Best Sleep',
      value: (maxSleep / 60).toStringAsFixed(1),
      unit: 'hrs',
      icon: PhosphorIconsFill.moon,
      color: const Color(0xFF6B7AFF),
    ),
    _PrEntry(
      label: 'Peak Burn',
      value: '$maxCalBurned',
      unit: 'kcal',
      icon: PhosphorIconsFill.fire,
      color: AppColors.warning,
    ),
    _PrEntry(
      label: 'Max Exercise',
      value: '$maxExercise',
      unit: 'min',
      icon: PhosphorIconsFill.barbell,
      color: AppColors.danger,
    ),
    if (maxWeightKg > 0)
      _PrEntry(
        label: 'Heaviest Lift',
          value: maxWeightKg.toStringAsFixed(1),
        unit: 'kg',
        icon: PhosphorIconsFill.barbell,
        color: const Color(0xFFFF6B35),
      ),
  ];
});

class _PrEntry {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  const _PrEntry({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class WeeklyOverviewScreen extends ConsumerWidget {
  const WeeklyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(weeklyStatsProvider);
    final prs = ref.watch(_personalRecordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepObsidian : AppColors.cloudGray,
      body: CustomScrollView(
        physics: scrollPhysics,
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: isDark
                ? AppColors.deepObsidian.withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.88),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: AppAnimatedPressable(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIconsRegular.arrowLeft,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Text(
              'Weekly Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _WeekLabel(),
              ),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // ── Summary Tiles ────────────────────────────────────────────────
              _SummaryTilesRow(stats: stats),

              const SizedBox(height: 28),

              // ── Sparklines ──────────────────────────────────────────────────
              _SectionTitle(title: '7-Day Trends'),
              const SizedBox(height: 16),

              _SparklineCard(
                title: 'STEPS',
                days: stats.days,
                getValue: (d) => d.stepCount.toDouble(),
                color: AppColors.dynamicMint,
                unitLabel: 'steps',
                goal: 10000,
                icon: PhosphorIconsFill.sneaker,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              _SparklineCard(
                title: 'CALORIES BURNED',
                days: stats.days,
                getValue: (d) => d.caloriesBurned.toDouble(),
                color: AppColors.warning,
                unitLabel: 'kcal',
                goal: 500,
                icon: PhosphorIconsFill.fire,
              ).animate().fadeIn(delay: 180.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              _SparklineCard(
                title: 'SLEEP',
                days: stats.days,
                getValue: (d) => d.sleepMinutes / 60,
                color: const Color(0xFF6B7AFF),
                unitLabel: 'hrs',
                goal: 8,
                icon: PhosphorIconsFill.moon,
              ).animate().fadeIn(delay: 260.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              _SparklineCard(
                title: 'EXERCISE',
                days: stats.days,
                getValue: (d) => d.exerciseCompletedMinutes.toDouble(),
                color: AppColors.danger,
                unitLabel: 'min',
                goal: 45,
                icon: PhosphorIconsFill.barbell,
              ).animate().fadeIn(delay: 340.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 28),

              // ── Personal Records ─────────────────────────────────────────────
              _SectionTitle(title: 'This Week\'s Best'),
              const SizedBox(height: 16),

              _PrGrid(prs: prs)
                  .animate().fadeIn(delay: 420.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 28),

              // ── Macro Averages ───────────────────────────────────────────────
              _SectionTitle(title: 'Macro Averages'),
              const SizedBox(height: 16),

              _MacroAveragesCard(
                stats: stats,
                calorieGoal: user.calorieGoal,
                proteinGoalG: user.proteinGoalG,
                waterGoalMl: user.waterGoalMl,
                isDark: isDark,
              )
                  .animate().fadeIn(delay: 480.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 28),

              // ── AI Weekly Summary ────────────────────────────────────────────
              _SectionTitle(title: 'AI Coach Summary'),
              const SizedBox(height: 16),

              _AiWeeklySummaryCard()
                  .animate().fadeIn(delay: 560.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Week Label (e.g. "Feb 21 – Feb 27")
// ─────────────────────────────────────────────────────────────────────────────
class _WeekLabel extends StatelessWidget {
  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final label =
        '${_months[start.month]} ${start.day} – ${_months[now.month]} ${now.day}';
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Title
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: -0.4,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Tiles Row (totals for the week)
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryTilesRow extends StatelessWidget {
  final WeeklyStats stats;
  const _SummaryTilesRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: scrollPhysics,
        children: [
          _SummaryChip(
            label: 'Workouts',
            value: '${stats.totalWorkouts}',
            unit: 'sessions',
            color: AppColors.danger,
            icon: PhosphorIconsFill.barbell,
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            label: 'Exercise',
            value: '${stats.totalExerciseMinutes}',
            unit: 'min total',
            color: AppColors.dynamicMint,
            icon: PhosphorIconsFill.personSimpleRun,
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            label: 'Avg Steps',
            value: '${stats.avgSteps}',
            unit: '/ day',
            color: const Color(0xFF6B7AFF),
            icon: PhosphorIconsFill.sneaker,
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            label: 'Avg Sleep',
            value: (stats.avgSleepMinutes / 60).toStringAsFixed(1),
            unit: 'hrs / night',
            color: AppColors.warning,
            icon: PhosphorIconsFill.moon,
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            label: 'Cal Burned',
            value: '${stats.totalCaloriesBurned}',
            unit: 'kcal total',
            color: const Color(0xFFFF6B35),
            icon: PhosphorIconsFill.fire,
          ),
        ]
            .animate(interval: 60.ms)
            .fadeIn(duration: 350.ms)
            .slideX(begin: 0.1, end: 0, duration: 350.ms, curve: Curves.easeOutCubic),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: color.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkline Card
// ─────────────────────────────────────────────────────────────────────────────
class _SparklineCard extends StatelessWidget {
  final String title;
  final List<DailyLogDoc> days;
  final double Function(DailyLogDoc) getValue;
  final Color color;
  final String unitLabel;
  final double goal;
  final IconData icon;

  const _SparklineCard({
    required this.title,
    required this.days,
    required this.getValue,
    required this.color,
    required this.unitLabel,
    required this.goal,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final values = days.map(getValue).toList();
    final maxVal = values.reduce(math.max).clamp(goal, double.infinity);
    final avg = values.isEmpty
        ? 0.0
        : values.fold(0.0, (s, v) => s + v) / values.length;
    final latest = values.isNotEmpty ? values.last : 0.0;

    // Day labels: Mon, Tue … today
    final dayLabels = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return names[d.weekday % 7];
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: color.withValues(alpha: 0.85),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: unitLabel == 'hrs'
                              ? latest.toStringAsFixed(1)
                              : latest.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: ' $unitLabel',
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                    Text(
                      'today',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sparkline chart
            SizedBox(
              height: 72,
              child: _SparklinePainterWidget(
                values: values,
                maxVal: maxVal,
                color: color,
                goal: goal,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 8),

            // Day labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dayLabels
                  .asMap()
                  .entries
                  .map((e) => Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: e.key == 6
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: e.key == 6
                              ? color
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 14),

            // Avg vs Goal row
            Row(
              children: [
                _StatPill(
                  label: 'Avg',
                  value: unitLabel == 'hrs'
                      ? avg.toStringAsFixed(1)
                      : avg.toStringAsFixed(0),
                  unit: unitLabel,
                  color: color,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _StatPill(
                  label: 'Goal',
                  value: unitLabel == 'hrs'
                      ? goal.toStringAsFixed(0)
                      : goal.toStringAsFixed(0),
                  unit: unitLabel,
                  color: color.withValues(alpha: 0.5),
                  isDark: isDark,
                ),
                const Spacer(),
                // Goal achieved badge
                if (avg >= goal)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIconsFill.checkCircle,
                            color: color, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Goal Met',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
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

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isDark;

  const _StatPill({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkline Painter Widget
// ─────────────────────────────────────────────────────────────────────────────
class _SparklinePainterWidget extends StatefulWidget {
  final List<double> values;
  final double maxVal;
  final Color color;
  final double goal;
  final bool isDark;

  const _SparklinePainterWidget({
    required this.values,
    required this.maxVal,
    required this.color,
    required this.goal,
    required this.isDark,
  });

  @override
  State<_SparklinePainterWidget> createState() =>
      _SparklinePainterWidgetState();
}

class _SparklinePainterWidgetState extends State<_SparklinePainterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(
          values: widget.values,
          maxVal: widget.maxVal,
          color: widget.color,
          goal: widget.goal,
          isDark: widget.isDark,
          progress: _progress.value,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final double maxVal;
  final Color color;
  final double goal;
  final bool isDark;
  final double progress;

  const _SparklinePainter({
    required this.values,
    required this.maxVal,
    required this.color,
    required this.goal,
    required this.isDark,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final w = size.width;
    final h = size.height;
    final count = values.length;

    // ── Bar chart ────────────────────────────────────────────────────────────
    final barW = (w - 16) / count - 6;
    for (int i = 0; i < count; i++) {
      final fraction =
          (maxVal > 0 ? (values[i] / maxVal) : 0.0).clamp(0.0, 1.0);
      final animFraction = fraction * progress;
      final x = 8 + i * ((w - 16) / count);
      final barH = animFraction * h * 0.75;
      final top = h - barH;

      final isAboveGoal = values[i] >= goal;
      final barColor = isAboveGoal ? color : color.withValues(alpha: 0.25);

      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, barH),
        const Radius.circular(4),
      );

      canvas.drawRRect(
        rRect,
        Paint()..color = barColor,
      );

      // Glow on the tallest bar (today = last)
      if (i == count - 1) {
        canvas.drawRRect(
          rRect,
          Paint()
            ..color = color.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
    }

    // ── Goal line ────────────────────────────────────────────────────────────
    final goalFraction = (maxVal > 0 ? (goal / maxVal) : 0.0).clamp(0.0, 1.0);
    final goalY = h - goalFraction * h * 0.75;

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashW = 6.0;
    const gapW = 4.0;
    double dx = 0;
    while (dx < w * progress) {
      final end = math.min(dx + dashW, w * progress);
      canvas.drawLine(Offset(dx, goalY), Offset(end, goalY), dashPaint);
      dx += dashW + gapW;
    }

    // ── Sparkline curve ──────────────────────────────────────────────────────
    if (count < 2) return;

    final pts = <Offset>[];
    for (int i = 0; i < count; i++) {
      final fraction =
          (maxVal > 0 ? (values[i] / maxVal) : 0.0).clamp(0.0, 1.0);
      final x = 8 + i * ((w - 16) / count) + barW / 2;
      final y = h - fraction * h * 0.75;
      pts.add(Offset(x, y));
    }

    // Clip to progress
    final clipW = w * progress;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, clipW, h));

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      final cpx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(path, linePaint);

    // Dot on last point
    canvas.drawCircle(
      pts.last,
      4,
      Paint()..color = color,
    );
    canvas.drawCircle(
      pts.last,
      2.5,
      Paint()..color = Colors.white,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress || old.values != values;
}

// ─────────────────────────────────────────────────────────────────────────────
// Personal Records Grid
// ─────────────────────────────────────────────────────────────────────────────
class _PrGrid extends StatelessWidget {
  final List<_PrEntry> prs;
  const _PrGrid({required this.prs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: prs.length,
        itemBuilder: (context, i) => _PrTile(entry: prs[i])
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn(duration: 350.ms)
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1, 1),
              duration: 350.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}

class _PrTile extends StatelessWidget {
  final _PrEntry entry;
  const _PrTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = entry.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.18 : 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(entry.icon, color: color, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entry.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: color.withValues(alpha: 0.75),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  entry.unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Weekly Summary Card
// ─────────────────────────────────────────────────────────────────────────────
class _AiWeeklySummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(weeklyInsightProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: asyncSummary.when(
        loading: () => _Shimmer(isDark: isDark),
        error: (_, __) => const SizedBox.shrink(),
        data: (text) => _SummaryCard(text: text, isDark: isDark, ref: ref),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String text;
  final bool isDark;
  final WidgetRef ref;
  const _SummaryCard({required this.text, required this.isDark, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1B2E), const Color(0xFF13151F)]
              : [const Color(0xFFF0F0FF), const Color(0xFFE8EAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.softIndigo.withValues(alpha: isDark ? 0.25 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softIndigo.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.softIndigo, AppColors.dynamicMint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softIndigo.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 18),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(
                      duration: 2200.ms,
                      color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY COACH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: AppColors.softIndigo.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'Powered by AI',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppAnimatedPressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(weeklyInsightProvider.notifier).refresh();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.softIndigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.arrowsClockwise,
                    size: 14,
                    color: AppColors.softIndigo.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.softIndigo.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.65,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final bool isDark;
  const _Shimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1B2E) : const Color(0xFFF0F0FF),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.softIndigo.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.softIndigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 8,
                      width: 100,
                      decoration: BoxDecoration(
                          color: AppColors.softIndigo.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 6),
                  Container(
                      height: 8,
                      width: 70,
                      decoration: BoxDecoration(
                          color: AppColors.softIndigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4))),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
              height: 8,
              decoration: BoxDecoration(
                  color: AppColors.softIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Container(
              height: 8,
              width: 240,
              decoration: BoxDecoration(
                  color: AppColors.softIndigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
          duration: 1200.ms, color: AppColors.softIndigo.withValues(alpha: 0.05));
    }
  }

// ─────────────────────────────────────────────────────────────────────────────
// Macro Averages Card
// ─────────────────────────────────────────────────────────────────────────────
class _MacroAveragesCard extends StatefulWidget {
  final WeeklyStats stats;
  final int calorieGoal;
  final int proteinGoalG;
  final int waterGoalMl;
  final bool isDark;

  const _MacroAveragesCard({
    required this.stats,
    required this.calorieGoal,
    required this.proteinGoalG,
    required this.waterGoalMl,
    required this.isDark,
  });

  @override
  State<_MacroAveragesCard> createState() => _MacroAveragesCardState();
}

class _MacroAveragesCardState extends State<_MacroAveragesCard>
    with SingleTickerProviderStateMixin {
  // Which macro is expanded to show the 7-day mini bar
  int? _expandedIndex;
  late AnimationController _barCtrl;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    final macros = [
      _MacroRow(
        label: 'Calories',
        avg: widget.stats.avgCaloriesConsumed,
        goal: widget.calorieGoal,
        unit: 'kcal',
        color: AppColors.warning,
        icon: PhosphorIconsFill.flame,
        days: widget.stats.days.map((d) => d.caloriesConsumed.toDouble()).toList(),
      ),
      _MacroRow(
        label: 'Protein',
        avg: widget.stats.avgProteinGrams,
        goal: widget.proteinGoalG,
        unit: 'g',
        color: AppColors.danger,
        icon: PhosphorIconsFill.egg,
        days: widget.stats.days.map((d) => d.proteinGrams.toDouble()).toList(),
      ),
      _MacroRow(
        label: 'Water',
        avg: (widget.stats.avgWaterMl / 1000.0 * 10).round(),
        goal: (widget.waterGoalMl / 1000.0 * 10).round(),
        unit: 'L',
        color: const Color(0xFF3B9EFF),
        icon: PhosphorIconsFill.dropHalf,
        days: widget.stats.days.map((d) => d.waterMl / 100.0).toList(),
        isDecimal: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.15 : 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dynamicMint.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
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
                    color: AppColors.dynamicMint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(PhosphorIconsFill.chartPie,
                      color: AppColors.dynamicMint, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'MACRO AVERAGES (7-DAY)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.dynamicMint.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...macros.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              final pct = m.goal > 0
                  ? (m.avg / m.goal).clamp(0.0, 1.0)
                  : 0.0;
              final isExpanded = _expandedIndex == i;

              return AppAnimatedPressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _expandedIndex = isExpanded ? null : i;
                    if (!isExpanded) {
                      _barCtrl.forward(from: 0);
                    }
                  });
                },
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (i > 0)
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          color: (isDark
                                  ? Colors.white
                                  : Colors.black)
                              .withValues(alpha: 0.06),
                        ),
                      // Label row
                      Row(
                        children: [
                          Icon(m.icon, color: m.color, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            m.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: m.isDecimal
                                    ? (m.avg / 10.0).toStringAsFixed(1)
                                    : '${m.avg}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              TextSpan(
                                text: ' / ${m.isDecimal ? (m.goal / 10.0).toStringAsFixed(1) : m.goal} ${m.unit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: m.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: m.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(pct * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: m.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Animated progress bar
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: m.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: v,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: m.color,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: m.color.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Expanded: 7-day mini bar chart
                      if (isExpanded) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 52,
                          child: AnimatedBuilder(
                            animation: _barCtrl,
                            builder: (_, __) => _MiniDayBars(
                              values: m.days,
                              color: m.color,
                              goal: m.goal.toDouble(),
                              isDark: isDark,
                              progress: _barCtrl.value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (d) {
                            final day = DateTime.now()
                                .subtract(Duration(days: 6 - d));
                            const names = [
                              'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
                            ];
                            return Text(
                              names[day.weekday % 7],
                              style: TextStyle(
                                fontSize: 8,
                                color: d == 6
                                    ? m.color
                                    : (isDark
                                        ? Colors.white30
                                        : Colors.black38),
                                fontWeight: d == 6
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MacroRow {
  final String label;
  final int avg;
  final int goal;
  final String unit;
  final Color color;
  final IconData icon;
  final List<double> days;
  final bool isDecimal;

  const _MacroRow({
    required this.label,
    required this.avg,
    required this.goal,
    required this.unit,
    required this.color,
    required this.icon,
    required this.days,
    this.isDecimal = false,
  });
}

class _MiniDayBars extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double goal;
  final bool isDark;
  final double progress;

  const _MiniDayBars({
    required this.values,
    required this.color,
    required this.goal,
    required this.isDark,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _MiniBarPainter(
        values: values,
        color: color,
        goal: goal,
        progress: progress,
      ),
    );
  }
}

class _MiniBarPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double goal;
  final double progress;

  const _MiniBarPainter({
    required this.values,
    required this.color,
    required this.goal,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final count = values.length;
    final maxV = math.max(
        values.reduce(math.max).clamp(1.0, double.infinity),
        goal > 0 ? goal : 1.0);
    final barW = (size.width / count) * 0.6;
    final gap = (size.width / count) * 0.4;

    for (int i = 0; i < count; i++) {
      final frac = (values[i] / maxV).clamp(0.0, 1.0) * progress;
      final barH = math.max(frac * size.height, frac > 0 ? 3.0 : 0.0);
      final x = i * (barW + gap) + gap / 2;
      final y = size.height - barH;

      final isGoalMet = values[i] >= goal;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, barH),
          const Radius.circular(3),
        ),
        Paint()
          ..color = isGoalMet ? color : color.withValues(alpha: 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(_MiniBarPainter old) =>
      old.progress != progress || old.values != values;
}

