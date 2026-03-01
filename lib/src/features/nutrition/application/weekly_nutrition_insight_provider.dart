import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../services/ai_service.dart';
import '../../../database/models/meal_doc.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class WeeklyNutritionInsight {
  final String summary;
  final double avgCalories;
  final double avgProtein;
  final double avgCarbs;
  final double avgFat;
  final String bestDay;
  final String worstDay;
  final List<String> suggestions;
  final DateTime generatedAt;

  const WeeklyNutritionInsight({
    required this.summary,
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
    required this.bestDay,
    required this.worstDay,
    required this.suggestions,
    required this.generatedAt,
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

final weeklyNutritionInsightProvider =
    AsyncNotifierProvider<WeeklyNutritionInsightNotifier, WeeklyNutritionInsight?>(
        WeeklyNutritionInsightNotifier.new);

class WeeklyNutritionInsightNotifier
    extends AsyncNotifier<WeeklyNutritionInsight?> {
  static const _cacheDuration = Duration(hours: 12);
  WeeklyNutritionInsight? _cached;

  @override
  Future<WeeklyNutritionInsight?> build() async {
    if (_cached != null &&
        DateTime.now().difference(_cached!.generatedAt) < _cacheDuration) {
      return _cached;
    }
    return _generate();
  }

  Future<WeeklyNutritionInsight?> refresh() async {
    state = const AsyncLoading();
    final result = await _generate();
    state = AsyncData(result);
    return result;
  }

  Future<WeeklyNutritionInsight?> _generate() async {
    try {
      final db = ref.read(isarProvider);
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

        final meals = db.mealDocs
            .filter()
            .dateLoggedBetween(weekAgo, now.add(const Duration(days: 1)))
            .findAllSync();

      if (meals.isEmpty) return null;

      // Group by day key
      final Map<String, List<MealDoc>> byDay = {};
      for (final m in meals) {
        final key =
            '${m.dateLogged.year}-${m.dateLogged.month.toString().padLeft(2, '0')}-${m.dateLogged.day.toString().padLeft(2, '0')}';
        byDay.putIfAbsent(key, () => []).add(m);
      }

      // Per-day totals
      final dayTotals = <String, ({int cal, int pro, int carb, int fat})>{};
      for (final entry in byDay.entries) {
        final ms = entry.value;
        dayTotals[entry.key] = (
          cal: ms.fold(0, (s, m) => s + m.calories),
          pro: ms.fold(0, (s, m) => s + m.proteinGrams),
          carb: ms.fold(0, (s, m) => s + m.carbsGrams),
          fat: ms.fold(0, (s, m) => s + m.fatGrams),
        );
      }

      final n = dayTotals.length.toDouble();
      final avgCal = dayTotals.values.fold(0, (s, d) => s + d.cal) / n;
      final avgPro = dayTotals.values.fold(0, (s, d) => s + d.pro) / n;
      final avgCarb = dayTotals.values.fold(0, (s, d) => s + d.carb) / n;
      final avgFat = dayTotals.values.fold(0, (s, d) => s + d.fat) / n;

      final best =
          dayTotals.entries.reduce((a, b) => a.value.cal > b.value.cal ? a : b).key;
      final worst =
          dayTotals.entries.reduce((a, b) => a.value.cal < b.value.cal ? a : b).key;

      // Compact summary for AI
      final buf = StringBuffer();
      buf.writeln('Weekly nutrition data (last 7 days):');
      for (final e in dayTotals.entries) {
        buf.writeln(
            '${e.key}: ${e.value.cal} kcal, ${e.value.pro}g protein, ${e.value.carb}g carbs, ${e.value.fat}g fat');
      }
      buf.writeln('Average: ${avgCal.round()} kcal, ${avgPro.round()}g protein');

      final prompt = '''
${buf.toString()}
User calorie goal: 2000 kcal, protein goal: 150g.

Return ONLY valid JSON (no markdown):
{
  "summary": "2-3 sentence narrative of their week",
  "suggestions": ["actionable tip 1", "actionable tip 2", "actionable tip 3"]
}
''';

      final ai = ref.read(aiServiceProvider);
      final raw = await ai.sendMessage(prompt);

      String? summary;
      List<String> suggestions = [];

      if (raw != null && raw.isNotEmpty && !raw.startsWith('__')) {
        try {
          final cleaned =
              raw.replaceAll('```json', '').replaceAll('```', '').trim();
          final start = cleaned.indexOf('{');
          final end = cleaned.lastIndexOf('}');
          if (start != -1 && end != -1) {
            final jsonStr = cleaned.substring(start, end + 1);
            final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
            summary = parsed['summary']?.toString();
            if (parsed['suggestions'] is List) {
              suggestions = List<String>.from(
                  (parsed['suggestions'] as List).map((e) => e.toString()));
            }
          }
        } catch (_) {
          summary = raw.length > 300 ? raw.substring(0, 300) : raw;
        }
      }

      final insight = WeeklyNutritionInsight(
        summary: summary ??
            'Good week! Keep tracking your meals for better insights.',
        avgCalories: avgCal,
        avgProtein: avgPro,
        avgCarbs: avgCarb,
        avgFat: avgFat,
        bestDay: best,
        worstDay: worst,
        suggestions: suggestions.isEmpty
            ? ['Stay consistent with meal logging', 'Aim for more protein']
            : suggestions,
        generatedAt: DateTime.now(),
      );

      _cached = insight;
      return insight;
    } catch (_) {
      return null;
    }
  }
}
