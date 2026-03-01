import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/workout_doc.dart';
import '../../../database/models/exercise_pr_doc.dart';

// ── Data classes ──────────────────────────────────────────────────────────────

class ExerciseHistory {
  final String exerciseName;
  final List<ExerciseDataPoint> points; // newest last
  const ExerciseHistory({required this.exerciseName, required this.points});
}

class ExerciseDataPoint {
  final DateTime date;
  final double bestWeightKg;
  final double estimated1RM; // Epley
  final int totalVolume;     // weight × reps for best set
  const ExerciseDataPoint({
    required this.date,
    required this.bestWeightKg,
    required this.estimated1RM,
    required this.totalVolume,
  });
}

class WeeklyVolumeBar {
  final DateTime weekStart;
  final int volumeKg;
  const WeeklyVolumeBar({required this.weekStart, required this.volumeKg});
}

class StrengthChartData {
  /// Names of all exercises ever logged.
  final List<String> exerciseNames;

  /// Weight-over-time data for the selected exercise.
  final ExerciseHistory selectedHistory;

  /// Weekly total volume (last 12 weeks).
  final List<WeeklyVolumeBar> weeklyVolume;

  /// All-time PRs per exercise.
  final List<ExercisePRDoc> prs;

  const StrengthChartData({
    required this.exerciseNames,
    required this.selectedHistory,
    required this.weeklyVolume,
    required this.prs,
  });
}

// ── Provider family (keyed by selected exercise name) ─────────────────────────

final strengthChartDataProvider =
    Provider.family<StrengthChartData, String>((ref, exerciseName) {
  final isar = ref.watch(isarProvider);

  // All workout docs, newest first
  final allDocs = isar.workoutDocs
      .where()
      .idGreaterThan(0)
      .findAllSync()
    ..sort((a, b) => a.date.compareTo(b.date));

  // Collect all exercise names (distinct)
  final nameSet = <String>{};
  for (final doc in allDocs) {
    for (final ex in doc.exercises) {
      if (ex.name.isNotEmpty) nameSet.add(ex.name);
    }
  }
  final exerciseNames = nameSet.toList()..sort();

  // Weight-over-time for selected exercise
  final pointMap = <String, ExerciseDataPoint>{}; // date string → point
  for (final doc in allDocs) {
    for (final ex in doc.exercises) {
      if (ex.name.toLowerCase() != exerciseName.toLowerCase()) continue;
      double best = 0;
      int bestReps = 0;
      for (final s in ex.sets) {
        if (s.completed && s.weightKg > best) {
          best = s.weightKg;
          bestReps = s.reps;
        }
      }
      if (best <= 0) continue;
      final epley = bestReps <= 1 ? best : best * (1 + bestReps / 30.0);
      final key = _dateKey(doc.date);
      final existing = pointMap[key];
      if (existing == null || best > existing.bestWeightKg) {
        pointMap[key] = ExerciseDataPoint(
          date: DateTime(doc.date.year, doc.date.month, doc.date.day),
          bestWeightKg: best,
          estimated1RM: double.parse(epley.toStringAsFixed(1)),
          totalVolume: (best * bestReps).round(),
        );
      }
    }
  }
  final points = pointMap.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  // Weekly volume (last 12 weeks)
  final now = DateTime.now();
  final weeklyBars = <WeeklyVolumeBar>[];
  for (int w = 11; w >= 0; w--) {
    final weekStart = now.subtract(Duration(days: now.weekday - 1 + w * 7));
    final weekStartClean =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEnd = weekStartClean.add(const Duration(days: 7));
    int vol = 0;
    for (final doc in allDocs) {
      if (doc.date.isAfter(weekStartClean) && doc.date.isBefore(weekEnd)) {
        vol += doc.totalVolumeKg;
      }
    }
    weeklyBars.add(
        WeeklyVolumeBar(weekStart: weekStartClean, volumeKg: vol));
  }

  // All PRs
  final prs = isar.exercisePRDocs
      .where()
      .idGreaterThan(0)
      .findAllSync()
    ..sort((a, b) => b.estimated1RMKg.compareTo(a.estimated1RMKg));

  return StrengthChartData(
    exerciseNames: exerciseNames,
    selectedHistory: ExerciseHistory(
        exerciseName: exerciseName, points: points),
    weeklyVolume: weeklyBars,
    prs: prs,
  );
});

// Provider that tracks the currently selected exercise name
final selectedExerciseProvider = StateProvider<String>((ref) => '');

String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
