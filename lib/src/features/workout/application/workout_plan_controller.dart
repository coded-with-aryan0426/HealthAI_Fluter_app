import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../database/models/workout_plan_doc.dart';
import '../../../services/local_db_service.dart';
import '../domain/workout_plan_model.dart';

/// Stream of all saved workout plans, newest first.
final savedPlansProvider = StreamProvider<List<WorkoutPlanDoc>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.workoutPlanDocs
      .where()
      .sortByCreatedAtDesc()
      .watch(fireImmediately: true);
});

/// Stream of favourite plans only.
final favouritePlansProvider = StreamProvider<List<WorkoutPlanDoc>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.workoutPlanDocs
      .filter()
      .isFavouriteEqualTo(true)
      .watch(fireImmediately: true);
});

final workoutPlanControllerProvider =
    NotifierProvider<WorkoutPlanController, void>(WorkoutPlanController.new);

class WorkoutPlanController extends Notifier<void> {
  @override
  void build() {}

  Isar get _isar => ref.read(isarProvider);

  /// Save an AI-generated plan to Isar. Returns the saved document.
  Future<WorkoutPlanDoc> savePlan(WorkoutPlanData data,
      {int dayIndex = 0}) async {
    final doc = data.toPlanDoc(dayIndex: dayIndex);
    await _isar.writeTxn(() async {
      await _isar.workoutPlanDocs.put(doc);
    });
    return doc;
  }

  /// Save a raw WorkoutPlanDoc directly (e.g. from plan preview).
  Future<WorkoutPlanDoc> savePlanDoc(WorkoutPlanDoc doc) async {
    await _isar.writeTxn(() async {
      await _isar.workoutPlanDocs.put(doc);
    });
    return doc;
  }

  /// Toggle the favourite flag for a plan.
  Future<void> toggleFavourite(int planId) async {
    await _isar.writeTxn(() async {
      final doc = await _isar.workoutPlanDocs.get(planId);
      if (doc == null) return;
      doc.isFavourite = !doc.isFavourite;
      await _isar.workoutPlanDocs.put(doc);
    });
  }

  /// Delete a plan by ID.
  Future<void> deletePlan(int planId) async {
    await _isar.writeTxn(() async {
      await _isar.workoutPlanDocs.delete(planId);
    });
  }
}
