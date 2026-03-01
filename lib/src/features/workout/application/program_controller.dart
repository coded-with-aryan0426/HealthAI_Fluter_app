import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/workout_program_doc.dart';
import '../../../database/models/workout_plan_doc.dart';

// ── Providers ──────────────────────────────────────────────────────────────────

final activeProgramProvider = StreamProvider<WorkoutProgramDoc?>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.workoutProgramDocs
      .filter()
      .isActiveEqualTo(true)
      .watch(fireImmediately: true)
      .map((list) => list.isEmpty ? null : list.first);
});

final allProgramsProvider = StreamProvider<List<WorkoutProgramDoc>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.workoutProgramDocs
      .where()
      .sortByStartedAtDesc()
      .watch(fireImmediately: true);
});

final programControllerProvider =
    NotifierProvider<ProgramController, void>(ProgramController.new);

// ── Controller ─────────────────────────────────────────────────────────────────

class ProgramController extends Notifier<void> {
  @override
  void build() {}

  Isar get _isar => ref.read(isarProvider);

  /// Create a new multi-week program from AI-parsed JSON.
  /// [weeklyPlansJson] is a list of week-objects, each with days + exercises.
  Future<WorkoutProgramDoc> createProgram({
    required String name,
    required String goal,
    required String mode,
    required int weeksTotal,
    required List<Map<String, dynamic>> weeklyPlansJson,
    String? aiSummary,
  }) async {
    final doc = WorkoutProgramDoc()
      ..name = name
      ..goal = goal
      ..mode = mode
      ..weeksTotal = weeksTotal
      ..currentWeek = 1
      ..isActive = false
      ..aiSummary = aiSummary
      ..startedAt = DateTime.now()
      ..weeklyPlanJson =
          weeklyPlansJson.map((w) => jsonEncode(w)).toList();

    await _isar.writeTxn(() async {
      await _isar.workoutProgramDocs.put(doc);
    });
    return doc;
  }

  /// Deactivate all programs without activating any.
  Future<void> deactivateAll() async {
    await _isar.writeTxn(() async {
      final all = await _isar.workoutProgramDocs.where().findAll();
      for (final p in all) {
        p.isActive = false;
      }
      await _isar.workoutProgramDocs.putAll(all);
    });
  }

  /// Activate a program (set isActive = true, deactivate others).
  Future<void> activateProgram(int programId) async {
    await _isar.writeTxn(() async {
      // Deactivate all
      final all = await _isar.workoutProgramDocs.where().findAll();
      for (final p in all) {
        p.isActive = false;
      }
      await _isar.workoutProgramDocs.putAll(all);

      // Activate selected
      final doc = await _isar.workoutProgramDocs.get(programId);
      if (doc == null) return;
      doc.isActive = true;
      doc.startedAt = DateTime.now();
      doc.currentWeek = 1;
      await _isar.workoutProgramDocs.put(doc);
    });
  }

  /// Advance to the next week.
  Future<void> advanceWeek(int programId) async {
    await _isar.writeTxn(() async {
      final doc = await _isar.workoutProgramDocs.get(programId);
      if (doc == null) return;
      if (doc.currentWeek < doc.weeksTotal) {
        doc.currentWeek++;
        doc.lastActiveAt = DateTime.now();
      } else {
        doc.isActive = false; // Program complete
      }
      await _isar.workoutProgramDocs.put(doc);
    });
  }

  /// Delete a program.
  Future<void> deleteProgram(int programId) async {
    await _isar.writeTxn(() async {
      await _isar.workoutProgramDocs.delete(programId);
    });
  }

  /// Build WorkoutPlanDoc objects from a week's JSON, save to Isar, return ids.
  Future<List<int>> buildWeekPlans(
      List<Map<String, dynamic>> days, String mode) async {
    final ids = <int>[];
    for (final day in days) {
      final exercises = (day['exercises'] as List<dynamic>? ?? [])
          .map((e) => PlannedExercise()
            ..name = e['name'] as String? ?? ''
            ..sets = e['sets'] as int? ?? 3
            ..reps = e['reps'] as int? ?? 12
            ..restSeconds = e['rest_seconds'] as int? ?? 60
            ..notes = e['notes'] as String? ?? '')
          .toList();

      final plan = WorkoutPlanDoc()
        ..title = day['day'] as String? ?? 'Day'
        ..createdAt = DateTime.now()
        ..source = 'ai'
        ..mode = mode
        ..exercises = exercises;

      await _isar.writeTxn(() async {
        await _isar.workoutPlanDocs.put(plan);
      });
      ids.add(plan.id);
    }
    return ids;
  }

  /// Parse a raw AI program JSON string into structured maps.
  static List<Map<String, dynamic>> parseWeeklyJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map) {
        // { weeks: [...] }
        final weeks = decoded['weeks'] as List<dynamic>? ?? [];
        return weeks
            .map((w) => Map<String, dynamic>.from(w as Map))
            .toList();
      } else if (decoded is List) {
        return decoded
            .map((w) => Map<String, dynamic>.from(w as Map))
            .toList();
      }
    } catch (e) {
      debugPrint('[ProgramController] parseWeeklyJson error: $e');
    }
    return [];
  }
}
