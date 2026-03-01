import 'package:isar/isar.dart';

part 'body_entry_doc.g.dart';

@collection
class BodyEntryDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: false)
  late DateTime date;

  /// Weight in kg (0 = not logged)
  double weightKg = 0;

  /// Body fat percentage (0 = not logged)
  double bodyFatPct = 0;

  /// Waist circumference in cm (0 = not logged)
  double waistCm = 0;

  /// Hip circumference in cm (0 = not logged)
  double hipCm = 0;

  /// Optional note
  String note = '';
}
