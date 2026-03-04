import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/application/user_provider.dart';
import '../domain/nutrition_targets.dart';

/// Computes NutritionTargets from the current user's profile.
/// Re-computes whenever UserDoc changes.
final nutritionTargetsProvider = Provider<NutritionTargets>((ref) {
  final user = ref.watch(userProvider);
  return NutritionTargets.fromUser(user);
});
