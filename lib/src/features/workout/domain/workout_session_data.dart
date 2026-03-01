/// Shared data models used between WorkoutPlayerScreen and WorkoutSummaryScreen.

class SetLog {
  final double weightKg;
  final int reps;
  const SetLog({this.weightKg = 0, this.reps = 0});
}

class ExerciseState {
  final String name;
  final int totalSets;
  final int reps;
  final int restSeconds;
  int completedSets;
  late List<SetLog> setLogs;

  ExerciseState({
    required this.name,
    required this.totalSets,
    required this.reps,
    required this.restSeconds,
    this.completedSets = 0,
  }) {
    setLogs = List.generate(totalSets, (_) => const SetLog());
  }
}

class WorkoutSummaryData {
  final String title;
  final int durationSeconds;
  final int totalSets;
  final int completedSets;
  final int exerciseCount;
  final List<ExerciseState> exercises;

  const WorkoutSummaryData({
    required this.title,
    required this.durationSeconds,
    required this.totalSets,
    required this.completedSets,
    required this.exerciseCount,
    required this.exercises,
  });
}
