import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../database/models/meal_doc.dart';
import '../../../../services/local_db_service.dart';

/// Nutrition confirmation card rendered when the AI analyzes a food image.
/// The [scanJson] is the raw JSON string returned by [AIService.analyzeFoodImage].
///
/// Supports both single-item and multi-item formats:
///   Single: {"name":"Oats","calories":300,"protein":10,"carbs":54,"fat":5,"portion":"medium bowl","confidence":"high"}
///   Multi:  {"items":[...],"total":{...},"portion":"...","confidence":"..."}
class FoodScanCard extends ConsumerStatefulWidget {
  final String scanJson;

  const FoodScanCard({super.key, required this.scanJson});

  @override
  ConsumerState<FoodScanCard> createState() => _FoodScanCardState();
}

class _FoodScanCardState extends ConsumerState<FoodScanCard> {
  _ParsedScan? _scan;
  bool _parseError = false;
  String _selectedMealType = 'snack';
  bool _saved = false;
  bool _saving = false;

  static const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void initState() {
    super.initState();
    _parse();
  }

  void _parse() {
    try {
      // Strip markdown code fences if present
      var raw = widget.scanJson.trim();
      raw = raw.replaceAll(RegExp(r'^```[a-z]*\n?', multiLine: false), '');
      raw = raw.replaceAll('```', '').trim();

      final Map<String, dynamic> json = jsonDecode(raw);

      // Auto-select meal type based on hour
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 10) {
        _selectedMealType = 'breakfast';
      } else if (hour >= 11 && hour < 15) {
        _selectedMealType = 'lunch';
      } else if (hour >= 17 && hour < 21) {
        _selectedMealType = 'dinner';
      } else {
        _selectedMealType = 'snack';
      }

      if (json.containsKey('items')) {
        // Multi-item format
        final items = (json['items'] as List)
            .map((e) => _FoodItem.fromJson(e as Map<String, dynamic>))
            .toList();
        final total = json['total'] as Map<String, dynamic>? ?? {};
        _scan = _ParsedScan(
          name: items.map((i) => i.name).join(' + '),
          items: items,
          totalCalories: (total['calories'] as num?)?.toInt() ??
              items.fold(0, (s, i) => s + i.calories),
          totalProtein: (total['protein'] as num?)?.toInt() ??
              items.fold(0, (s, i) => s + i.protein),
          totalCarbs: (total['carbs'] as num?)?.toInt() ??
              items.fold(0, (s, i) => s + i.carbs),
          totalFat: (total['fat'] as num?)?.toInt() ??
              items.fold(0, (s, i) => s + i.fat),
          portion: json['portion'] as String? ?? '',
          confidence: json['confidence'] as String? ?? 'moderate',
        );
      } else {
        // Single-item format
        _scan = _ParsedScan(
          name: json['name'] as String? ?? 'Unknown food',
          items: [],
          totalCalories: (json['calories'] as num?)?.toInt() ?? 0,
          totalProtein: (json['protein'] as num?)?.toInt() ?? 0,
          totalCarbs: (json['carbs'] as num?)?.toInt() ?? 0,
          totalFat: (json['fat'] as num?)?.toInt() ?? 0,
          portion: json['portion'] as String? ?? '',
          confidence: json['confidence'] as String? ?? 'moderate',
        );
      }
    } catch (_) {
      setState(() => _parseError = true);
    }
  }

  Future<void> _logMeal() async {
    if (_scan == null || _saved) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final meal = MealDoc()
      ..dateLogged = DateTime.now()
      ..mealType = _selectedMealType
      ..name = _scan!.name
      ..calories = _scan!.totalCalories
      ..proteinGrams = _scan!.totalProtein
      ..carbsGrams = _scan!.totalCarbs
      ..fatGrams = _scan!.totalFat
      ..aiGenerated = true
      ..source = 'scan';

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async => isar.mealDocs.put(meal));

    setState(() {
      _saved = true;
      _saving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_scan!.name} logged to $_selectedMealType'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.dynamicMint.withValues(alpha: 0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF14172A) : Colors.white;
    final borderColor = AppColors.dynamicMint.withValues(alpha: 0.35);

    if (_parseError || _scan == null) {
      return _ErrorTile(isDark: isDark);
    }

    final scan = _scan!;
    final confidenceColor = scan.confidence == 'high'
        ? AppColors.dynamicMint
        : scan.confidence == 'moderate'
            ? Colors.amber
            : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.dynamicMint.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.dynamicMint.withValues(alpha: isDark ? 0.18 : 0.1),
                    AppColors.softIndigo.withValues(alpha: isDark ? 0.14 : 0.06),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.dynamicMint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(PhosphorIconsFill.forkKnife,
                        color: AppColors.dynamicMint, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (scan.portion.isNotEmpty)
                          Text(
                            scan.portion,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Confidence badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: confidenceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: confidenceColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      scan.confidence,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: confidenceColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Macros row ─────────────────────────────────────────────
                  Row(
                    children: [
                      _MacroChip(
                        label: 'Cal',
                        value: '${scan.totalCalories}',
                        unit: 'kcal',
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _MacroChip(
                        label: 'Pro',
                        value: '${scan.totalProtein}',
                        unit: 'g',
                        color: Colors.redAccent,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _MacroChip(
                        label: 'Carb',
                        value: '${scan.totalCarbs}',
                        unit: 'g',
                        color: Colors.amber,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _MacroChip(
                        label: 'Fat',
                        value: '${scan.totalFat}',
                        unit: 'g',
                        color: AppColors.softIndigo,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  // ── Per-item breakdown (multi-item) ────────────────────────
                  if (scan.items.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'BREAKDOWN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...scan.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.dynamicMint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : Colors.black.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                              Text(
                                '${item.calories} kcal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  const SizedBox(height: 16),

                  // ── Meal type selector ─────────────────────────────────────
                  if (!_saved) ...[
                    Text(
                      'LOG AS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _mealTypes.map((type) {
                        final isSelected = _selectedMealType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedMealType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors.softIndigo,
                                          AppColors.dynamicMint
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.black.withValues(alpha: 0.05)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.1)),
                                ),
                              ),
                              child: Text(
                                type[0].toUpperCase() + type.substring(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // ── Log button ─────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _logMeal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.dynamicMint,
                                AppColors.softIndigo,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.dynamicMint.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(PhosphorIconsFill.checkCircle,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'Log Meal',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // ── Saved confirmation ─────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.dynamicMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.dynamicMint.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(PhosphorIconsFill.checkCircle,
                              color: AppColors.dynamicMint, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Meal Logged',
                            style: TextStyle(
                              color: AppColors.dynamicMint,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(
                          begin: const Offset(0.92, 0.92),
                          duration: 300.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(
          begin: 0.06,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _ParsedScan {
  final String name;
  final List<_FoodItem> items;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final String portion;
  final String confidence;

  const _ParsedScan({
    required this.name,
    required this.items,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.portion,
    required this.confidence,
  });
}

class _FoodItem {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const _FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory _FoodItem.fromJson(Map<String, dynamic> j) => _FoodItem(
        name: j['name'] as String? ?? 'Item',
        calories: (j['calories'] as num?)?.toInt() ?? 0,
        protein: (j['protein'] as num?)?.toInt() ?? 0,
        carbs: (j['carbs'] as num?)?.toInt() ?? 0,
        fat: (j['fat'] as num?)?.toInt() ?? 0,
      );
}

// ── Macro chip ────────────────────────────────────────────────────────────────

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isDark;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.grey.shade600
                    : Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error tile ────────────────────────────────────────────────────────────────

class _ErrorTile extends StatelessWidget {
  final bool isDark;
  const _ErrorTile({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Colors.redAccent.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.warning,
              color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not analyse this image. Try a clearer photo.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.75)
                    : Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
