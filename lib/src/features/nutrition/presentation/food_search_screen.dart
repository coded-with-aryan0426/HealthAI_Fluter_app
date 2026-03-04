import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../application/meal_provider.dart';
import '../../../services/open_food_facts_service.dart';
import '../../../services/ai_service.dart';

// ── Search result model ────────────────────────────────────────────────────────

class _FoodResult {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String? brand;
  final String? imageUrl;
  final String source; // 'barcode' | 'off' | 'ai'

  const _FoodResult({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.brand,
    this.imageUrl,
    required this.source,
  });
}

// ── Provider: OpenFoodFacts text search ────────────────────────────────────────

final _offSearchProvider =
    FutureProvider.autoDispose.family<List<_FoodResult>, String>(
  (ref, query) async {
    if (query.trim().length < 2) return [];
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl'
        '?search_terms=${Uri.encodeComponent(query)}'
        '&search_simple=1&action=process&json=1&page_size=20',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'HealthAI-Flutter/1.0 (contact@healthai.app)',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final products = (body['products'] as List<dynamic>? ?? []);

      final results = <_FoodResult>[];
      for (final p in products) {
        final product = p as Map<String, dynamic>;
        final name = (product['product_name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final brand = (product['brands'] as String?)?.trim();
        final imageUrl = product['image_front_thumb_url'] as String?;
        final nutriments =
            product['nutriments'] as Map<String, dynamic>? ?? {};

        int _toInt(dynamic v) => v == null ? 0 : (v as num).round();

        final cal = _toInt(
            nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal']);
        final protein = _toInt(
            nutriments['proteins_100g'] ?? nutriments['proteins']);
        final carbs = _toInt(
            nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates']);
        final fat = _toInt(nutriments['fat_100g'] ?? nutriments['fat']);

        if (cal == 0 && protein == 0 && carbs == 0 && fat == 0) continue;

        results.add(_FoodResult(
          name: brand != null ? '$name ($brand)' : name,
          calories: cal,
          protein: protein,
          carbs: carbs,
          fat: fat,
          brand: brand,
          imageUrl: imageUrl,
          source: 'off',
        ));
      }
      return results;
    } catch (_) {
      return [];
    }
  },
);

// ── Provider: AI food estimate ─────────────────────────────────────────────────

final _aiEstimateProvider =
    FutureProvider.autoDispose.family<_FoodResult?, String>(
  (ref, query) async {
    if (query.trim().length < 3) return null;
    try {
      final ai = ref.read(aiServiceProvider);
      final prompt =
          'Estimate the nutritional info per 100g serving for: "$query".\n'
          'Return ONLY valid JSON (no markdown): '
          '{"name":"<name>","calories":<int>,"protein":<int>,"carbs":<int>,"fat":<int>}';
      final raw = await ai.sendMessage(prompt);
      if (raw == null || raw.startsWith('__')) return null;
      final cleaned =
          raw.replaceAll('```json', '').replaceAll('```', '').trim();
      final s = cleaned.indexOf('{');
      final e = cleaned.lastIndexOf('}');
      if (s == -1 || e == -1) return null;
      final json =
          jsonDecode(cleaned.substring(s, e + 1)) as Map<String, dynamic>;
      return _FoodResult(
        name: json['name'] as String? ?? query,
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        protein: (json['protein'] as num?)?.toInt() ?? 0,
        carbs: (json['carbs'] as num?)?.toInt() ?? 0,
        fat: (json['fat'] as num?)?.toInt() ?? 0,
        source: 'ai',
      );
    } catch (_) {
      return null;
    }
  },
);

// ── Screen ─────────────────────────────────────────────────────────────────────

class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  String _selectedType = 'Breakfast';

  static const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onSearch(String q) => setState(() => _query = q.trim());

  Future<void> _logFood(_FoodResult food, {double portion = 1.0}) async {
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);
    await ref.read(mealsForDateProvider(midnight).notifier).add(
          name: food.name,
          mealType: _selectedType,
          calories: (food.calories * portion).round(),
          protein: (food.protein * portion).round(),
          carbs: (food.carbs * portion).round(),
          fat: (food.fat * portion).round(),
        );
    if (mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food.name} added to $_selectedType'),
          backgroundColor: AppColors.dynamicMint,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.deepObsidian : const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/nutrition-tab'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.charcoalCard
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _focus.hasFocus
                              ? AppColors.dynamicMint
                              : isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.08),
                          width: _focus.hasFocus ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dynamicMint.withValues(
                                alpha: _focus.hasFocus ? 0.08 : 0),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        onChanged: _onSearch,
                        onSubmitted: _onSearch,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search food or scan barcode...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass,
                              color: AppColors.dynamicMint, size: 18),
                          suffixIcon: _ctrl.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    _onSearch('');
                                  },
                                  child: Icon(PhosphorIconsRegular.x,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                      size: 16),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Barcode scan button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/scanner');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dynamicMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.dynamicMint.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(PhosphorIconsFill.barcode,
                          color: AppColors.dynamicMint, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Meal type selector ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _mealTypes
                      .map((t) => _TypeChip(
                            label: t,
                            selected: t == _selectedType,
                            onTap: () => setState(() => _selectedType = t),
                          ))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Results ───────────────────────────────────────────────────────
            Expanded(
              child: _query.isEmpty
                  ? _EmptyState(isDark: isDark)
                  : _SearchResults(
                      query: _query,
                      isDark: isDark,
                      onLog: _logFood,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Type chip ──────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      pressScale: 0.93,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.dynamicMint
              : AppColors.dynamicMint.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.dynamicMint
                : AppColors.dynamicMint.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : AppColors.dynamicMint,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.dynamicMint.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(PhosphorIconsFill.magnifyingGlass,
                color: AppColors.dynamicMint, size: 36),
          ),
          const SizedBox(height: 16),
          Text('Search for any food',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              )),
          const SizedBox(height: 8),
          Text(
            'Type a food name to search OpenFoodFacts\nor tap the barcode icon to scan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── Search results ─────────────────────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  final String query;
  final bool isDark;
  final Future<void> Function(_FoodResult food, {double portion}) onLog;

  const _SearchResults({
    required this.query,
    required this.isDark,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offAsync = ref.watch(_offSearchProvider(query));
    final aiAsync = ref.watch(_aiEstimateProvider(query));

    return CustomScrollView(
      slivers: [
        // ── OpenFoodFacts results ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: offAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.dynamicMint),
                  ),
                  const SizedBox(width: 12),
                  Text('Searching OpenFoodFacts...',
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45)),
                ],
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (results) {
              if (results.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                      label: 'FOOD DATABASE', isDark: isDark),
                  ...results.asMap().entries.map(
                        (e) => _FoodResultCard(
                          result: e.value,
                          isDark: isDark,
                          onLog: onLog,
                          delay: e.key * 30,
                        ),
                      ),
                ],
              );
            },
          ),
        ),

        // ── AI estimate ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: aiAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.softIndigo),
                  ),
                  const SizedBox(width: 10),
                  Text('Getting AI estimate...',
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38)),
                ],
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (result) {
              if (result == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: 'AI ESTIMATE', isDark: isDark),
                  _FoodResultCard(
                    result: result,
                    isDark: isDark,
                    onLog: onLog,
                    delay: 0,
                    isAi: true,
                  ),
                ],
              );
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.dynamicMint.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

