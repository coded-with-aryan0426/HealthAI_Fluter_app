import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/application/user_provider.dart';
import '../application/habit_provider.dart';
import '../../../services/ai_service.dart';

final habitInsightProvider =
    AsyncNotifierProvider<HabitInsightNotifier, String>(
        HabitInsightNotifier.new);

class HabitInsightNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final user = ref.read(userProvider);
    final now = DateTime.now();

    final cached = user.habitInsightText;
    final generatedAt = user.habitInsightGeneratedAt;
    if (cached != null &&
        cached.isNotEmpty &&
        generatedAt != null &&
        generatedAt.year == now.year &&
        generatedAt.month == now.month &&
        generatedAt.day == now.day) {
      return cached;
    }

    return _generate();
  }

  Future<String> _generate() async {
    try {
      final user = ref.read(userProvider);
      final habits = ref.read(habitsProvider);
      final notifier = ref.read(habitsProvider.notifier);
      final now = DateTime.now();

      final completedToday = habits
          .where((h) => h.completedDates
              .any((d) => d.year == now.year && d.month == now.month && d.day == now.day))
          .map((h) => h.title)
          .toList();

      final pendingToday = habits
          .where((h) => !h.completedDates
              .any((d) => d.year == now.year && d.month == now.month && d.day == now.day))
          .map((h) => h.title)
          .toList();

      final streak = notifier.calculateStreak();

      final prompt = '''
You are a supportive habit coach. Write ONE short motivating message (max 2 sentences) for the user's habits page.
Be specific about their actual habits. Keep it warm, concise, and actionable. No bullet points or headings.

User: ${user.displayName ?? 'User'}, Streak: $streak days
Completed today: ${completedToday.isEmpty ? 'none yet' : completedToday.join(', ')}
Still pending: ${pendingToday.isEmpty ? 'all done!' : pendingToday.join(', ')}

Write only the message text.
''';

      final result = await ref.read(aiServiceProvider).sendMessage(prompt);
      if (result != null && result.isNotEmpty && !result.startsWith('__')) {
        final clean = result
            .replaceAll(RegExp(r'^#+\s+', multiLine: true), '')
            .replaceAll('**', '')
            .trim();
        await ref.read(userProvider.notifier).cacheHabitInsight(clean);
        return clean;
      }
    } catch (_) {}

    return "Small steps compound into big results. Keep showing up for yourself!";
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_generate);
  }
}
