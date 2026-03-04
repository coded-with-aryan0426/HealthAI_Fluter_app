import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/body_entry_doc.dart';

final bodyEntriesProvider =
    NotifierProvider<BodyEntriesNotifier, List<BodyEntryDoc>>(
        BodyEntriesNotifier.new);

/// Latest entry (null if none)
final latestBodyEntryProvider = Provider<BodyEntryDoc?>((ref) {
  final entries = ref.watch(bodyEntriesProvider);
  if (entries.isEmpty) return null;
  return entries.first;
});

class BodyEntriesNotifier extends Notifier<List<BodyEntryDoc>> {
  Isar get _db => ref.read(isarProvider);

  @override
  List<BodyEntryDoc> build() {
    Future.microtask(_load);
    return [];
  }

  void _load() {
    final entries = _db.bodyEntryDocs
        .where()
        .sortByDateDesc()
        .limit(90)
        .findAllSync();
    state = entries;
  }

  Future<void> addEntry({
    required double weightKg,
    double bodyFatPct = 0,
    double waistCm = 0,
    double hipCm = 0,
    String note = '',
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if an entry exists for today
    final existing = _db.bodyEntryDocs
        .where()
        .filter()
        .dateBetween(today, today.add(const Duration(days: 1)))
        .findFirstSync();

    final doc = existing ?? BodyEntryDoc();
    doc
      ..date = today
      ..weightKg = weightKg
      ..bodyFatPct = bodyFatPct
      ..waistCm = waistCm
      ..hipCm = hipCm
      ..note = note;

    await _db.writeTxn(() => _db.bodyEntryDocs.put(doc));
    _load();
  }

  Future<void> deleteEntry(int id) async {
    await _db.writeTxn(() => _db.bodyEntryDocs.delete(id));
    state = state.where((e) => e.id != id).toList();
  }

  /// Weight change between first and last entry in last N days
  double weightDelta(int days) {
    if (state.length < 2) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = state.where((e) => e.date.isAfter(cutoff)).toList();
    if (recent.length < 2) return 0;
    return recent.first.weightKg - recent.last.weightKg;
  }

  /// Estimate goal date given target weight and current trajectory
  DateTime? estimatedGoalDate(double targetKg) {
    if (state.length < 7) return null;
    final delta = weightDelta(7);
    if (delta == 0) return null;
    final diff = state.first.weightKg - targetKg;
    if ((diff > 0) != (delta > 0)) return null; // moving wrong direction
    final weeksNeeded = diff / delta;
    return DateTime.now()
        .add(Duration(days: (weeksNeeded * 7).round()));
  }
}
