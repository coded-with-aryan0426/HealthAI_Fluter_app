import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/workout_doc.dart';
import '../../../database/models/exercise_pr_doc.dart';
import '../../dashboard/application/daily_activity_provider.dart';

// Provides the active workout session state
final activeWorkoutProvider = NotifierProvider<WorkoutController, WorkoutDoc?>(WorkoutController.new);

// Tracks elapsed seconds for the active workout (updated every second)
final activeWorkoutElapsedProvider = StateProvider<int>((ref) => 0);

class WorkoutController extends Notifier<WorkoutDoc?> {
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  @override
  WorkoutDoc? build() {
    ref.onDispose(() {
      _elapsedTimer?.cancel();
    });
    return null;
  }

  void _startElapsedClock() {
    _elapsedTimer?.cancel();
    _elapsedSeconds = 0;
    ref.read(activeWorkoutElapsedProvider.notifier).state = 0;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      ref.read(activeWorkoutElapsedProvider.notifier).state = _elapsedSeconds;
    });
  }

  /// Called when the plan-based player starts a session
  void startPlanWorkout(String title) {
    state = WorkoutDoc()
      ..date = DateTime.now()
      ..title = title
      ..durationSeconds = 0
      ..exercises = [];
    _startElapsedClock();
  }

  void startWorkout(String exerciseName) {
    state = WorkoutDoc()
      ..date = DateTime.now()
      ..title = exerciseName
      ..durationSeconds = 0
      ..exercises = [
        WorkoutExercise()
          ..name = exerciseName
          ..sets = [
            WorkoutSetDoc()..weightKg = 15.0..reps = 12..completed = true,
            WorkoutSetDoc()..weightKg = 17.5..reps = 10..completed = true,
            WorkoutSetDoc(),
          ]
      ];
    _startElapsedClock();
  }

  void completeSet(int exerciseIndex, int setIndex, double? weight, int? reps) {
    if (state == null) return;
    final currentState = state!;
    
    // Copy the nested lists to maintain immutability for UI (Riverpod expects new references)
    final updatedExercises = List<WorkoutExercise>.from(currentState.exercises);
    final targetExercise = updatedExercises[exerciseIndex];
    final updatedSets = List<WorkoutSetDoc>.from(targetExercise.sets);
    
    // Update the specific set
    updatedSets[setIndex] = WorkoutSetDoc()
      ..weightKg = weight ?? updatedSets[setIndex].weightKg
      ..reps = reps ?? updatedSets[setIndex].reps
      ..completed = true;

    targetExercise.sets = updatedSets;
    updatedExercises[exerciseIndex] = targetExercise;

    // Create a new session object to trigger Riverpod
    state = WorkoutDoc()
      ..date = currentState.date
      ..title = currentState.title
      ..durationSeconds = currentState.durationSeconds
      ..exercises = updatedExercises;
  }

  void endWorkout({required int actualDurationSeconds}) {
    if (state == null) return;

    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    ref.read(activeWorkoutElapsedProvider.notifier).state = 0;

    final db = ref.read(isarProvider);
    final dailyNotifier = ref.read(dailyActivityProvider.notifier);

    // Compute total volume (sum weight × reps for completed sets)
    int totalVolume = 0;
    for (final ex in state!.exercises) {
      for (final s in ex.sets) {
        if (s.completed) totalVolume += (s.weightKg * s.reps).round();
      }
    }

    // Persist actual duration + volume on the workout doc
    final finished = state!
      ..durationSeconds = actualDurationSeconds
      ..totalVolumeKg = totalVolume;

    db.writeTxnSync(() => db.workoutDocs.putSync(finished));

    // Update PRs per exercise
    _updatePRs(db, state!.exercises);

    // Calculate real exercise minutes + estimated calories burned
    final exerciseMinutes = (actualDurationSeconds / 60).round().clamp(1, 9999);
    // ~5 kcal/min is a reasonable moderate-intensity estimate
    final estimatedKcal = (exerciseMinutes * 5).clamp(0, 9999);

      dailyNotifier.addExercise(minutes: exerciseMinutes, caloriesBurned: estimatedKcal);

      // Clear active session
      state = null;
  }

  void _updatePRs(dynamic db, List<WorkoutExercise> exercises) {
    for (final ex in exercises) {
      for (final s in ex.sets) {
        if (!s.completed || s.weightKg <= 0 || s.reps <= 0) continue;
        final epley = s.reps == 1 ? s.weightKg : s.weightKg * (1 + s.reps / 30.0);

        // Look up existing PR
        final existing = db.exercisePRDocs
            .filter()
            .exerciseNameEqualTo(ex.name, caseSensitive: false)
            .findFirstSync();

        if (existing == null || epley > existing.estimated1RMKg) {
          final pr = existing ?? ExercisePRDoc();
          pr.exerciseName = ex.name;
          pr.achievedAt = DateTime.now();
          pr.computeEpley(s.weightKg, s.reps);
          db.writeTxnSync(() => db.exercisePRDocs.putSync(pr));
        }
      }
    }
  }
}
