import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/daily_log_doc.dart';
import '../../../database/models/workout_doc.dart';

class WeeklyStats {
  final List<DailyLogDoc> days; // 7 entries, oldest → newest
  final List<WorkoutDoc> workouts; // all workouts in last 7 days
  final int totalWorkouts;
  final int totalExerciseMinutes;
  final int totalCaloriesBurned;
  final int totalProteinGrams;
  final int avgSleepMinutes;
  final int avgSteps;
  final String? topWorkoutTitle;

  // Macro averages for the 7-day window
  final int avgCaloriesConsumed;
  final int avgProteinGrams;
  final int avgWaterMl;

  const WeeklyStats({
    required this.days,
    required this.workouts,
    required this.totalWorkouts,
    required this.totalExerciseMinutes,
    required this.totalCaloriesBurned,
    required this.totalProteinGrams,
    required this.avgSleepMinutes,
    required this.avgSteps,
    this.topWorkoutTitle,
    this.avgCaloriesConsumed = 0,
    this.avgProteinGrams = 0,
    this.avgWaterMl = 0,
  });
}

final weeklyStatsProvider = Provider<WeeklyStats>((ref) {
  final isar = ref.read(isarProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Build list of the last 7 days (oldest → newest)
  final days = <DailyLogDoc>[];
  for (int i = 6; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    final doc = isar.dailyLogDocs.where().dateEqualTo(date).findFirstSync();
    if (doc != null) {
      days.add(doc);
    } else {
      days.add(DailyLogDoc()
        ..date = date
        ..stepCount = 0
        ..sleepMinutes = 0
        ..caloriesBurned = 0
        ..exerciseCompletedMinutes = 0
        ..proteinGrams = 0
        ..caloriesConsumed = 0
        ..waterMl = 0);
    }
  }

  final sevenDaysAgo = today.subtract(const Duration(days: 7));
  final workouts = isar.workoutDocs
      .filter()
      .dateGreaterThan(sevenDaysAgo)
      .findAllSync();

  final totalExMins = days.fold(0, (s, d) => s + d.exerciseCompletedMinutes);
  final totalCalsBurned = days.fold(0, (s, d) => s + d.caloriesBurned);
  final totalProtein = days.fold(0, (s, d) => s + d.proteinGrams);

  final sleepDays = days.where((d) => d.sleepMinutes > 0).toList();
  final avgSleep = sleepDays.isEmpty
      ? 0
      : (sleepDays.fold(0, (s, d) => s + d.sleepMinutes) / sleepDays.length)
          .round();

  final stepDays = days.where((d) => d.stepCount > 0).toList();
  final avgSteps = stepDays.isEmpty
      ? 0
      : (stepDays.fold(0, (s, d) => s + d.stepCount) / stepDays.length)
          .round();

  // Macro averages (average over days that have any data)
  final calDays = days.where((d) => d.caloriesConsumed > 0).toList();
  final avgCals = calDays.isEmpty
      ? 0
      : (calDays.fold(0, (s, d) => s + d.caloriesConsumed) / calDays.length)
          .round();

  final protDays = days.where((d) => d.proteinGrams > 0).toList();
  final avgProt = protDays.isEmpty
      ? 0
      : (protDays.fold(0, (s, d) => s + d.proteinGrams) / protDays.length)
          .round();

  final waterDays = days.where((d) => d.waterMl > 0).toList();
  final avgWater = waterDays.isEmpty
      ? 0
      : (waterDays.fold(0, (s, d) => s + d.waterMl) / waterDays.length)
          .round();

  // Most frequent workout title
  final titleCount = <String, int>{};
  for (final w in workouts) {
    titleCount[w.title] = (titleCount[w.title] ?? 0) + 1;
  }
  final topTitle = titleCount.isEmpty
      ? null
      : (titleCount.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .first
          .key;

  return WeeklyStats(
    days: days,
    workouts: workouts,
    totalWorkouts: workouts.length,
    totalExerciseMinutes: totalExMins,
    totalCaloriesBurned: totalCalsBurned,
    totalProteinGrams: totalProtein,
    avgSleepMinutes: avgSleep,
    avgSteps: avgSteps,
    topWorkoutTitle: topTitle,
    avgCaloriesConsumed: avgCals,
    avgProteinGrams: avgProt,
    avgWaterMl: avgWater,
  );
});
