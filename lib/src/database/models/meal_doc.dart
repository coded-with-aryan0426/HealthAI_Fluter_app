import 'package:isar/isar.dart';

part 'meal_doc.g.dart';

@collection
class MealDoc {
  Id id = Isar.autoIncrement;

  late DateTime dateLogged;
  late String mealType; // Breakfast/Lunch/Dinner/Snack
  late String name;
  String? imageUrl;

  // Macros
  int calories = 0;
  int proteinGrams = 0;
  int carbsGrams = 0;
  int fatGrams = 0;

  // Micronutrients
  double fiberGrams = 0;
  double sodiumMg = 0;
  double sugarGrams = 0;
  double saturatedFatGrams = 0;
  double calciumMg = 0;
  double ironMg = 0;
  double vitaminCMg = 0;
  double vitaminDMcg = 0;
  double potassiumMg = 0;

  // Metadata
  List<String> ingredientsDetected = [];
  bool aiGenerated = false;
  String source = 'scan'; // scan | manual | barcode | planned | ai_generated
  String? barcode;
  double portionMultiplier = 1.0;
  bool planned = false;

  // AI quality fields
  double healthScore = 0; // 0–100
  String? imageLocalPath;

  // User feedback (personalization loop)
  bool? userApproved;
  String? userNote;
}
