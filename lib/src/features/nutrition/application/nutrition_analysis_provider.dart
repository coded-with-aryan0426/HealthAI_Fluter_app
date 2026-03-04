import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/meal_doc.dart';
import '../../profile/application/user_provider.dart';
import '../domain/nutrition_insight.dart';
import '../domain/nutrition_targets.dart';
import 'meal_provider.dart';
import 'nutrition_targets_provider.dart';

// ── Per-day cache ─────────────────────────────────────────────────────────────

final _cache = <String, ({NutritionInsight insight, DateTime at})>{};

/// Provides an AI nutrition analysis for a given date.
/// Cached for 1 hour per day. Re-analyzes when meals change.
final nutritionAnalysisProvider = FutureProvider.family<NutritionInsight?, DateTime>(
  (ref, date) async {
    final midnight = DateTime(date.year, date.month, date.day);
    final key = '${midnight.year}-${midnight.month}-${midnight.day}';

    // Return cache if fresh
    final cached = _cache[key];
    if (cached != null &&
        DateTime.now().difference(cached.at) < const Duration(hours: 1)) {
      return cached.insight;
    }

    // Need at least 1 meal to analyze
    final meals = ref.watch(mealsForDateProvider(midnight));
    if (meals.isEmpty) return null;

    final targets = ref.read(nutritionTargetsProvider);
    final user = ref.read(userProvider);

    final totalCal = meals.fold(0, (s, m) => s + m.calories);
    final totalProtein = meals.fold(0, (s, m) => s + m.proteinGrams);
    final totalCarbs = meals.fold(0, (s, m) => s + m.carbsGrams);
    final totalFat = meals.fold(0, (s, m) => s + m.fatGrams);
    final totalFiber = meals.fold(0.0, (s, m) => s + m.fiberGrams);
    final totalSodium = meals.fold(0.0, (s, m) => s + m.sodiumMg);
    final mealNames = meals.map((m) => m.name).join(', ');

    final prompt = '''
Today's intake summary:
- Calories: $totalCal / ${targets.calories} kcal
- Protein: ${totalProtein}g / ${targets.proteinG}g
- Carbs: ${totalCarbs}g / ${targets.carbsG}g
- Fat: ${totalFat}g / ${targets.fatG}g
- Fiber: ${totalFiber.toStringAsFixed(1)}g (goal: 25g)
- Sodium: ${totalSodium.toStringAsFixed(0)}mg (limit: 2300mg)
- Meals logged: $mealNames
- User goal: ${user.primaryGoal}
- Dietary preferences: ${user.preferences.dietary.join(', ')}

Return ONLY valid JSON (no markdown, no explanation):
{
  "score": <number 0-100>,
  "grade": "<A|B|C|D|F>",
  "summary": "<1 sentence summary>",
  "positives": ["<string>"],
  "alerts": [
    { "type": "<deficiency|excess|warning>", "nutrient": "<string>", "message": "<string>", "severity": "<low|medium|high>" }
  ],
  "suggestions": ["<actionable tip>"],
  "tomorrow_tip": "<1 tip for tomorrow>"
}
''';

    try {
      final ai = ref.read(aiServiceProvider);
      final raw = await ai.sendMessage(prompt);
      if (raw == null || raw.isEmpty || raw.startsWith('__')) return null;

      final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1) return null;

      final json = jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
      final insight = NutritionInsight.fromJson(json);
      _cache[key] = (insight: insight, at: DateTime.now());
      return insight;
    } catch (_) {
      return null;
    }
  },
);

/// Invalidate the cache for today, forcing a fresh analysis on next watch.
void invalidateDailyNutritionCache(DateTime date) {
  final key = '${date.year}-${date.month}-${date.day}';
  _cache.remove(key);
}
