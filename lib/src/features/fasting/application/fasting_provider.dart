import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/fasting_doc.dart';

// ── Active fasting session (null = not fasting) ──────────────────────────────
final fastingProvider =
    NotifierProvider<FastingNotifier, FastingState>(FastingNotifier.new);

// ── History (last 30 sessions) ───────────────────────────────────────────────
final fastingHistoryProvider = Provider<List<FastingDoc>>((ref) {
  ref.watch(fastingProvider); // rebuild on any change
  final db = ref.read(isarProvider);
  return db.fastingDocs
      .where()
      .filter()
      .isActiveEqualTo(false)
      .sortByStartTimeDesc()
      .limit(30)
      .findAllSync();
});

// ── Elapsed seconds ticker (only active when fasting) ────────────────────────
final fastingElapsedProvider = StreamProvider<int>((ref) {
  final state = ref.watch(fastingProvider);
  if (!state.isActive || state.session == null) return const Stream.empty();

  final start = state.session!.startTime;
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return DateTime.now().difference(start).inSeconds;
  });
});

// ── State ────────────────────────────────────────────────────────────────────
class FastingState {
  final FastingDoc? session;
  final bool isActive;

  const FastingState({this.session, this.isActive = false});
}

// ── Notifier ─────────────────────────────────────────────────────────────────
class FastingNotifier extends Notifier<FastingState> {
  Isar get _db => ref.read(isarProvider);

  @override
  FastingState build() {
    final active = _db.fastingDocs
        .where()
        .filter()
        .isActiveEqualTo(true)
        .findFirstSync();
    return FastingState(session: active, isActive: active != null);
  }

  Future<void> startFast({
    required int targetHours,
    required String protocolName,
  }) async {
    // End any existing active session first
    await _endAnyActive();

    final doc = FastingDoc()
      ..startTime = DateTime.now()
      ..targetHours = targetHours
      ..protocolName = protocolName
      ..isActive = true;

    await _db.writeTxn(() => _db.fastingDocs.put(doc));
    state = FastingState(session: doc, isActive: true);
  }

  Future<void> endFast() async {
    final active = state.session;
    if (active == null) return;

    active.endTime = DateTime.now();
    active.isActive = false;

    await _db.writeTxn(() => _db.fastingDocs.put(active));
    state = const FastingState(session: null, isActive: false);
  }

  Future<void> _endAnyActive() async {
    final actives =
        _db.fastingDocs.where().filter().isActiveEqualTo(true).findAllSync();
    for (final a in actives) {
      a.endTime = DateTime.now();
      a.isActive = false;
    }
    if (actives.isNotEmpty) {
      await _db.writeTxn(() => _db.fastingDocs.putAll(actives));
    }
  }

  /// Metabolic phase from elapsed hours
  static FastingPhase phaseFromHours(double hours) {
    if (hours < 4) return FastingPhase.fed;
    if (hours < 12) return FastingPhase.fatBurning;
    if (hours < 16) return FastingPhase.ketosis;
    if (hours < 24) return FastingPhase.deepKetosis;
    return FastingPhase.autophagy;
  }
}

enum FastingPhase { fed, fatBurning, ketosis, deepKetosis, autophagy }

extension FastingPhaseExt on FastingPhase {
  String get label {
    switch (this) {
      case FastingPhase.fed:         return 'Fed State';
      case FastingPhase.fatBurning:  return 'Fat Burning';
      case FastingPhase.ketosis:     return 'Ketosis';
      case FastingPhase.deepKetosis: return 'Deep Ketosis';
      case FastingPhase.autophagy:   return 'Autophagy';
    }
  }

  String get description {
    switch (this) {
      case FastingPhase.fed:
        return 'Your body is still processing the last meal.';
      case FastingPhase.fatBurning:
        return 'Insulin is low — your body starts burning stored fat.';
      case FastingPhase.ketosis:
        return 'Liver produces ketones for clean brain fuel.';
      case FastingPhase.deepKetosis:
        return 'Fat burning maximised. Mental clarity peaks.';
      case FastingPhase.autophagy:
        return 'Cellular cleanup mode. Damaged cells are being recycled.';
    }
  }

  double get startsAtHours {
    switch (this) {
      case FastingPhase.fed:         return 0;
      case FastingPhase.fatBurning:  return 4;
      case FastingPhase.ketosis:     return 12;
      case FastingPhase.deepKetosis: return 16;
      case FastingPhase.autophagy:   return 24;
    }
  }
}
