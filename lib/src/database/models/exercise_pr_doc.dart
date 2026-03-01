import 'package:isar/isar.dart';

part 'exercise_pr_doc.g.dart';

@collection
class ExercisePRDoc {
  Id id = Isar.autoIncrement;

  late String exerciseName;
  double maxWeightKg = 0;
  int maxReps = 0;
  double estimated1RMKg = 0; // Epley: weight * (1 + reps/30)
  late DateTime achievedAt;

  /// Computes and stores the Epley estimated 1RM from weight + reps.
  void computeEpley(double weightKg, int reps) {
    maxWeightKg = weightKg;
    maxReps = reps;
    estimated1RMKg = reps == 1
        ? weightKg
        : double.parse(
            (weightKg * (1 + reps / 30.0)).toStringAsFixed(2));
  }
}
