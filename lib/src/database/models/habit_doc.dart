import 'package:isar/isar.dart';

part 'habit_doc.g.dart';

@collection
class HabitDoc {
  Id id = Isar.autoIncrement;

  late String title;
  String subtitle = '';
  String frequency = 'daily'; // daily, weekly
  String timeOfDay = 'any';   // morning, afternoon, evening, any
  String category = 'general'; // fitness, mental, nutrition, sleep, productivity
  String iconName = 'target';  // maps to PhosphorIcons name
  int colorValue = 0xFF6366F1; // stored as int, e.g. Color.value

  // Completion history — list of midnight-normalised DateTime per completed day
  List<DateTime> completedDates = [];

  int targetPerWeek = 7; // 7 = daily
  DateTime? reminderTime;

  late DateTime createdAt;
  bool isArchived = false;
}
