import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/supplement_doc.dart';

// ── All active supplements ────────────────────────────────────────────────────
final supplementsProvider =
    NotifierProvider<SupplementsNotifier, List<SupplementDoc>>(
        SupplementsNotifier.new);

// ── Today's logs (supplementId -> takenAt list) ───────────────────────────────
final todaySupplementLogsProvider =
    NotifierProvider<TodayLogsNotifier, Map<int, List<DateTime>>>(
        TodayLogsNotifier.new);

// ── Convenience: how many supplements taken today ────────────────────────────
final takenCountTodayProvider = Provider<int>((ref) {
  final logs = ref.watch(todaySupplementLogsProvider);
  return logs.values.where((v) => v.isNotEmpty).length;
});

// ── Supplements Notifier ─────────────────────────────────────────────────────
class SupplementsNotifier extends Notifier<List<SupplementDoc>> {
  Isar get _db => ref.read(isarProvider);

  @override
  List<SupplementDoc> build() {
    _load();
    return [];
  }

  void _load() {
    state = _db.supplementDocs
        .where()
        .filter()
        .isActiveEqualTo(true)
        .findAllSync();
  }

  Future<void> addSupplement({
    required String name,
    double dosage = 0,
    String unit = 'mg',
    List<String> timing = const [],
    int colorValue = 0xFF6366F1,
    String iconName = 'pill',
    String notes = '',
  }) async {
    final doc = SupplementDoc()
      ..name = name
      ..dosage = dosage
      ..unit = unit
      ..timing = timing
      ..colorValue = colorValue
      ..iconName = iconName
      ..isActive = true
      ..notes = notes;
    await _db.writeTxn(() => _db.supplementDocs.put(doc));
    _load();
  }

  Future<void> updateSupplement(SupplementDoc doc) async {
    await _db.writeTxn(() => _db.supplementDocs.put(doc));
    _load();
  }

  Future<void> archiveSupplement(int id) async {
    final doc = _db.supplementDocs.getSync(id);
    if (doc == null) return;
    doc.isActive = false;
    await _db.writeTxn(() => _db.supplementDocs.put(doc));
    _load();
  }
}

// ── Today Logs Notifier ───────────────────────────────────────────────────────
class TodayLogsNotifier extends Notifier<Map<int, List<DateTime>>> {
  Isar get _db => ref.read(isarProvider);

  @override
  Map<int, List<DateTime>> build() {
    ref.watch(supplementsProvider); // rebuild when supplements change
    _load();
    return {};
  }

  void _load() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final logs = _db.supplementLogDocs
        .where()
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .findAllSync();

    final map = <int, List<DateTime>>{};
    for (final log in logs) {
      map.putIfAbsent(log.supplementId, () => []).add(log.takenAt);
    }
    state = map;
  }

  Future<void> logTaken(int supplementId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final log = SupplementLogDoc()
      ..date = today
      ..supplementId = supplementId
      ..takenAt = now;

    await _db.writeTxn(() => _db.supplementLogDocs.put(log));
    _load();
  }

  Future<void> removeLastLog(int supplementId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final logs = _db.supplementLogDocs
        .where()
        .filter()
        .supplementIdEqualTo(supplementId)
        .dateBetween(startOfDay, endOfDay)
        .findAllSync();

    if (logs.isEmpty) return;
    final lastLog = logs.last;
    await _db.writeTxn(() => _db.supplementLogDocs.delete(lastLog.id));
    _load();
  }

  bool isTakenToday(int supplementId) {
    return (state[supplementId]?.isNotEmpty) ?? false;
  }
}
