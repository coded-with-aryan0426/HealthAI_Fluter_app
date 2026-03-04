import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../features/dashboard/application/daily_activity_provider.dart';
import '../features/profile/application/user_provider.dart';
import '../features/habits/application/habit_provider.dart';
import '../database/models/meal_doc.dart';
import '../database/models/workout_doc.dart';
import 'local_db_service.dart';

/// Builds a rich, up-to-date health context string from all available user
/// data.  Inject this as a system message at the start of every AI session so
/// the model never needs to ask the user for information it already has.
String buildAiContext(Ref ref) {
  final dailyLog = ref.read(dailyActivityProvider);
  final user = ref.read(userProvider);
  final habits = ref.read(habitsProvider);
  final isar = ref.read(isarProvider);

  // ── Last 3 workouts ──────────────────────────────────────────────────────
    final recentWorkouts =
        isar.workoutDocs.where().sortByDateDesc().limit(3).findAllSync();

  final workoutSummary = recentWorkouts.isEmpty
      ? 'No recent workouts'
      : recentWorkouts.map((w) {
          final mins = (w.durationSeconds / 60).round();
          return '${w.title} (${mins}min, ${w.date.day}/${w.date.month})';
        }).join(', ');

  // ── Habits ───────────────────────────────────────────────────────────────
  final notifier = ref.read(habitsProvider.notifier);
  final streak = notifier.calculateStreak();
  final completedToday = notifier.todayCompleted.length;

  // ── Today's meals (for food context) ────────────────────────────────────
  final today = DateTime.now();
  final todayMidnight = DateTime(today.year, today.month, today.day);
  final tomorrowMidnight = todayMidnight.add(const Duration(days: 1));

    final todayMeals = isar.mealDocs
        .where()
        .filter()
        .dateLoggedBetween(
          todayMidnight.subtract(const Duration(seconds: 1)),
          tomorrowMidnight,
        )
        .limit(50)
        .findAllSync();

  final mealSummary = todayMeals.isEmpty
      ? 'No meals logged yet today'
      : todayMeals
          .map((m) => '${m.mealType}: ${m.name} (${m.calories}kcal, '
              '${m.proteinGrams}g protein)')
          .join('; ');

  // ── Derived stats ─────────────────────────────────────────────────────────
  final age = user.dob != null
      ? '${DateTime.now().difference(user.dob!).inDays ~/ 365} years'
      : 'unknown';
  final weight =
      user.weightKg != null ? '${user.weightKg!.toStringAsFixed(1)} kg' : 'unknown';
  final height =
      user.heightCm != null ? '${user.heightCm!.toStringAsFixed(0)} cm' : 'unknown';
  final bmi = (user.weightKg != null && user.heightCm != null && user.heightCm! > 0)
      ? (user.weightKg! / ((user.heightCm! / 100) * (user.heightCm! / 100)))
          .toStringAsFixed(1)
      : 'unknown';

  final calGoal = user.calorieGoal > 0 ? user.calorieGoal : 2000;
  final calRemaining = calGoal - dailyLog.caloriesConsumed;
  final proteinGoal = user.proteinGoalG > 0 ? user.proteinGoalG : 120;
  final proteinRemaining = proteinGoal - dailyLog.proteinGrams;

  final now = DateTime.now();
  final timeOfDay = now.hour < 12
      ? 'morning'
      : now.hour < 17
          ? 'afternoon'
          : now.hour < 21
              ? 'evening'
              : 'night';

  final dietaryList = user.preferences.dietary;
  final dietaryLine = dietaryList.isEmpty
      ? 'none — user eats all foods including meat and animal products'
      : '⚠️ HARD RESTRICTIONS (MUST FOLLOW): ${dietaryList.join(', ').toUpperCase()} — '
          'ALL meal plans and food suggestions MUST strictly comply with these restrictions. '
          'NEVER suggest foods that violate them.';

  return '''[User Health Context — use for personalisation only, never repeat unless directly asked]:
- Name: ${user.displayName ?? 'User'} | Age: $age | Gender: ${user.gender ?? 'not specified'}
- Body: Height $height | Weight $weight | BMI: $bmi
- Goal: ${user.primaryGoal} | Fitness Level: ${user.fitnessLevel}
- Calorie Goal: $calGoal kcal/day | Protein Goal: ${proteinGoal}g/day
- Today ($timeOfDay): Calories consumed ${dailyLog.caloriesConsumed} kcal (${calRemaining > 0 ? '$calRemaining kcal remaining' : '${-calRemaining} kcal over goal'})
- Today macros: Protein ${dailyLog.proteinGrams}g (${proteinRemaining > 0 ? '${proteinRemaining}g remaining' : 'goal met'}), Carbs ${dailyLog.carbsGrams}g, Fat ${dailyLog.fatGrams}g
- Today calories burned: ${dailyLog.caloriesBurned}/${dailyLog.caloriesBurnedGoal} kcal
- Water: ${dailyLog.waterMl}/${dailyLog.waterGoalMl} ml | Sleep last night: ${dailyLog.sleepMinutes > 0 ? '${(dailyLog.sleepMinutes / 60).toStringAsFixed(1)} hours' : 'not logged'}
- Today's meals: $mealSummary
- Recent Workouts: $workoutSummary
- Habit streak: $streak days | Today: $completedToday/${habits.length} habits completed
- Dietary restrictions: $dietaryLine''';
}
