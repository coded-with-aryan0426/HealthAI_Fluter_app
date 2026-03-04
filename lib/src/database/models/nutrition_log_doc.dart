import 'package:isar/isar.dart';

part 'nutrition_log_doc.g.dart';

/// Daily aggregated nutrition snapshot — one doc per calendar day.
/// Written/updated by [NutritionLogService] whenever meals change.
/// Used by analytics and the weekly report to avoid recomputing meal sums.
@collection
class NutritionLogDoc {
  Id id = Isar.autoIncrement;

  /// Midnight of the logged day (time portion is always 00:00:00)
  @Index(unique: true)
  late DateTime date;

  // ── Macros ──────────────────────────────────────────────────────────────────
  int totalCalories   = 0;
  int totalProteinG   = 0;
  int totalCarbsG     = 0;
  int totalFatG       = 0;

  // ── Micronutrients (optional, enriched from OpenFoodFacts / USDA) ──────────
  double fiberG       = 0;
  double sodiumMg     = 0;
  double sugarG       = 0;
  double calciumMg    = 0;
  double ironMg       = 0;
  double vitaminCMg   = 0;
  double vitaminDMcg  = 0;
  double potassiumMg  = 0;

  // ── Daily stats ──────────────────────────────────────────────────────────────
  int    mealCount        = 0;
  double avgHealthScore   = 0;  // average of MealDoc.healthScore for the day
  int    waterMl          = 0;  // pulled from DailyLogDoc

  // ── AI insight cache ─────────────────────────────────────────────────────────
  /// Cached JSON string of the last NutritionInsight for this day
  String? insightJson;
  DateTime? insightGeneratedAt;

  // ── Eating pattern helpers ────────────────────────────────────────────────────
  /// Comma-separated list of dominant meal types logged (Breakfast,Lunch,etc.)
  String mealTypesLogged  = '';
  /// True if the user hit their calorie goal (within ±10%) for this day
  bool   hitCalorieGoal   = false;
  /// True if protein target was met (≥ 90% of goal)
  bool   hitProteinGoal   = false;
}
