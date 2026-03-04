import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/models/daily_log_doc.dart';
import '../database/models/workout_doc.dart';
import '../database/models/meal_doc.dart';
import '../database/models/habit_doc.dart';
import '../database/models/user_doc.dart';
import 'pdf_report_service.dart';

/// Exports Isar data as PDF or CSV and shares via the native share sheet.
class DataExportService {
  const DataExportService._();

  // ── PDF export (primary) ──────────────────────────────────────────────────

  static Future<void> exportPdfAndShare(Isar isar, UserDoc user) async {
    final now  = DateTime.now();
    final file = await PdfReportService.generate(isar: isar, user: user);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'HealthAI — Health Report',
      text: 'Your HealthAI health report generated on ${_formatDate(now)}.',
    );
  }

  // ── CSV export (legacy, kept for reference) ───────────────────────────────

  static Future<void> exportAndShare(Isar isar) async {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));

    final files = await Future.wait([
      _buildDailyLogCsv(isar, from, now),
      _buildWorkoutCsv(isar, from, now),
      _buildMealCsv(isar, from, now),
      _buildHabitCsv(isar),
    ]);

    final xFiles = files.map((f) => XFile(f.path, mimeType: 'text/csv')).toList();

    await Share.shareXFiles(
      xFiles,
      subject: 'HealthAI — Health Data Export (last 30 days)',
      text: 'Your HealthAI health data exported on ${_formatDate(now)}.\n'
            'Includes: daily logs, workouts, meals, and habits.',
    );
  }

  // ── Daily logs ─────────────────────────────────────────────────────────────

  static Future<File> _buildDailyLogCsv(
      Isar isar, DateTime from, DateTime to) async {
    final docs = await isar.dailyLogDocs
        .filter()
        .dateBetween(from, to)
        .sortByDate()
        .findAll();

    final buf = StringBuffer();
    buf.writeln(
        'date,calories_consumed,calories_burned,protein_g,carbs_g,fat_g,'
        'water_ml,step_count,sleep_minutes,exercise_minutes');

    for (final d in docs) {
      buf.writeln([
        _formatDate(d.date),
        d.caloriesConsumed,
        d.caloriesBurned,
        d.proteinGrams,
        d.carbsGrams,
        d.fatGrams,
        d.waterMl,
        d.stepCount,
        d.sleepMinutes,
        d.exerciseCompletedMinutes,
      ].join(','));
    }

    return _writeTempFile('healthai_daily_logs.csv', buf.toString());
  }

  // ── Workouts ───────────────────────────────────────────────────────────────

  static Future<File> _buildWorkoutCsv(
      Isar isar, DateTime from, DateTime to) async {
    final docs = await isar.workoutDocs
        .filter()
        .dateBetween(from, to)
        .sortByDate()
        .findAll();

    final buf = StringBuffer();
    buf.writeln(
        'date,title,duration_seconds,total_volume_kg,source,plan_title,'
        'exercise_name,set_number,reps,weight_kg,completed');

    for (final w in docs) {
      if (w.exercises.isEmpty) {
        buf.writeln([
          _formatDate(w.date),
          _csvEscape(w.title),
          w.durationSeconds,
          w.totalVolumeKg,
          w.source,
          _csvEscape(w.planTitle ?? ''),
          '', '', '', '', '',
        ].join(','));
      } else {
        for (final ex in w.exercises) {
          if (ex.sets.isEmpty) {
            buf.writeln([
              _formatDate(w.date),
              _csvEscape(w.title),
              w.durationSeconds,
              w.totalVolumeKg,
              w.source,
              _csvEscape(w.planTitle ?? ''),
              _csvEscape(ex.name),
              '', '', '', '',
            ].join(','));
          } else {
            for (int i = 0; i < ex.sets.length; i++) {
              final s = ex.sets[i];
              buf.writeln([
                _formatDate(w.date),
                _csvEscape(w.title),
                w.durationSeconds,
                w.totalVolumeKg,
                w.source,
                _csvEscape(w.planTitle ?? ''),
                _csvEscape(ex.name),
                i + 1,
                s.reps,
                s.weightKg,
                s.completed ? 1 : 0,
              ].join(','));
            }
          }
        }
      }
    }

    return _writeTempFile('healthai_workouts.csv', buf.toString());
  }

  // ── Meals ──────────────────────────────────────────────────────────────────

  static Future<File> _buildMealCsv(
      Isar isar, DateTime from, DateTime to) async {
    final docs = await isar.mealDocs
        .filter()
        .dateLoggedBetween(from, to)
        .sortByDateLogged()
        .findAll();

    final buf = StringBuffer();
    buf.writeln(
        'date,meal_type,name,calories,protein_g,carbs_g,fat_g,source,ai_generated');

    for (final m in docs) {
      buf.writeln([
        _formatDate(m.dateLogged),
        m.mealType,
        _csvEscape(m.name),
        m.calories,
        m.proteinGrams,
        m.carbsGrams,
        m.fatGrams,
        m.source,
        m.aiGenerated ? 1 : 0,
      ].join(','));
    }

    return _writeTempFile('healthai_meals.csv', buf.toString());
  }

  // ── Habits ─────────────────────────────────────────────────────────────────

  static Future<File> _buildHabitCsv(Isar isar) async {
    final docs = await isar.habitDocs
        .filter()
        .isArchivedEqualTo(false)
        .findAll();

    final buf = StringBuffer();
    buf.writeln(
        'title,category,frequency,target_per_week,streak,'
        'total_completions,created_at');

    for (final h in docs) {
      final streak = _calcStreak(h.completedDates);
      buf.writeln([
        _csvEscape(h.title),
        h.category,
        h.frequency,
        h.targetPerWeek,
        streak,
        h.completedDates.length,
        _formatDate(h.createdAt),
      ].join(','));
    }

    return _writeTempFile('healthai_habits.csv', buf.toString());
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static int _calcStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final sorted = dates.map(_midnight).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime cursor = _midnight(DateTime.now());
    for (final d in sorted) {
      if (d == cursor || d == cursor.subtract(const Duration(days: 1))) {
        streak++;
        cursor = d;
      } else {
        break;
      }
    }
    return streak;
  }

  static DateTime _midnight(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _csvEscape(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  static Future<File> _writeTempFile(String name, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(content, flush: true);
    return file;
  }
}
