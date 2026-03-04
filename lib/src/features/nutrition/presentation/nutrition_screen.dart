import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../../profile/application/user_provider.dart';
import '../application/meal_provider.dart';
import '../application/weekly_nutrition_insight_provider.dart';
import '../application/nutrition_analysis_provider.dart';
import '../application/meal_plan_notifier.dart';
import '../domain/nutrition_insight.dart';
import '../../../database/models/meal_doc.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

const _quickFoods = [
  ('Oatmeal', 'Breakfast', 350, 12, 58, 7),
  ('Chicken Breast', 'Lunch', 280, 52, 0, 6),
  ('Greek Yogurt', 'Snack', 130, 17, 9, 0),
  ('Brown Rice', 'Lunch', 215, 5, 45, 2),
  ('Salmon Fillet', 'Dinner', 320, 46, 0, 14),
  ('Banana', 'Snack', 105, 1, 27, 0),
  ('Eggs x2', 'Breakfast', 155, 13, 1, 11),
  ('Avocado Toast', 'Breakfast', 290, 8, 34, 15),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();
  // Meal type pill filter index (0 = All)
  int _selectedMealTab = 0;

  DateTime get _midnight =>
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

  void _prevDay() => setState(
      () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
  void _nextDay() {
    final next = _selectedDate.add(const Duration(days: 1));
    if (next.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      setState(() => _selectedDate = next);
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    final yest = now.subtract(const Duration(days: 1));
    if (d.year == yest.year && d.month == yest.month && d.day == yest.day) {
      return 'Yesterday';
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meals = ref.watch(mealsForDateProvider(_midnight));
    final notifier = ref.read(mealsForDateProvider(_midnight).notifier);
    final user = ref.watch(userProvider);
    final calorieGoal = user.calorieGoal;
    final proteinGoal = user.proteinGoalG;
    // Derive carb/fat goals from calorie goal (50% carbs, 30% fat)
    final carbGoal = ((calorieGoal * 0.50) / 4).round();
    final fatGoal = ((calorieGoal * 0.30) / 9).round();
    final totalCal = notifier.totalCalories;
    final totalProtein = notifier.totalProtein;
    final totalCarbs = notifier.totalCarbs;
    final totalFat = notifier.totalFat;

    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor:
          isDark ? AppColors.deepObsidian : const Color(0xFFF7F8FC),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 60,
            backgroundColor:
                isDark ? AppColors.deepObsidian : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
              leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIconsRegular.arrowLeft,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                        size: 18),
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/dashboard');
                    }
                  },
                ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                'Nutrition',
                style: TextStyle(
                  color:
                      isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
              actions: [
                // Report Icon
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/nutrition/weekly-report');
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.softIndigo.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.chartBar,
                        color: AppColors.softIndigo, size: 18),
                  ),
                ),
                // Search Icon
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/nutrition/food-search');
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.magnifyingGlass,
                        color: AppColors.warning, size: 18),
                  ),
                ),
                // Scan Icon
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/scanner');
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.dynamicMint.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.barcode,
                        color: AppColors.dynamicMint, size: 18),
                  ),
                ),
                // Add Icon
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showAddMealSheet(context, isDark, notifier),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.dynamicMint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(PhosphorIconsFill.plus,
                        color: AppColors.dynamicMint, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
              ],
          ),
        ],
        body: SingleChildScrollView(
          physics: scrollPhysics,
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Date picker ─────────────────────────────────────────────
              _DateNavigator(
                label: _formatDate(_midnight),
                onPrev: _prevDay,
                onNext: _nextDay,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),

              // ── Daily macro progress bars ────────────────────────────────
              _DailyMacroBar(
                totalCal: totalCal,
                calorieGoal: calorieGoal,
                protein: totalProtein,
                proteinGoal: proteinGoal,
                carbs: totalCarbs,
                carbGoal: carbGoal,
                fat: totalFat,
                fatGoal: fatGoal,
                isDark: isDark,
              ).animate().fadeIn(delay: 60.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // ── Macro ring summary ───────────────────────────────────────
              _MacroRingSummary(
                totalCal: totalCal,
                calorieGoal: calorieGoal,
                protein: totalProtein,
                proteinGoal: proteinGoal,
                carbs: totalCarbs,
                fat: totalFat,
                isDark: isDark,
              ).animate().fadeIn(delay: 80.ms, duration: 400.ms),

              const SizedBox(height: 20),

              // ── Macro breakdown chips ────────────────────────────────────
              _MacroChips(
                protein: totalProtein,
                carbs: totalCarbs,
                fat: totalFat,
                isDark: isDark,
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 24),

              // ── AI Daily Insight card ────────────────────────────────────
              _DailyInsightCard(date: _midnight, isDark: isDark)
                  .animate()
                  .fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // ── AI Meal Planner entry ────────────────────────────────────
              _MealPlannerEntryCard(isDark: isDark)
                  .animate()
                  .fadeIn(delay: 220.ms),

              const SizedBox(height: 24),

              // ── Meal type pill tab bar ───────────────────────────────────
              AppPillTabBar(
                tabs: const ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack'],
                selectedIndex: _selectedMealTab,
                onChanged: (i) => setState(() => _selectedMealTab = i),
                activeColor: AppColors.dynamicMint,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),

              const SizedBox(height: 16),

              // ── Meals by type ────────────────────────────────────────────
              ..._mealTypes.where((type) {
                if (_selectedMealTab == 0) return true;
                return type == _mealTypes[_selectedMealTab - 1];
              }).map((type) {
                final typeMeals =
                    meals.where((m) => m.mealType == type).toList();
                return _MealSection(
                  type: type,
                  meals: typeMeals,
                  isDark: isDark,
                  onAdd: () =>
                      _showAddMealSheet(context, isDark, notifier,
                          preselectedType: type),
                  onDelete: (id) => notifier.remove(id),
                );
              }),

              const SizedBox(height: 24),

                // ── Quick add section ────────────────────────────────────────
                _QuickAddSection(
                  isDark: isDark,
                  onQuickAdd: (name, type, cal, protein, carbs, fat) =>
                      notifier.add(
                    name: name,
                    mealType: type,
                    calories: cal,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),

                // ── Weekly nutrition insights ────────────────────────────────
                _WeeklyNutritionInsightCard(isDark: isDark)
                    .animate()
                    .fadeIn(delay: 400.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMealSheet(
    BuildContext context,
    bool isDark,
    MealsNotifier notifier, {
    String? preselectedType,
  }) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMealSheet(
        isDark: isDark,
        preselectedType: preselectedType ?? 'Breakfast',
        onAdd: ({
          required String name,
          required String type,
          required int cal,
          required int protein,
          required int carbs,
          required int fat,
        }) async {
          await notifier.add(
            name: name,
            mealType: type,
            calories: cal,
            protein: protein,
            carbs: carbs,
            fat: fat,
          );
        },
      ),
    );
  }
}

// ── Date Navigator ────────────────────────────────────────────────────────────
class _DateNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isDark;

  const _DateNavigator({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavBtn(icon: PhosphorIconsRegular.caretLeft, onTap: onPrev, isDark: isDark),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ),
          _NavBtn(icon: PhosphorIconsRegular.caretRight, onTap: onNext, isDark: isDark),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _NavBtn({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      pressScale: 0.9,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            size: 18,
            color: isDark ? Colors.white70 : AppColors.lightTextSecondary),
      ),
    );
  }
}