// ── Food result card ───────────────────────────────────────────────────────────

class _FoodResultCard extends StatelessWidget {
  final _FoodResult result;
  final bool isDark;
  final Future<void> Function(_FoodResult, {double portion}) onLog;
  final int delay;
  final bool isAi;

  const _FoodResultCard({
    required this.result,
    required this.isDark,
    required this.onLog,
    required this.delay,
    this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isAi ? AppColors.softIndigo : AppColors.dynamicMint;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Image or placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: result.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          result.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            PhosphorIconsFill.cookingPot,
                            color: accentColor,
                            size: 22,
                          ),
                        ),
                      )
                    : Icon(
                        isAi
                            ? PhosphorIconsFill.sparkle
                            : PhosphorIconsFill.cookingPot,
                        color: accentColor,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 12),

              // Name + macros
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isAi)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.softIndigo.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('AI',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.softIndigo,
                                  letterSpacing: 0.5,
                                )),
                          ),
                        Expanded(
                          child: Text(
                            result.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.protein}g P  ·  ${result.carbs}g C  ·  ${result.fat}g F  ·  per 100g',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Calories + log button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${result.calories}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      )),
                  Text('kcal',
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? Colors.white38 : Colors.black38,
                      )),
                  const SizedBox(height: 6),
                  AppAnimatedPressable(
                    onTap: () => _showPortionSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Text('+ Log',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.04);
  }

  void _showPortionSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double portion = 1.0; // 1.0 = 100g

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoalCard : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    )),
                const SizedBox(height: 4),
                Text('Per 100g base',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38)),
                const SizedBox(height: 20),

                // Portion slider
                Row(
                  children: [
                    Text('Portion: ',
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black54)),
                    Text('${(portion * 100).round()}g',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dynamicMint)),
                  ],
                ),
                Slider(
                  value: portion,
                  min: 0.25,
                  max: 5.0,
                  divisions: 19,
                  activeColor: AppColors.dynamicMint,
                  inactiveColor: AppColors.dynamicMint.withValues(alpha: 0.2),
                  onChanged: (v) => setSheetState(() => portion = v),
                ),

                // Macro preview
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.dynamicMint.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MacroPreview(
                          label: 'Calories',
                          value: '${(result.calories * portion).round()}',
                          unit: 'kcal'),
                      _MacroPreview(
                          label: 'Protein',
                          value: '${(result.protein * portion).round()}g',
                          unit: ''),
                      _MacroPreview(
                          label: 'Carbs',
                          value: '${(result.carbs * portion).round()}g',
                          unit: ''),
                      _MacroPreview(
                          label: 'Fat',
                          value: '${(result.fat * portion).round()}g',
                          unit: ''),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onLog(result, portion: portion);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dynamicMint,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Log Food',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
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

class _MacroPreview extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MacroPreview(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value$unit',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.dynamicMint,
            )),
        Text(label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
