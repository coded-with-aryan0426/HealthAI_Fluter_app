import 'package:isar/isar.dart';

part 'meal_plan_doc.g.dart';

@collection
class MealPlanDoc {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;
  late DateTime targetDate;       // Start date of the plan
  int durationDays = 7;           // 1 / 7 / 30
  String goal = 'maintenance';    // fat_loss / muscle_gain / maintenance / recomposition
  String status = 'draft';        // draft / active / completed

  // JSON-serialized MealPlanModel
  late String planJson;

  // Summary for quick display
  int avgDailyCalories = 0;
  int avgDailyProtein = 0;

  // Snapshot of user context at generation time
  String userContextSnapshot = '';
}
