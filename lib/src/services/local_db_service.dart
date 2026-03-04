import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../database/models/user_doc.dart';
import '../database/models/daily_log_doc.dart';
import '../database/models/meal_doc.dart';
import '../database/models/workout_doc.dart';
import '../database/models/workout_plan_doc.dart';
import '../database/models/workout_program_doc.dart';
import '../database/models/exercise_pr_doc.dart';
import '../database/models/habit_doc.dart';
import '../database/models/chat_session_doc.dart';
import '../database/models/fasting_doc.dart';
import '../database/models/body_entry_doc.dart';
import '../database/models/supplement_doc.dart';
import '../database/models/meal_plan_doc.dart';
import '../database/models/nutrition_log_doc.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar is not initialized yet');
});

const _schemas = [
  UserDocSchema,
  DailyLogDocSchema,
  MealDocSchema,
  WorkoutDocSchema,
  WorkoutPlanDocSchema,
  WorkoutProgramDocSchema,
  ExercisePRDocSchema,
  HabitDocSchema,
  ChatSessionDocSchema,
  FastingDocSchema,
  BodyEntryDocSchema,
  SupplementDocSchema,
  SupplementLogDocSchema,
  MealPlanDocSchema,
  NutritionLogDocSchema,
];

class LocalDBService {
  static Future<Isar> init() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      return await Isar.open(_schemas, directory: dir.path);
    } catch (_) {
      // Schema mismatch or corrupt DB — wipe and start fresh.
      await _deleteIsarFiles(dir.path);
      return await Isar.open(_schemas, directory: dir.path);
    }
  }

  static Future<void> _deleteIsarFiles(String dirPath) async {
    final directory = Directory(dirPath);
    if (!directory.existsSync()) return;
    for (final entity in directory.listSync()) {
      final name = entity.path.split('/').last;
      if (name.endsWith('.isar') || name.endsWith('.isar.lock')) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }
}
