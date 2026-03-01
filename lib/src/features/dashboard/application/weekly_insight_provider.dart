import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/application/user_provider.dart';
import '../../../services/ai_service.dart';
import 'weekly_stats_provider.dart';

final weeklyInsightProvider =
    AsyncNotifierProvider<WeeklyInsightNotifier, String>(
        WeeklyInsightNotifier.new);

class WeeklyInsightNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final user = ref.read(userProvider);
    final now = DateTime.now();

    // Cache for 24 hours (re-generate once per day)
    final cached = user.weeklyAiSummary;
    final generatedAt = user.weeklyAiSummaryGeneratedAt;
    if (cached != null &&
        cached.isNotEmpty &&
        generatedAt != null &&
        now.difference(generatedAt).inHours < 24) {
      return cached;
    }

    return _generate();
  }

  Future<String> _generate() async {
    try {
      final stats = ref.read(weeklyStatsProvider);
      final user = ref.read(userProvider);

      final prompt = '''
You are a personal health coach. Write a concise, motivating 2-3 sentence weekly summary for the user.
Be specific with the numbers, warm, and end with one actionable suggestion for next week.
Do NOT use bullet points, markdown headers, or bold text.

User: ${user.displayName ?? 'User'}, Goal: ${user.primaryGoal}, Level: ${user.fitnessLevel}
This week:
- Workouts completed: ${stats.totalWorkouts}
- Total exercise: ${stats.totalExerciseMinutes} minutes
- Avg daily steps: ${stats.avgSteps}
- Avg sleep: ${(stats.avgSleepMinutes / 60).toStringAsFixed(1)} hours
- Total calories burned: ${stats.totalCaloriesBurned} kcal
- Total protein: ${stats.totalProteinGrams}g
${stats.topWorkoutTitle != null ? '- Most done workout: ${stats.topWorkoutTitle}' : ''}

Write only the summary text, nothing else.
''';

      final result = await ref.read(aiServiceProvider).sendMessage(prompt);
      if (result != null && result.isNotEmpty && !result.startsWith('__')) {
        final clean = result
            .replaceAll(RegExp(r'^#+\s+', multiLine: true), '')
            .replaceAll('**', '')
            .trim();
        await ref.read(userProvider.notifier).cacheWeeklySummary(clean);
        return clean;
      }
    } catch (_) {}

    return "Great work this week! Consistency is the key to long-term results. Keep building on your progress next week.";
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_generate);
  }
}
