import 'package:isar/isar.dart';

part 'daily_log_doc.g.dart';

@collection
class DailyLogDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late DateTime date;

  int waterMl = 0;
  int waterGoalMl = 2500;

  int caloriesConsumed = 0;
  int caloriesBurned = 0;
  int caloriesBurnedGoal = 500;
  
  int exerciseCompletedMinutes = 0;
  int exerciseGoalMinutes = 30;
  
  int standCompletedHours = 0;
  int standGoalHours = 12;
  
  int proteinGrams = 0;
  int carbsGrams = 0;
  int fatGrams = 0;

  int sleepMinutes = 0;
  int stepCount = 0;
}
