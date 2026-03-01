import 'package:isar/isar.dart';

part 'workout_plan_doc.g.dart';

@collection
class WorkoutPlanDoc {
  Id id = Isar.autoIncrement;

  late String title;
  late DateTime createdAt;
  String source = 'ai'; // 'ai' | 'preset' | 'custom'
  String mode = 'gym'; // 'gym' | 'home'
  bool isFavourite = false;
  String? aiSummary;

  List<PlannedExercise> exercises = [];
}

@embedded
class PlannedExercise {
  String exerciseId = ''; // maps to ExerciseDB id
  String name = '';
  int sets = 3;
  int reps = 12;
  int restSeconds = 60;
  String notes = '';
}
