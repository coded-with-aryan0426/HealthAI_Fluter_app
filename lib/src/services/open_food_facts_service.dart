import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>((_) => OpenFoodFactsService());

class BarcodeLookupResult {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String barcode;
  final String? imageUrl;
  final String? brand;

  const BarcodeLookupResult({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.barcode,
    this.imageUrl,
    this.brand,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'barcode': barcode,
        'image_url': imageUrl,
        'brand': brand,
        'source': 'barcode',
        'items': null,
        'total': null,
        'portion': 'per 100g serving',
        'confidence': 'high',
      };
}

class OpenFoodFactsService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';
  static const _timeout = Duration(seconds: 10);

  Future<BarcodeLookupResult?> lookup(String barcode) async {
    try {
      final uri = Uri.parse('$_baseUrl/$barcode.json');
      final response = await http.get(uri, headers: {
        'User-Agent': 'HealthAI-Flutter/1.0 (contact@healthai.app)',
      }).timeout(_timeout);

      debugPrint('[OFF] barcode=$barcode status=${response.statusCode}');

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['status'] != 1) return null; // product not found

      final product = body['product'] as Map<String, dynamic>? ?? {};
      final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

      final name = (product['product_name'] as String?)?.trim() ??
          (product['generic_name'] as String?)?.trim() ??
          'Unknown Product';
      final brand = (product['brands'] as String?)?.trim();
      final imageUrl = product['image_front_url'] as String?;

      // Prefer per 100g values (more universal)
      int _toInt(dynamic v) => v == null ? 0 : (v as num).round();

      final calories = _toInt(
          nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal']);
      final protein = _toInt(
          nutriments['proteins_100g'] ?? nutriments['proteins']);
      final carbs = _toInt(
          nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates']);
      final fat = _toInt(
          nutriments['fat_100g'] ?? nutriments['fat']);

      return BarcodeLookupResult(
        name: brand != null ? '$name ($brand)' : name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        barcode: barcode,
        imageUrl: imageUrl,
        brand: brand,
      );
    } catch (e) {
      debugPrint('[OFF] lookup error: $e');
      return null;
    }
  }
}
