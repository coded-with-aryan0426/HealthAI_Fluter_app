import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/daily_log_doc.dart';
import '../../../services/health_service.dart';

final dailyActivityProvider = NotifierProvider<DailyActivityNotifier, DailyLogDoc>(DailyActivityNotifier.new);

class DailyActivityNotifier extends Notifier<DailyLogDoc> {
  @override
  DailyLogDoc build() {
    return _loadOrCreateToday();
  }

  Isar get _db => ref.read(isarProvider);

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DailyLogDoc _loadOrCreateToday() {
    final today = _startOfToday();
    final existing = _db.dailyLogDocs.where().dateEqualTo(today).findFirstSync();
    if (existing != null) return existing;

    final newDay = DailyLogDoc()
        ..date = today
        ..caloriesBurned = 0
        ..caloriesBurnedGoal = 600
        ..exerciseGoalMinutes = 45
        ..exerciseCompletedMinutes = 0
        ..standGoalHours = 12
        ..standCompletedHours = 0
        ..proteinGrams = 0
        ..carbsGrams = 0
        ..fatGrams = 0
        ..caloriesConsumed = 0
        ..waterMl = 0
        ..waterGoalMl = 2500
        ..sleepMinutes = 0
        ..stepCount = 0;

    _db.writeTxnSync(() {
      _db.dailyLogDocs.putSync(newDay);
    });
    return newDay;
  }

  void _persist() {
    _db.writeTxnSync(() {
      _db.dailyLogDocs.putSync(state);
    });
  }

  void addWater(int ml) {
    final newWater = (state.waterMl + ml).clamp(0, 9999);
    state = _clone(state)..waterMl = newWater;
    _persist();
  }

  void removeWater(int ml) {
    addWater(-ml);
  }

  void updateSteps(int steps) {
    state = _clone(state)..stepCount = steps;
    _persist();
  }

  void addCaloriesBurned(int kcal) {
    state = _clone(state)..caloriesBurned = state.caloriesBurned + kcal;
    _persist();
  }

    void addExercise({required int minutes, required int caloriesBurned}) {
      final newExerciseMinutes = state.exerciseCompletedMinutes + minutes;
      // Derive stand hours: each 30 min of accumulated exercise = 1 stand hour (max = standGoalHours)
      final derivedStandHours = (newExerciseMinutes / 30).floor().clamp(0, state.standGoalHours);
      state = _clone(state)
        ..exerciseCompletedMinutes = newExerciseMinutes
        ..caloriesBurned = state.caloriesBurned + caloriesBurned
        ..standCompletedHours = derivedStandHours;
      _persist();
    }

  void updateSleep(int minutes) {
    state = _clone(state)..sleepMinutes = minutes;
    _persist();
  }

  void addMeal({required int calories, required int protein, required int carbs, required int fat}) {
    state = _clone(state)
      ..caloriesConsumed = (state.caloriesConsumed + calories).clamp(0, 99999)
      ..proteinGrams = (state.proteinGrams + protein).clamp(0, 9999)
      ..carbsGrams = (state.carbsGrams + carbs).clamp(0, 9999)
      ..fatGrams = (state.fatGrams + fat).clamp(0, 9999);
    _persist();
  }

  /// Sync all vitals from HealthKit / Health Connect.
  /// Health data is authoritative — always takes the max value.
  Future<void> syncFromHealth() async {
    try {
      final service = ref.read(healthServiceProvider);
      final snapshot = await service.fetchToday();
      if (!snapshot.hasPermission) return;

      bool changed = false;
      final updated = _clone(state);

      if (snapshot.steps > updated.stepCount) {
        updated.stepCount = snapshot.steps;
        changed = true;
      }
      if (snapshot.sleepMinutes > 0 && snapshot.sleepMinutes != updated.sleepMinutes) {
        updated.sleepMinutes = snapshot.sleepMinutes;
        changed = true;
      }
      if (snapshot.activeCaloriesBurned > updated.caloriesBurned) {
        updated.caloriesBurned = snapshot.activeCaloriesBurned;
        changed = true;
      }
      // Sync exercise minutes from health (max of manual + health data)
      if (snapshot.exerciseMinutes > updated.exerciseCompletedMinutes) {
        updated.exerciseCompletedMinutes = snapshot.exerciseMinutes;
        changed = true;
      }
      // Sync stand hours from health data (capped at goal)
      final healthStand = snapshot.standHours.clamp(0, updated.standGoalHours);
      if (healthStand > updated.standCompletedHours) {
        updated.standCompletedHours = healthStand;
        changed = true;
      }

      if (changed) {
        state = updated;
        _persist();
      }
    } catch (_) {
      // Health sync is best-effort; never crash the dashboard
    }
  }

  DailyLogDoc _clone(DailyLogDoc src) {
    return DailyLogDoc()
      ..id = src.id
      ..date = src.date
      ..caloriesBurned = src.caloriesBurned
      ..caloriesBurnedGoal = src.caloriesBurnedGoal
      ..exerciseGoalMinutes = src.exerciseGoalMinutes
      ..exerciseCompletedMinutes = src.exerciseCompletedMinutes
      ..standGoalHours = src.standGoalHours
      ..standCompletedHours = src.standCompletedHours
      ..proteinGrams = src.proteinGrams
      ..carbsGrams = src.carbsGrams
      ..fatGrams = src.fatGrams
      ..caloriesConsumed = src.caloriesConsumed
      ..waterMl = src.waterMl
      ..waterGoalMl = src.waterGoalMl
      ..sleepMinutes = src.sleepMinutes
      ..stepCount = src.stepCount;
  }
}