// ── Daily Macro Progress Bar ──────────────────────────────────────────────────
class _DailyMacroBar extends StatelessWidget {
  final int totalCal;
  final int calorieGoal;
  final int protein;
  final int proteinGoal;
  final int carbs;
  final int carbGoal;
  final int fat;
  final int fatGoal;
  final bool isDark;

  const _DailyMacroBar({
    required this.totalCal,
    required this.calorieGoal,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbGoal,
    required this.fat,
    required this.fatGoal,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _MacroProgressRow(
              label: 'Calories',
              current: totalCal,
              goal: calorieGoal,
              unit: 'kcal',
              color: AppColors.dynamicMint,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _MacroProgressRow(
              label: 'Protein',
              current: protein,
              goal: proteinGoal,
              unit: 'g',
              color: AppColors.danger,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _MacroProgressRow(
              label: 'Carbs',
              current: carbs,
              goal: carbGoal,
              unit: 'g',
              color: AppColors.warning,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _MacroProgressRow(
              label: 'Fat',
              current: fat,
              goal: fatGoal,
              unit: 'g',
              color: AppColors.softIndigo,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroProgressRow extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final String unit;
  final Color color;
  final bool isDark;

  const _MacroProgressRow({
    required this.label,
    required this.current,
    required this.goal,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final over = current > goal;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Stack(
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.12 : 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: over ? AppColors.warning : color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: (over ? AppColors.warning : color)
                              .withValues(alpha: 0.35),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            '$current / $goal$unit',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: over ? AppColors.warning : color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Macro Ring Summary ────────────────────────────────────────────────────────
class _MacroRingSummary extends StatelessWidget {
  final int totalCal;
  final int calorieGoal;
  final int protein;
  final int proteinGoal;
  final int carbs;
  final int fat;
  final bool isDark;

  const _MacroRingSummary({
    required this.totalCal,
    required this.calorieGoal,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.fat,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (totalCal / calorieGoal).clamp(0.0, 1.0);
    final remaining = (calorieGoal - totalCal).clamp(0, calorieGoal);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFFEEF2FF), const Color(0xFFE8F5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.2 : 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dynamicMint.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular progress
            SizedBox(
              width: 90,
              height: 90,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: 1200.ms,
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => CustomPaint(
                  painter: _RingPainter(
                    progress: v,
                    color: AppColors.dynamicMint,
                    bgColor: AppColors.dynamicMint.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(v * 100).round()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'of goal',
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark
                                ? Colors.white38
                                : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCountUpText(
                      value: totalCal.toDouble(),
                      formatter: (v) => v.round().toString(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: AppColors.dynamicMint,
                      ),
                    ),
                    Text(
                      'of $calorieGoal kcal goal',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (remaining == 0
                              ? AppColors.warning
                              : AppColors.dynamicMint)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      remaining > 0
                          ? '$remaining kcal remaining'
                          : 'Goal reached!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: remaining > 0
                            ? AppColors.dynamicMint
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,
        2 * 3.14159 * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Macro Chips ───────────────────────────────────────────────────────────────
class _MacroChips extends StatelessWidget {
  final int protein;
  final int carbs;
  final int fat;
  final bool isDark;

  const _MacroChips({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _MacroChip(
              label: 'Protein',
              value: '${protein}g',
              color: AppColors.danger,
              isDark: isDark),
          const SizedBox(width: 10),
          _MacroChip(
              label: 'Carbs',
              value: '${carbs}g',
              color: AppColors.warning,
              isDark: isDark),
          const SizedBox(width: 10),
          _MacroChip(
              label: 'Fat',
              value: '${fat}g',
              color: AppColors.softIndigo,
              isDark: isDark),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Meal Section ──────────────────────────────────────────────────────────────
class _MealSection extends StatelessWidget {
  final String type;
  final List<MealDoc> meals;
  final bool isDark;
  final VoidCallback onAdd;
  final void Function(int id) onDelete;

  const _MealSection({
    required this.type,
    required this.meals,
    required this.isDark,
    required this.onAdd,
    required this.onDelete,
  });

  IconData get _icon {
    switch (type) {
      case 'Breakfast': return PhosphorIconsFill.coffee;
      case 'Lunch':     return PhosphorIconsFill.sun;
      case 'Dinner':    return PhosphorIconsFill.moon;
      default:          return PhosphorIconsFill.cookingPot;
    }
  }

  Color get _color {
    switch (type) {
      case 'Breakfast': return const Color(0xFFF59E0B);
      case 'Lunch':     return AppColors.dynamicMint;
      case 'Dinner':    return AppColors.softIndigo;
      default:          return AppColors.danger;
    }
  }

  int get _totalCal =>
      meals.fold(0, (s, m) => s + m.calories);

  int get _totalProtein =>
      meals.fold(0, (s, m) => s + m.proteinGrams);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon, color: _color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            )),
                          if (_totalCal > 0)
                            Text(
                              '$_totalCal kcal  ·  ${_totalProtein}g protein',
                              style: TextStyle(
                                fontSize: 11,
                                color: _color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ],
                    ),
                  ),
                  AppAnimatedPressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onAdd();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(PhosphorIconsFill.plus,
                          color: _color, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Meal rows
            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Text(
                  'No meals logged yet',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                ),
              )
            else
              ...meals.map((m) => _MealRow(
                    meal: m,
                    isDark: isDark,
                    accentColor: _color,
                    onDelete: () => onDelete(m.id),
                  )),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final MealDoc meal;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onDelete;

  const _MealRow({
    required this.meal,
    required this.isDark,
    required this.accentColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('meal_${meal.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(PhosphorIconsFill.trash,
            color: AppColors.danger, size: 20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${meal.proteinGrams}g P  •  ${meal.carbsGrams}g C  •  ${meal.fatGrams}g F',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${meal.calories} kcal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Add Section ─────────────────────────────────────────────────────────
class _QuickAddSection extends StatelessWidget {
  final bool isDark;
  final void Function(
    String name,
    String type,
    int cal,
    int protein,
    int carbs,
    int fat,
  ) onQuickAdd;

  const _QuickAddSection({required this.isDark, required this.onQuickAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'Quick Add',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _quickFoods.length,
            itemBuilder: (_, i) {
              final (name, type, cal, protein, carbs, fat) =
                  _quickFoods[i];
                return AppAnimatedPressable(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onQuickAdd(name, type, cal, protein, carbs, fat);
                  },
                  child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.charcoalGlass : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.lightTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(PhosphorIconsFill.plus,
                              color: AppColors.dynamicMint, size: 14),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$cal kcal',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dynamicMint,
                            ),
                          ),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: 40 * i))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, end: 0, duration: 300.ms);
            },
          ),
        ),
      ],
    );
  }
}

// ── Add Meal Bottom Sheet ─────────────────────────────────────────────────────
class _AddMealSheet extends StatefulWidget {
  final bool isDark;
  final String preselectedType;
  final Future<void> Function({
    required String name,
    required String type,
    required int cal,
    required int protein,
    required int carbs,
    required int fat,
  }) onAdd;

  const _AddMealSheet({
    required this.isDark,
    required this.preselectedType,
    required this.onAdd,
  });

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  late String _selectedType;
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preselectedType;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final cal = int.tryParse(_calCtrl.text) ?? 0;
    final protein = int.tryParse(_proteinCtrl.text) ?? 0;
    final carbs = int.tryParse(_carbsCtrl.text) ?? 0;
    final fat = int.tryParse(_fatCtrl.text) ?? 0;
    setState(() => _saving = true);
    await widget.onAdd(
      name: name,
      type: _selectedType,
      cal: cal,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.07 : 0)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Log Meal',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary)),

                const SizedBox(height: 16),

                // Meal type chips
                Wrap(
                  spacing: 8,
                  children: _mealTypes.map((type) {
                    final selected = type == _selectedType;
                      return AppAnimatedPressable(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedType = type);
                        },
                        pressScale: 0.93,
                        child: AnimatedContainer(
                        duration: 200.ms,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.dynamicMint
                              : AppColors.dynamicMint.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.dynamicMint
                                : AppColors.dynamicMint.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : AppColors.dynamicMint,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Name field
                _Field(
                  controller: _nameCtrl,
                  label: 'Food Name',
                  icon: PhosphorIconsRegular.forkKnife,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                // Calories + macros
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _calCtrl,
                        label: 'Calories',
                        icon: PhosphorIconsRegular.fire,
                        isDark: isDark,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Field(
                        controller: _proteinCtrl,
                        label: 'Protein (g)',
                        icon: PhosphorIconsRegular.egg,
                        isDark: isDark,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _carbsCtrl,
                        label: 'Carbs (g)',
                        icon: PhosphorIconsRegular.bread,
                        isDark: isDark,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Field(
                        controller: _fatCtrl,
                        label: 'Fat (g)',
                        icon: PhosphorIconsRegular.drop,
                        isDark: isDark,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dynamicMint,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Log Meal',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isNumber;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(
          color: isDark ? Colors.white : AppColors.lightTextPrimary,
          fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black45),
        prefixIcon: Icon(icon, size: 16, color: AppColors.dynamicMint),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.cloudGray,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: AppColors.dynamicMint.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.dynamicMint, width: 1.5),
        ),
      ),
    );
  }
}

// ── Daily AI Insight Card ─────────────────────────────────────────────────────

class _DailyInsightCard extends ConsumerWidget {
  final DateTime date;
  final bool isDark;

  const _DailyInsightCard({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(nutritionAnalysisProvider(date));
    final meals = ref.watch(mealsForDateProvider(date));

    // No meals — no card
    if (meals.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: insightAsync.when(
        loading: () => _InsightLoadingCard(isDark: isDark),
        error: (_, __) => const SizedBox.shrink(),
        data: (insight) {
          if (insight == null) return const SizedBox.shrink();
          return _InsightDataCard(insight: insight, isDark: isDark);
        },
      ),
    );
  }
}

class _InsightLoadingCard extends StatelessWidget {
  final bool isDark;
  const _InsightLoadingCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.softIndigo.withValues(alpha: isDark ? 0.2 : 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softIndigo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.softIndigo),
            ),
          ),
          const SizedBox(width: 12),
          Text('Analysing today\'s nutrition...',
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black45)),
        ],
      ),
    );
  }
}

class _InsightDataCard extends StatelessWidget {
  final NutritionInsight insight;
  final bool isDark;

  const _InsightDataCard(
      {required this.insight, required this.isDark});

  Color get _gradeColor {
    switch (insight.grade) {
      case 'A': return AppColors.dynamicMint;
      case 'B': return const Color(0xFF4CAF50);
      case 'C': return AppColors.warning;
      case 'D': return const Color(0xFFFF7043);
      default:  return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final highAlerts =
        insight.alerts.where((a) => a.severity == 'high').toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _gradeColor.withValues(alpha: isDark ? 0.25 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: _gradeColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _gradeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      insight.grade,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _gradeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('TODAY\'S SCORE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: _gradeColor.withValues(alpha: 0.8),
                              )),
                          const Spacer(),
                          Text('${insight.score}/100',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _gradeColor,
                              )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: insight.score / 100),
                          duration: 900.ms,
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => LinearProgressIndicator(
                            value: v,
                            minHeight: 6,
                            backgroundColor: _gradeColor.withValues(alpha: 0.12),
                            valueColor:
                                AlwaysStoppedAnimation(_gradeColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Summary
          if (insight.summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                insight.summary,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.4,
                ),
              ),
            ),

          // High-severity alerts
          if (highAlerts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Column(
                children: highAlerts
                    .take(2)
                    .map((a) => _AlertChip(alert: a, isDark: isDark))
                    .toList(),
              ),
            ),

          // Top suggestion
          if (insight.suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dynamicMint.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.dynamicMint.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsFill.lightbulb,
                        color: AppColors.dynamicMint, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.suggestions.first,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertChip extends StatelessWidget {
  final NutritionAlert alert;
  final bool isDark;

  const _AlertChip({required this.alert, required this.isDark});

  Color get _alertColor {
    switch (alert.type) {
      case 'deficiency': return AppColors.warning;
      case 'excess': return AppColors.danger;
      default: return AppColors.softIndigo;
    }
  }

  IconData get _alertIcon {
    switch (alert.type) {
      case 'deficiency': return PhosphorIconsFill.arrowDown;
      case 'excess': return PhosphorIconsFill.arrowUp;
      default: return PhosphorIconsFill.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _alertColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(_alertIcon, size: 12, color: _alertColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.message,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meal Planner Entry Card ────────────────────────────────────────────────────

class _MealPlannerEntryCard extends ConsumerWidget {
  final bool isDark;
  const _MealPlannerEntryCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planState = ref.watch(mealPlanNotifierProvider);
    final hasActivePlan = planState.activePlan != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppAnimatedPressable(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/meal-planner');
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0E1A2E), const Color(0xFF0A1224)]
                  : [const Color(0xFFEEF2FF), const Color(0xFFE3EAFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.softIndigo.withValues(alpha: isDark ? 0.25 : 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.softIndigo.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softIndigo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(PhosphorIconsFill.calendarDots,
                    color: AppColors.softIndigo, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasActivePlan ? 'View Your Meal Plan' : 'AI Meal Planner',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasActivePlan
                          ? '${planState.activePlan!.durationDays}-day plan active  ·  ${planState.activePlan!.avgDailyCalories} kcal/day'
                          : 'Generate a personalised meal plan',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.softIndigo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasActivePlan
                          ? PhosphorIconsRegular.arrowRight
                          : PhosphorIconsFill.sparkle,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasActivePlan ? 'View' : 'Create',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Weekly Nutrition Insight Card ─────────────────────────────────────────────

class _WeeklyNutritionInsightCard extends ConsumerWidget {
  final bool isDark;
  const _WeeklyNutritionInsightCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(weeklyNutritionInsightProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0E1F1A), const Color(0xFF0A1A16)]
                : [const Color(0xFFE8FBF4), const Color(0xFFD6F5E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.25 : 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dynamicMint.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: insightAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.dynamicMint,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly AI Insights',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Analyzing your week...',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38)),
                  ],
                ),
              ],
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(PhosphorIconsFill.lightbulb,
                      color: AppColors.dynamicMint, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Log meals for a few days to see your weekly AI nutrition summary.',
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          data: (insight) {
            if (insight == null) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.dynamicMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(PhosphorIconsFill.lightbulb,
                          color: AppColors.dynamicMint, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Log meals throughout the week to unlock AI nutrition insights.',
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.dynamicMint.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(PhosphorIconsFill.lightbulb,
                            color: AppColors.dynamicMint, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WEEKLY INSIGHTS',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: AppColors.dynamicMint.withValues(alpha: 0.8))),
                            const Text('AI Nutrition Analysis',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      AppAnimatedPressable(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(weeklyNutritionInsightProvider.notifier).refresh();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.dynamicMint.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(PhosphorIconsRegular.arrowsClockwise,
                              color: AppColors.dynamicMint, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _StatPill(
                          label: 'Avg Cal',
                          value: '${insight.avgCalories.round()}',
                          unit: 'kcal',
                          color: AppColors.softIndigo),
                      const SizedBox(width: 8),
                      _StatPill(
                          label: 'Avg Protein',
                          value: '${insight.avgProtein.round()}',
                          unit: 'g',
                          color: AppColors.dynamicMint),
                      const SizedBox(width: 8),
                      _StatPill(
                          label: 'Avg Carbs',
                          value: '${insight.avgCarbs.round()}',
                          unit: 'g',
                          color: AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    insight.summary,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...insight.suggestions.take(3).map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 5, right: 8),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.dynamicMint),
                            ),
                            Expanded(
                              child: Text(s,
                                  style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _StatPill(
      {required this.label,
      required this.value,
      required this.unit,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value $unit',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}
