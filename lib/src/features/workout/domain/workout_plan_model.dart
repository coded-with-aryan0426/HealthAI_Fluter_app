import '../../../database/models/workout_plan_doc.dart';

/// Transient domain model for an AI-generated workout plan (before saving to Isar).
/// Parsed from the ```workout_plan JSON block in chat responses.
class WorkoutPlanData {
  final String title;
  final String mode; // 'gym' | 'home'
  final String? aiSummary;
  final List<WorkoutDayData> days;

  const WorkoutPlanData({
    required this.title,
    required this.mode,
    this.aiSummary,
    required this.days,
  });

  factory WorkoutPlanData.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List? ?? [];
    return WorkoutPlanData(
      title: json['title'] as String? ?? 'AI Workout Plan',
      mode: json['mode'] as String? ?? 'gym',
      aiSummary: json['summary'] as String?,
      days: rawDays
          .map((d) => WorkoutDayData.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'mode': mode,
        if (aiSummary != null) 'summary': aiSummary,
        'days': days.map((d) => d.toJson()).toList(),
      };

  /// Saves this plan as a single WorkoutPlanDoc (all days flattened, or one day).
  WorkoutPlanDoc toPlanDoc({int dayIndex = 0}) {
    final day = dayIndex < days.length ? days[dayIndex] : null;
    final exercises = day?.exercises ?? allExercises;

    return WorkoutPlanDoc()
      ..title = day != null ? '$title — ${day.dayLabel}' : title
      ..createdAt = DateTime.now()
      ..source = 'ai'
      ..mode = mode
      ..aiSummary = aiSummary
      ..exercises = exercises
            .map((e) => PlannedExercise()
              ..name = e.name
              ..sets = e.sets
              ..reps = e.reps
              ..restSeconds = e.restSeconds
              ..notes = e.notes ?? '')
          .toList();
  }

  /// All exercises across all days, flattened.
  List<PlannedExerciseData> get allExercises =>
      days.expand((d) => d.exercises).toList();

  int get totalExercises => allExercises.length;

  /// Rough estimate: ~3 min per set + rest time
  int get estimatedMinutes {
    int total = 0;
    for (final e in allExercises) {
      total += (e.sets * 3) + ((e.sets - 1) * (e.restSeconds ~/ 60));
    }
    return total.clamp(10, 120);
  }
}

class WorkoutDayData {
  final String dayLabel; // e.g. "Day 1 - Push"
  final List<PlannedExerciseData> exercises;

  const WorkoutDayData({required this.dayLabel, required this.exercises});

  factory WorkoutDayData.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List? ?? [];
    return WorkoutDayData(
      dayLabel: json['day'] as String? ?? 'Day',
      exercises: rawExercises
          .map((e) => PlannedExerciseData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'day': dayLabel,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}

class PlannedExerciseData {
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;

  const PlannedExerciseData({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
  });

  factory PlannedExerciseData.fromJson(Map<String, dynamic> json) {
    return PlannedExerciseData(
      name: json['name'] as String? ?? '',
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      reps: (json['reps'] as num?)?.toInt() ?? 12,
      restSeconds: (json['rest_seconds'] as num?)?.toInt() ?? 60,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'rest_seconds': restSeconds,
        if (notes != null) 'notes': notes,
      };
}
