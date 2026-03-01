import 'package:isar/isar.dart';

part 'workout_doc.g.dart';

@collection
class WorkoutDoc {
  Id id = Isar.autoIncrement;

  late DateTime date;
  late String title;
  int durationSeconds = 0;
  String source = 'manual'; // e.g., ai_generated, manual, pre_built

  // Phase 3 additions
  int totalVolumeKg = 0; // sum of (weight × reps) across all completed sets
  String? planTitle;     // linked WorkoutPlanDoc title

  List<WorkoutExercise> exercises = [];
}

@embedded
class WorkoutExercise {
  String name = '';
  List<WorkoutSetDoc> sets = [];
}

@embedded
class WorkoutSetDoc {
  int reps = 0;
  double weightKg = 0;
  bool completed = false;
}
