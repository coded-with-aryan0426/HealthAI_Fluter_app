import 'package:isar/isar.dart';

part 'workout_program_doc.g.dart';

@collection
class WorkoutProgramDoc {
  Id id = Isar.autoIncrement;

  late String name;
  late String goal;          // e.g. "Build Muscle", "Lose Fat"
  int weeksTotal = 8;
  int currentWeek = 1;
  bool isActive = false;
  String mode = 'gym';       // 'gym' | 'home'
  String? aiSummary;
  late DateTime startedAt;
  DateTime? lastActiveAt;

  /// Each element is a JSON string representing one week's plan days.
  /// Format: List of { day: String, exercises: [...] }
  List<String> weeklyPlanJson = [];

  /// Flat list of WorkoutPlanDoc ids (one per day across all weeks).
  List<int> planDocIds = [];
}

@embedded
class ProgramWeek {
  int weekNumber = 1;
  String focus = ''; // e.g. "Volume", "Intensity", "Deload"
  List<int> planDocIds = []; // references to WorkoutPlanDoc ids for this week
}
