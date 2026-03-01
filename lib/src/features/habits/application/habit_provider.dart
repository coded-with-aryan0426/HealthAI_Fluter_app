import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/habit_doc.dart';

final habitsProvider =
    NotifierProvider<HabitsNotifier, List<HabitDoc>>(HabitsNotifier.new);

class HabitsNotifier extends Notifier<List<HabitDoc>> {
  Isar get _db => ref.read(isarProvider);

  @override
  List<HabitDoc> build() {
    _load();
    return [];
  }

  void _load() {
    final habits = _db.habitDocs
        .where()
        .filter()
        .isArchivedEqualTo(false)
        .findAllSync();
    state = habits;
  }

  // ── Queries ──────────────────────────────────────────────────────────────

  /// Whether a given habit was completed on a specific date
  bool isCompletedOn(HabitDoc habit, DateTime date) {
    final day = _midnight(date);
    return habit.completedDates.any((d) => _midnight(d) == day);
  }

  /// Real streak: consecutive days ending today (or yesterday) with ≥1 completion
  int calculateStreak() {
    if (state.isEmpty) return 0;
    int streak = 0;
    DateTime day = _midnight(DateTime.now());
    while (true) {
      final anyDone = state.any((h) => isCompletedOn(h, day));
      if (!anyDone) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// All habits completed today
  List<HabitDoc> get todayCompleted =>
      state.where((h) => isCompletedOn(h, DateTime.now())).toList();

  // ── Mutations ────────────────────────────────────────────────────────────

  Future<void> toggle(int id, DateTime date) async {
    final habit = state.firstWhere((h) => h.id == id);
    final day = _midnight(date);
    final alreadyDone = habit.completedDates.any((d) => _midnight(d) == day);

    final updated = List<DateTime>.from(habit.completedDates);
    if (alreadyDone) {
      updated.removeWhere((d) => _midnight(d) == day);
    } else {
      updated.add(day);
    }
    habit.completedDates = updated;

    await _db.writeTxn(() => _db.habitDocs.put(habit));
    state = List.from(state);
  }

  Future<void> add({
    required String title,
    String subtitle = '',
    String iconName = 'target',
    int colorValue = 0xFF6366F1,
    String category = 'general',
    String frequency = 'daily',
    int targetPerWeek = 7,
    DateTime? reminderTime,
  }) async {
    final doc = HabitDoc()
      ..title = title
      ..subtitle = subtitle
      ..iconName = iconName
      ..colorValue = colorValue
      ..category = category
      ..frequency = frequency
      ..targetPerWeek = targetPerWeek
      ..completedDates = []
      ..createdAt = DateTime.now()
      ..isArchived = false
      ..reminderTime = reminderTime;

    await _db.writeTxn(() => _db.habitDocs.put(doc));
    _load();
  }

  Future<void> remove(int id) async {
    await _db.writeTxn(() => _db.habitDocs.delete(id));
    state = state.where((h) => h.id != id).toList();
  }

  Future<void> update(HabitDoc updated) async {
    await _db.writeTxn(() => _db.habitDocs.put(updated));
    state = state.map((h) => h.id == updated.id ? updated : h).toList();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);
}
