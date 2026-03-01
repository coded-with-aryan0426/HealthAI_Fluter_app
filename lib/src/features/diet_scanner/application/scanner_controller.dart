import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/application/daily_activity_provider.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_db_service.dart';
import '../../../services/open_food_facts_service.dart';
import '../../../database/models/meal_doc.dart';

final scannerControllerProvider = Provider<ScannerController>((ref) {
  return ScannerController(ref);
});

/// Result from [ScannerController.analyzeMeal].
sealed class ScanResult {}

class ScanSuccess extends ScanResult {
  final Map<String, dynamic> data;
  ScanSuccess(this.data);
}

class ScanRateLimit extends ScanResult {
  final int retryAfterSeconds;
  ScanRateLimit(this.retryAfterSeconds);
}

class ScanError extends ScanResult {
  final String message;
  ScanError(this.message);
}

class ScannerController {
  final Ref _ref;

  ScannerController(this._ref);

  Future<ScanResult> analyzeMeal(List<int> imageBytes, String mimeType) async {
    try {
      final aiService = _ref.read(aiServiceProvider);
      final jsonString =
          await aiService.analyzeFoodImage(imageBytes, mimeType);

      if (jsonString == null) {
        return ScanError('No response from AI. Please try again.');
      }

      if (jsonString.startsWith('__RATE_LIMIT__:')) {
        final secs = int.tryParse(jsonString.split(':').last) ?? 60;
        return ScanRateLimit(secs);
      }

      final cleaned = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final data = jsonDecode(cleaned) as Map<String, dynamic>;
      return ScanSuccess(data);
    } catch (e) {
      return ScanError('Could not parse nutrition data: $e');
    }
  }

  /// Barcode lookup via OpenFoodFacts.
  Future<ScanResult> analyzeBarcodeValue(String barcode) async {
    try {
      final service = _ref.read(openFoodFactsServiceProvider);
      final result = await service.lookup(barcode);
      if (result == null) {
        return ScanError(
            'Product not found in database. Try scanning again or enter manually.');
      }
      return ScanSuccess(result.toMap());
    } catch (e) {
      return ScanError('Barcode lookup failed: $e');
    }
  }

  /// Saves scanned meal(s) to both DailyLogDoc totals and individual MealDocs.
  /// [items] is used for multi-food results; falls back to single-item data.
  Future<void> saveMealToLog({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    String name = 'Scanned Meal',
    String mealType = 'snack',
    String source = 'scan',
    String? barcode,
    double portionMultiplier = 1.0,
  }) async {
    final scaledCal = (calories * portionMultiplier).round();
    final scaledPro = (protein * portionMultiplier).round();
    final scaledCarb = (carbs * portionMultiplier).round();
    final scaledFat = (fat * portionMultiplier).round();

    // 1. Update daily totals
    _ref.read(dailyActivityProvider.notifier).addMeal(
          calories: scaledCal,
          protein: scaledPro,
          carbs: scaledCarb,
          fat: scaledFat,
        );

    // 2. Persist individual MealDoc to Isar
    final db = _ref.read(isarProvider);
    final meal = MealDoc()
      ..name = name
      ..calories = scaledCal
      ..proteinGrams = scaledPro
      ..carbsGrams = scaledCarb
      ..fatGrams = scaledFat
      ..mealType = mealType
      ..dateLogged = DateTime.now()
      ..aiGenerated = source == 'scan'
      ..source = source
      ..barcode = barcode
      ..portionMultiplier = portionMultiplier;

    await db.writeTxn(() => db.mealDocs.put(meal));
  }
}
