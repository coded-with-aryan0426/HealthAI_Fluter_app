import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../profile/application/user_provider.dart';
import '../../habits/application/habit_provider.dart';
import '../../dashboard/application/daily_activity_provider.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/workout_doc.dart';

/// AsyncNotifier that generates (and caches) a one-sentence daily health insight.
/// Re-generates once per calendar day; serves the cached version otherwise.
final dailyInsightProvider =
    AsyncNotifierProvider<DailyInsightNotifier, String>(
        DailyInsightNotifier.new);

class DailyInsightNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final user = ref.read(userProvider);
    final now = DateTime.now();

    // Return cached value if it was generated today
    final cached = user.dailyInsightText;
    final generatedAt = user.dailyInsightGeneratedAt;
    if (cached != null &&
        cached.isNotEmpty &&
        generatedAt != null &&
        generatedAt.year == now.year &&
        generatedAt.month == now.month &&
        generatedAt.day == now.day) {
      return cached;
    }

    // Generate a new insight
    return _generate();
  }

  Future<String> _generate() async {
    try {
      final user = ref.read(userProvider);
      final today = ref.read(dailyActivityProvider);
      final habits = ref.read(habitsProvider);
      final isar = ref.read(isarProvider);

      final recentWorkouts = isar.workoutDocs
          .where()
          .sortByDateDesc()
          .limit(3)
          .findAllSync();

      final completedHabitsToday = habits.where((h) {
        final d = DateTime.now();
        return h.completedDates
            .any((c) => c.year == d.year && c.month == d.month && c.day == d.day);
      }).length;

      final workoutSummary = recentWorkouts.isEmpty
          ? 'no recent workouts'
          : recentWorkouts.map((w) {
              final mins = (w.durationSeconds / 60).round();
              return '${w.title} ${mins}min';
            }).join(', ');

      final prompt = '''
You are a personal health coach. Write ONE short, motivating, personalized insight (max 2 sentences) for the user's dashboard.
Be specific, warm, and actionable. Do NOT use bullet points or headings.

User context:
- Name: ${user.displayName ?? 'User'}, Goal: ${user.primaryGoal}, Level: ${user.fitnessLevel}
- Today: Calories burned ${today.caloriesBurned} kcal, Protein ${today.proteinGrams}g, Water ${today.waterMl}ml
- Habits done today: $completedHabitsToday / ${habits.length}
- Recent workouts: $workoutSummary

Write only the insight text, nothing else.
''';

      final result = await ref.read(aiServiceProvider).sendMessage(prompt);
      if (result != null &&
          result.isNotEmpty &&
          !result.startsWith('__')) {
        // Strip any accidental markdown
        final clean = result
            .replaceAll(RegExp(r'^#+\s+', multiLine: true), '')
            .replaceAll('**', '')
            .trim();
        await ref.read(userProvider.notifier).cacheDailyInsight(clean);
        return clean;
      }
    } catch (_) {}

    // Fallback static insight
    return "Every rep, every step, and every meal brings you closer to your goal. Keep going!";
  }

  /// Force-regenerate (e.g. pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_generate);
  }
}
