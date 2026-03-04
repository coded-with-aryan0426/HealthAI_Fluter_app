import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../../../nutrition/domain/meal_plan_model.dart';

class MealPlanCard extends StatefulWidget {
  final String planJson;
  const MealPlanCard({super.key, required this.planJson});

  @override
  State<MealPlanCard> createState() => _MealPlanCardState();
}

class _MealPlanCardState extends State<MealPlanCard> {
  int _selectedDayIndex = 0;
  late MealPlanModel _plan;
  bool _parseError = false;

  @override
  void initState() {
    super.initState();
    try {
      _plan = MealPlanModel.fromJson(
          jsonDecode(widget.planJson) as Map<String, dynamic>);
    } catch (_) {
      _parseError = true;
      _plan = const MealPlanModel(title: '', dailyCalories: 0, days: []);
    }
  }

  static const _mealColors = {
    'breakfast': Color(0xFFFF9F43),
    'lunch': Color(0xFF00D4B2),
    'dinner': Color(0xFF6B7AFF),
    'snack': Color(0xFFFF6B6B),
  };

  static const _mealIcons = {
    'breakfast': PhosphorIconsFill.sun,
    'lunch': PhosphorIconsFill.forkKnife,
    'dinner': PhosphorIconsFill.moon,
    'snack': PhosphorIconsFill.cookie,
  };

  @override
  Widget build(BuildContext context) {
    if (_parseError) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = _plan.days;
    final selectedDay = days.isNotEmpty ? days[_selectedDayIndex] : null;

    final totalCal = selectedDay?.meals.fold(0, (s, m) => s + m.calories) ?? 0;
    final totalPro = selectedDay?.meals.fold(0, (s, m) => s + m.protein) ?? 0;
    final totalCarb = selectedDay?.meals.fold(0, (s, m) => s + m.carbs) ?? 0;
    final totalFat = selectedDay?.meals.fold(0, (s, m) => s + m.fat) ?? 0;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13151F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.2 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dynamicMint.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A2A2A), const Color(0xFF0D1B1B)]
                    : [const Color(0xFFE0FFF8), const Color(0xFFC8F7EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dynamicMint.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(PhosphorIconsFill.forkKnife,
                      color: AppColors.dynamicMint, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MEAL PLAN',
                        style: TextStyle(
                          color: AppColors.dynamicMint,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        _plan.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_plan.dailyCalories > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dynamicMint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '~${_plan.dailyCalories} kcal/day',
                      style: const TextStyle(
                        color: AppColors.dynamicMint,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Day selector
          if (days.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: days.length,
                itemBuilder: (_, i) {
                  final sel = i == _selectedDayIndex;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDayIndex = i);
                    },
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.dynamicMint
                            : AppColors.dynamicMint.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        days[i].day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: sel ? Colors.white : AppColors.dynamicMint,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Daily macro summary
          if (selectedDay != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _MacroChip(label: 'Cal', value: '$totalCal', color: AppColors.warning),
                  const SizedBox(width: 8),
                  _MacroChip(label: 'Pro', value: '${totalPro}g', color: AppColors.dynamicMint),
                  const SizedBox(width: 8),
                  _MacroChip(label: 'Carb', value: '${totalCarb}g', color: AppColors.softIndigo),
                  const SizedBox(width: 8),
                  _MacroChip(label: 'Fat', value: '${totalFat}g', color: AppColors.danger),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Meals list
            ...selectedDay.meals.asMap().entries.map((entry) {
              final i = entry.key;
              final meal = entry.value;
              final color = _mealColors[meal.type] ?? AppColors.dynamicMint;
              final icon = _mealIcons[meal.type] ?? PhosphorIconsFill.forkKnife;
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, i == selectedDay.meals.length - 1 ? 16 : 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.type[0].toUpperCase() + meal.type.substring(1),
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              meal.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${meal.calories} kcal',
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'P${meal.protein} C${meal.carbs} F${meal.fat}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.35),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.1),
              );
            }),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
