import 'package:isar/isar.dart';

part 'supplement_doc.g.dart';

@collection
class SupplementDoc {
  Id id = Isar.autoIncrement;

  late String name;

  /// Dosage amount (e.g. 5)
  double dosage = 0;

  /// Unit: 'mg', 'g', 'IU', 'mcg', 'ml', 'capsule', 'tablet'
  String unit = 'mg';

  /// When to take: 'morning', 'with_meal', 'pre_workout', 'post_workout', 'evening', 'bedtime'
  List<String> timing = [];

  /// Color for UI (ARGB int)
  int colorValue = 0xFF6366F1;

  /// Icon name (reuses the habit icon system)
  String iconName = 'pill';

  /// Whether active / archived
  bool isActive = true;

  /// Notes / instructions
  String notes = '';
}

@collection
class SupplementLogDoc {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  /// FK to SupplementDoc.id
  @Index()
  late int supplementId;

  late DateTime takenAt;
}
