import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/meal_doc.dart';

/// Meals for a specific date
final mealsForDateProvider =
    NotifierProvider.family<MealsNotifier, List<MealDoc>, DateTime>(
        MealsNotifier.new);

class MealsNotifier extends FamilyNotifier<List<MealDoc>, DateTime> {
  Isar get _db => ref.read(isarProvider);

  DateTime get _date => arg;

  DateTime get _midnight =>
      DateTime(_date.year, _date.month, _date.day);

  @override
  List<MealDoc> build(DateTime arg) {
    _load();
    return [];
  }

  void _load() {
    final start = _midnight;
    final end = start.add(const Duration(days: 1));
    final meals = _db.mealDocs
        .where()
        .filter()
        .dateLoggedGreaterThan(start.subtract(const Duration(seconds: 1)))
        .and()
        .dateLoggedLessThan(end)
        .findAllSync();
    meals.sort((a, b) => a.dateLogged.compareTo(b.dateLogged));
    state = meals;
  }

  Future<void> add({
    required String name,
    required String mealType,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    bool aiGenerated = false,
    List<String> ingredients = const [],
  }) async {
    final doc = MealDoc()
      ..name = name
      ..mealType = mealType
      ..dateLogged = DateTime.now()
      ..calories = calories
      ..proteinGrams = protein
      ..carbsGrams = carbs
      ..fatGrams = fat
      ..aiGenerated = aiGenerated
      ..ingredientsDetected = ingredients;
    await _db.writeTxn(() => _db.mealDocs.put(doc));
    _load();
  }

  Future<void> remove(int id) async {
    await _db.writeTxn(() => _db.mealDocs.delete(id));
    state = state.where((m) => m.id != id).toList();
  }

  // Totals
  int get totalCalories =>
      state.fold(0, (s, m) => s + m.calories);
  int get totalProtein =>
      state.fold(0, (s, m) => s + m.proteinGrams);
  int get totalCarbs =>
      state.fold(0, (s, m) => s + m.carbsGrams);
  int get totalFat =>
      state.fold(0, (s, m) => s + m.fatGrams);
}
