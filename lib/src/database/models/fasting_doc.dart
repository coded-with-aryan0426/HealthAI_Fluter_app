import 'package:isar/isar.dart';

part 'fasting_doc.g.dart';

@collection
class FastingDoc {
  Id id = Isar.autoIncrement;

  late DateTime startTime;
  DateTime? endTime;

  /// Target hours (e.g. 16, 18, 20, 24)
  int targetHours = 16;

  /// Protocol name e.g. "16:8", "18:6", "OMAD", "Custom"
  late String protocolName;

  /// Whether this session is currently active
  bool isActive = false;

  /// Notes (optional)
  String notes = '';

  // Computed helpers (stored for fast access)
  int get durationMinutes {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMinutes;
  }

  double get durationHours => durationMinutes / 60.0;

  bool get hitTarget => durationHours >= targetHours;
}
