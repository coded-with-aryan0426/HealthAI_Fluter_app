import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/daily_log_doc.dart';
import '../../../database/models/workout_doc.dart';
import '../../habits/application/habit_provider.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class WeeklyReportData {
  final DateTime weekStart;
  final DateTime weekEnd;

  // Aggregated stats
  final int workoutsCompleted;
  final int workoutsPlanned;
  final double avgCalories;
  final double avgProtein;
  final double avgSleep;
  final double habitCompletion; // 0.0 – 1.0
  final int avgSteps;

  // AI narrative
  final String summary;
  final String nextWeekFocus;
  final List<String> highlights; // ✅ items
  final List<String> warnings;  // ⚠️ items

  const WeeklyReportData({
    required this.weekStart,
    required this.weekEnd,
    required this.workoutsCompleted,
    required this.workoutsPlanned,
    required this.avgCalories,
    required this.avgProtein,
    required this.avgSleep,
    required this.habitCompletion,
    required this.avgSteps,
    required this.summary,
    required this.nextWeekFocus,
    required this.highlights,
    required this.warnings,
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Generates a weekly AI report card on demand.
/// Returns `null` while generating.
final weeklyReportProvider =
    AsyncNotifierProvider<WeeklyReportNotifier, WeeklyReportData?>(
        WeeklyReportNotifier.new);

class WeeklyReportNotifier extends AsyncNotifier<WeeklyReportData?> {
  @override
  Future<WeeklyReportData?> build() async => null;

  Future<WeeklyReportData> generate() async {
    state = const AsyncLoading();

    final isar = ref.read(isarProvider);
    final habits = ref.read(habitsProvider);
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - 6);
    final weekEnd = DateTime(now.year, now.month, now.day);

    // ── Gather last 7 days of daily logs ────────────────────────────────────
    final logs = isar.dailyLogDocs
        .where()
        .filter()
        .dateGreaterThan(weekStart.subtract(const Duration(hours: 1)))
        .findAllSync();

    final int daysWithData = logs.isEmpty ? 1 : logs.length;

    final double avgCal = logs.isEmpty
        ? 0
        : logs.map((l) => l.caloriesConsumed).reduce((a, b) => a + b) /
            daysWithData;
    final double avgProt = logs.isEmpty
        ? 0
        : logs.map((l) => l.proteinGrams).reduce((a, b) => a + b) /
            daysWithData;
    final double avgSleep = logs.isEmpty
        ? 0
        : logs.map((l) => l.sleepMinutes).reduce((a, b) => a + b) /
            daysWithData /
            60.0;
    final int avgSteps = logs.isEmpty
        ? 0
        : (logs.map((l) => l.stepCount).reduce((a, b) => a + b) ~/
            daysWithData);

    // ── Workouts ─────────────────────────────────────────────────────────────
    final workouts = isar.workoutDocs
        .where()
        .filter()
        .dateGreaterThan(weekStart.subtract(const Duration(hours: 1)))
        .findAllSync();
    final int workoutsCompleted = workouts.length;

    // ── Habit completion ──────────────────────────────────────────────────────
    double habitCompletion = 0;
    if (habits.isNotEmpty) {
      int totalPossible = 0;
      int totalDone = 0;
      for (final habit in habits) {
        for (int i = 0; i < 7; i++) {
          final day = weekStart.add(Duration(days: i));
          totalPossible++;
          if (habit.completedDates.any((d) =>
              d.year == day.year && d.month == day.month && d.day == day.day)) {
            totalDone++;
          }
        }
      }
      habitCompletion = totalPossible > 0 ? totalDone / totalPossible : 0;
    }

    // ── Ask AI for narrative ──────────────────────────────────────────────────
    final aiService = ref.read(aiServiceProvider);
    final prompt = '''
Generate a weekly health report card in JSON format. Be concise and motivating.

User stats this week:
- Workouts completed: $workoutsCompleted
- Avg daily calories: ${avgCal.round()} kcal
- Avg daily protein: ${avgProt.round()}g
- Avg sleep: ${avgSleep.toStringAsFixed(1)}h/night
- Habit completion: ${(habitCompletion * 100).round()}%
- Avg steps/day: $avgSteps

Return ONLY valid JSON (no markdown, no explanation):
{
  "summary": "2-3 sentence encouraging summary of the week",
  "next_week_focus": "1 specific actionable focus for next week",
  "highlights": ["highlight 1", "highlight 2"],
  "warnings": ["warning 1"]
}

Rules:
- highlights: things the user did well (max 3)
- warnings: things to improve (max 2, be gentle)
- next_week_focus: one concrete action
- Keep tone positive and motivating
''';

    String summary = 'Great week overall! Keep up the momentum.';
    String nextWeekFocus = 'Stay consistent with your daily habits.';
    List<String> highlights = [];
    List<String> warnings = [];

    try {
      final buffer = StringBuffer();
      await for (final delta in aiService.streamMessage(prompt)) {
        if (delta.startsWith('__') ) break;
        buffer.write(delta);
      }
      final raw = buffer.toString().trim();
      // Strip markdown code fences if present
      final clean = raw
          .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
          .trim();
      final json = jsonDecode(clean) as Map<String, dynamic>;
      summary = json['summary'] as String? ?? summary;
      nextWeekFocus = json['next_week_focus'] as String? ?? nextWeekFocus;
      highlights = (json['highlights'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      warnings = (json['warnings'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    } catch (_) {
      // AI failed — use computed fallbacks
      if (workoutsCompleted >= 3) highlights.add('Completed $workoutsCompleted workouts this week');
      if (avgSleep >= 7) highlights.add('Averaged ${avgSleep.toStringAsFixed(1)}h sleep — excellent recovery');
      if (habitCompletion >= 0.7) {
        highlights.add('${(habitCompletion * 100).round()}% habit completion — great consistency');
      }
      if (avgCal < 1200 && avgCal > 0) warnings.add('Calorie intake was low — aim to hit your daily goal');
      if (workoutsCompleted < 2) warnings.add('Only $workoutsCompleted workouts — aim for 3+ next week');
    }

    final report = WeeklyReportData(
      weekStart: weekStart,
      weekEnd: weekEnd,
      workoutsCompleted: workoutsCompleted,
      workoutsPlanned: 4, // Default plan target
      avgCalories: avgCal,
      avgProtein: avgProt,
      avgSleep: avgSleep,
      habitCompletion: habitCompletion,
      avgSteps: avgSteps,
      summary: summary,
      nextWeekFocus: nextWeekFocus,
      highlights: highlights,
      warnings: warnings,
    );

    state = AsyncData(report);
    return report;
  }
}
