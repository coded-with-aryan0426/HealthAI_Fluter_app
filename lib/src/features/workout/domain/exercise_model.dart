/// Domain model for an exercise from the free-exercise-db JSON dataset.
///
/// Image URLs are constructed as:
/// https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/<id>/0.jpg
class ExerciseModel {
  final String id;
  final String name;
  final String? force; // 'push' | 'pull' | 'static' | null
  final String level; // 'beginner' | 'intermediate' | 'expert'
  final String? mechanic; // 'compound' | 'isolation' | null
  final String? equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String category;
  final List<String> images; // relative paths e.g. "Barbell_Bench_Press/0.jpg"

  const ExerciseModel({
    required this.id,
    required this.name,
    this.force,
    required this.level,
    this.mechanic,
    this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.images,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      force: json['force'] as String?,
      level: json['level'] as String? ?? 'beginner',
      mechanic: json['mechanic'] as String?,
      equipment: json['equipment'] as String?,
      primaryMuscles: List<String>.from(json['primaryMuscles'] as List? ?? []),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] as List? ?? []),
      instructions: List<String>.from(json['instructions'] as List? ?? []),
      category: json['category'] as String? ?? 'strength',
      images: List<String>.from(json['images'] as List? ?? []),
    );
  }

  /// Returns the GitHub raw URL for the first exercise image/GIF.
  String? get gifUrl {
    if (images.isEmpty) return null;
    const base = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';
    return '$base${images.first}';
  }

  /// Returns a fallback thumbnail URL (second image if available, else first).
  String? get thumbnailUrl {
    if (images.isEmpty) return null;
    const base = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';
    final img = images.length > 1 ? images[1] : images[0];
    return '$base$img';
  }

  /// Default rest time in seconds based on category.
  int get defaultRestSeconds {
    return switch (category) {
      'strength' => 90,
      'powerlifting' => 120,
      'plyometrics' => 60,
      'cardio' => 20,
      'stretching' => 30,
      _ => 60,
    };
  }

  bool get isBodyweight =>
      equipment == null || equipment == 'body only' || equipment == 'none';
}
