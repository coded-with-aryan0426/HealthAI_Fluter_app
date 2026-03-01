import 'package:isar/isar.dart';

part 'meal_doc.g.dart';

@collection
class MealDoc {
  Id id = Isar.autoIncrement;

  late DateTime dateLogged;
  late String mealType; // breakfast/lunch/dinner/snack
  late String name;
  String? imageUrl;

  int calories = 0;
  int proteinGrams = 0;
  int carbsGrams = 0;
  int fatGrams = 0;

  List<String> ingredientsDetected = [];
  bool aiGenerated = false;

  // New fields
  String source = 'scan'; // scan | manual | barcode | planned
  String? barcode;
  double portionMultiplier = 1.0; // applied at save time
  bool planned = false;
}
