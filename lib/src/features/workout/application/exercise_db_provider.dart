import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/exercise_model.dart';

/// Loads and caches the bundled exercises.json asset (873 exercises from free-exercise-db).
final exerciseDbProvider = FutureProvider<List<ExerciseModel>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/exercises.json');
  final list = jsonDecode(jsonStr) as List;
  return list
      .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Look up a single exercise by its string ID.
final exerciseByIdProvider =
    Provider.family<ExerciseModel?, String>((ref, id) {
  final db = ref.watch(exerciseDbProvider).valueOrNull ?? [];
  try {
    return db.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
});

/// Fuzzy-search exercises by name (case-insensitive contains).
final exerciseSearchProvider =
    Provider.family<List<ExerciseModel>, String>((ref, query) {
  if (query.isEmpty) return [];
  final db = ref.watch(exerciseDbProvider).valueOrNull ?? [];
  final lower = query.toLowerCase();
  return db.where((e) => e.name.toLowerCase().contains(lower)).toList();
});

/// Lottie asset path mapping for home bodyweight exercises.
const Map<String, String> kExerciseLottieMap = {
  'push-up': 'assets/animations/pushup.json',
  'push up': 'assets/animations/pushup.json',
  'pushup': 'assets/animations/pushup.json',
  'squat': 'assets/animations/squat.json',
  'plank': 'assets/animations/plank.json',
  'burpee': 'assets/animations/burpee.json',
  'jumping jack': 'assets/animations/jumping_jacks.json',
  'lunge': 'assets/animations/lunge.json',
  'mountain climber': 'assets/animations/mountain_climber.json',
  'sit-up': 'assets/animations/pushup.json', // fallback to closest
  'sit up': 'assets/animations/pushup.json',
};

/// Returns the bundled Lottie asset path for the given exercise name, or null.
String? lottieForExercise(String name) {
  final lower = name.toLowerCase();
  for (final entry in kExerciseLottieMap.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}
