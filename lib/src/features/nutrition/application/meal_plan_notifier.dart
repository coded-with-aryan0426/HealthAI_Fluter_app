import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../database/models/meal_plan_doc.dart';
import '../../../database/models/meal_doc.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_db_service.dart';
import '../../profile/application/user_provider.dart';
import '../domain/meal_plan_model.dart';
import 'meal_provider.dart';
import 'nutrition_targets_provider.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum MealPlanStatus { idle, generating, error }

class MealPlanState {
  final MealPlanStatus status;
  final MealPlanDoc? activePlan;
  final List<MealPlanDoc> history;
  final String? errorMessage;

  const MealPlanState({
    this.status = MealPlanStatus.idle,
    this.activePlan,
    this.history = const [],
    this.errorMessage,
  });

  MealPlanState copyWith({
    MealPlanStatus? status,
    MealPlanDoc? activePlan,
    List<MealPlanDoc>? history,
    String? errorMessage,
  }) =>
      MealPlanState(
        status: status ?? this.status,
        activePlan: activePlan ?? this.activePlan,
        history: history ?? this.history,
        errorMessage: errorMessage,
      );

  MealPlanModel? get activePlanModel {
    final doc = activePlan;
    if (doc == null) return null;
    try {
      return MealPlanModel.fromJson(
          jsonDecode(doc.planJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class MealPlanNotifier extends Notifier<MealPlanState> {
  Isar get _db => ref.read(isarProvider);

  @override
  MealPlanState build() {
    // Defer _loadActive so it runs AFTER the initial state is returned.
    // Setting state= synchronously inside build() is illegal in Riverpod
    // and causes "Bad state: Tried to read the state of an uninitialized provider".
    Future.microtask(_loadActive);
    return const MealPlanState();
  }

  // ── Load ──────────────────────────────────────────────────────────────────────

  void _loadActive() {
    final docs = _db.mealPlanDocs
        .where()
        .sortByCreatedAtDesc()
        .findAllSync();

    final active = docs.where((d) => d.status == 'active').firstOrNull;
    final history = docs.take(10).toList();
    state = state.copyWith(activePlan: active, history: history);
  }

  // ── Generate a new AI meal plan ────────────────────────────────────────────────

  Future<void> generatePlan({
    required int durationDays, // 1 / 7
    DateTime? startDate,
  }) async {
    state = state.copyWith(status: MealPlanStatus.generating, errorMessage: null);

    final user = ref.read(userProvider);
    final targets = ref.read(nutritionTargetsProvider);

    final dietary = user.preferences.dietary.isNotEmpty
        ? user.preferences.dietary.join(', ')
        : 'no restrictions';

    final prompt = '''
You are a professional dietitian. Create a ${durationDays}-day personalised meal plan for:
- Goal: ${user.primaryGoal}
- Daily calorie target: ${targets.calories} kcal
- Protein: ${targets.proteinG}g | Carbs: ${targets.carbsG}g | Fat: ${targets.fatG}g
- Dietary preferences: $dietary
- Meals per day: ${user.mealsPerDay}
- Food allergies: ${user.foodAllergies.isNotEmpty ? user.foodAllergies.join(', ') : 'none'}

Rules:
1. Each day must hit ±100 kcal of the calorie target.
2. Protein target MUST be met within ±10g.
3. Respect ALL dietary restrictions absolutely.
4. Include practical, everyday meals — no exotic or hard-to-find ingredients.
5. Vary meals across days; do not repeat the same meal on consecutive days.

Return ONLY valid JSON (no markdown, no explanation) in EXACTLY this format:
{
  "title": "<plan title>",
  "daily_calories": ${targets.calories},
  "days": [
    {
      "day": "Day 1",
      "meals": [
        { "type": "breakfast", "name": "<name>", "calories": 0, "protein": 0, "carbs": 0, "fat": 0 },
        { "type": "lunch",     "name": "<name>", "calories": 0, "protein": 0, "carbs": 0, "fat": 0 },
        { "type": "dinner",    "name": "<name>", "calories": 0, "protein": 0, "carbs": 0, "fat": 0 }
      ]
    }
  ]
}
''';

    try {
      final ai = ref.read(aiServiceProvider);
      final raw = await ai.sendMessage(prompt);

      if (raw == null || raw.isEmpty || raw.startsWith('__')) {
        state = state.copyWith(
          status: MealPlanStatus.error,
          errorMessage: 'AI unavailable. Please try again.',
        );
        return;
      }

      // Parse JSON
      final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1) throw FormatException('No JSON found');

      final json = jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
      final plan = MealPlanModel.fromJson(json);

      // Compute summary stats
      int totalCal = 0, totalProtein = 0;
      for (final day in plan.days) {
        for (final meal in day.meals) {
          totalCal += meal.calories;
          totalProtein += meal.protein;
        }
      }
      final days = plan.days.isEmpty ? 1 : plan.days.length;

      // Deactivate any existing active plans
      await _db.writeTxn(() async {
        final existing = _db.mealPlanDocs
            .where()
            .findAllSync()
            .where((d) => d.status == 'active');
        for (final d in existing) {
          d.status = 'completed';
          await _db.mealPlanDocs.put(d);
        }
      });

      // Save new plan
      final doc = MealPlanDoc()
        ..createdAt = DateTime.now()
        ..targetDate = startDate ?? DateTime.now()
        ..durationDays = durationDays
        ..goal = user.primaryGoal
        ..status = 'active'
        ..planJson = jsonEncode(plan.toJson())
        ..avgDailyCalories = totalCal ~/ days
        ..avgDailyProtein = totalProtein ~/ days
        ..userContextSnapshot = 'goal=${user.primaryGoal},cal=${targets.calories}';

      await _db.writeTxn(() => _db.mealPlanDocs.put(doc));
      _loadActive();
      state = state.copyWith(status: MealPlanStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: MealPlanStatus.error,
        errorMessage: 'Failed to generate plan. Please try again.',
      );
    }
  }

  // ── Adopt a single day from the active plan into the meal log ─────────────────

  Future<void> adoptDay(int dayIndex) async {
    final plan = state.activePlanModel;
    if (plan == null || dayIndex >= plan.days.length) return;

    final day = plan.days[dayIndex];
    final today = DateTime.now();
    final notifier = ref.read(mealsForDateProvider(
      DateTime(today.year, today.month, today.day),
    ).notifier);

    for (final meal in day.meals) {
      await notifier.add(
        name: meal.name,
        mealType: _mealTypeLabel(meal.type),
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        fat: meal.fat,
        aiGenerated: true,
      );
    }
  }

  // ── Adopt a single meal item ──────────────────────────────────────────────────

  Future<void> adoptMeal(MealPlanItem meal) async {
    final today = DateTime.now();
    final notifier = ref.read(mealsForDateProvider(
      DateTime(today.year, today.month, today.day),
    ).notifier);

    await notifier.add(
      name: meal.name,
      mealType: _mealTypeLabel(meal.type),
      calories: meal.calories,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      aiGenerated: true,
    );
  }

  // ── Discard current plan ──────────────────────────────────────────────────────

  Future<void> discardActivePlan() async {
    final active = state.activePlan;
    if (active == null) return;
    await _db.writeTxn(() async {
      active.status = 'completed';
      await _db.mealPlanDocs.put(active);
    });
    _loadActive();
  }

  String _mealTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast': return 'Breakfast';
      case 'lunch': return 'Lunch';
      case 'dinner': return 'Dinner';
      default: return 'Snack';
    }
  }
}

final mealPlanNotifierProvider =
    NotifierProvider<MealPlanNotifier, MealPlanState>(MealPlanNotifier.new);
