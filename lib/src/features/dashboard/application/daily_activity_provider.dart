import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/daily_log_doc.dart';
import '../../../services/health_service.dart';

final dailyActivityProvider = NotifierProvider<DailyActivityNotifier, DailyLogDoc>(DailyActivityNotifier.new);

class DailyActivityNotifier extends Notifier<DailyLogDoc> {
  @override
  DailyLogDoc build() {
    _initToday();
    return DailyLogDoc()..date = _startOfToday();
  }

  Isar get _db => ref.read(isarProvider);

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _initToday() {
    final today = _startOfToday();
    final existing = _db.dailyLogDocs.where().dateEqualTo(today).findFirstSync();

    if (existing != null) {
      state = existing;
    } else {
      final newDay = DailyLogDoc()
        ..date = today
        ..caloriesBurned = 450
        ..caloriesBurnedGoal = 600
        ..exerciseGoalMinutes = 45
        ..exerciseCompletedMinutes = 20
        ..standGoalHours = 12
        ..standCompletedHours = 7
        ..proteinGrams = 85
        ..carbsGrams = 150
        ..fatGrams = 45
        ..caloriesConsumed = 1200
        ..waterMl = 1200
        ..waterGoalMl = 2500
        ..sleepMinutes = 450
        ..stepCount = 4500;

      _db.writeTxnSync(() {
        _db.dailyLogDocs.putSync(newDay);
      });
      state = newDay;
    }
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
    state = _clone(state)
      ..exerciseCompletedMinutes = state.exerciseCompletedMinutes + minutes
      ..caloriesBurned = state.caloriesBurned + caloriesBurned;
    _persist();
  }

  void updateSleep(int minutes) {
    state = _clone(state)..sleepMinutes = minutes;
    _persist();
  }

  void addMeal({required int calories, required int protein, required int carbs, required int fat}) {
    state = _clone(state)
      ..caloriesConsumed = state.caloriesConsumed + calories
      ..proteinGrams = state.proteinGrams + protein
      ..carbsGrams = state.carbsGrams + carbs
      ..fatGrams = state.fatGrams + fat;
    _persist();
  }

  /// Sync real steps + sleep from HealthKit / Health Connect.
  /// Only updates values that are larger than current (health data is authoritative).
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
