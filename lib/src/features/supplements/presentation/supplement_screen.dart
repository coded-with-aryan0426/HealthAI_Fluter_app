import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../application/supplement_provider.dart';
import '../../../database/models/supplement_doc.dart';

// ── Constants ─────────────────────────────────────────────────────────────────
const _kUnits = ['mg', 'g', 'IU', 'mcg', 'ml', 'capsule', 'tablet'];

const _kTimingOptions = [
  ('morning',      'Morning'),
  ('with_meal',    'With Meal'),
  ('pre_workout',  'Pre-Workout'),
  ('post_workout', 'Post-Workout'),
  ('evening',      'Evening'),
  ('bedtime',      'Bedtime'),
];

/// Canonical display order for time-of-day groups
const _kGroupOrder = [
  'morning',
  'with_meal',
  'pre_workout',
  'post_workout',
  'evening',
  'bedtime',
];

const _kGroupLabels = {
  'morning':      'Morning',
  'with_meal':    'With Meal',
  'pre_workout':  'Pre-Workout',
  'post_workout': 'Post-Workout',
  'evening':      'Evening',
  'bedtime':      'Bedtime',
  '_other':       'Other',
};

const _kSupplementColors = [
  Color(0xFF6366F1),
  Color(0xFF00C9A7),
  Color(0xFFFF9F43),
  Color(0xFFFF4B4B),
  Color(0xFF845EC2),
  Color(0xFF00B4D8),
  Color(0xFF2ECC71),
  Color(0xFFE91E8C),
];

// ── Preset Packs ──────────────────────────────────────────────────────────────
class _PresetSupplement {
  final String name;
  final double dosage;
  final String unit;
  final List<String> timing;
  final String iconName;
  final int colorValue;

  const _PresetSupplement({
    required this.name,
    required this.dosage,
    required this.unit,
    required this.timing,
    required this.iconName,
    required this.colorValue,
  });
}

class _PresetPack {
  final String emoji;
  final String title;
  final String subtitle;
  final List<_PresetSupplement> supplements;

  const _PresetPack({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.supplements,
  });
}

const _kPresetPacks = [
  _PresetPack(
    emoji: '🌱',
    title: 'Beginner Health Stack',
    subtitle: 'Vitamin D · Omega 3 · Magnesium',
    supplements: [
      _PresetSupplement(name: 'Vitamin D3', dosage: 1000, unit: 'IU',
          timing: ['morning'], iconName: 'sun', colorValue: 0xFFFF9F43),
      _PresetSupplement(name: 'Omega 3', dosage: 1000, unit: 'mg',
          timing: ['with_meal'], iconName: 'drop', colorValue: 0xFF00B4D8),
      _PresetSupplement(name: 'Magnesium', dosage: 400, unit: 'mg',
          timing: ['bedtime'], iconName: 'moon', colorValue: 0xFF845EC2),
    ],
  ),
  _PresetPack(
    emoji: '💪',
    title: 'Athlete Stack',
    subtitle: 'Creatine · BCAA · Zinc · Protein',
    supplements: [
      _PresetSupplement(name: 'Creatine', dosage: 5000, unit: 'mg',
          timing: ['pre_workout'], iconName: 'fire', colorValue: 0xFFFF4B4B),
      _PresetSupplement(name: 'BCAA', dosage: 5, unit: 'g',
          timing: ['pre_workout', 'post_workout'], iconName: 'heart', colorValue: 0xFFE91E8C),
      _PresetSupplement(name: 'Zinc', dosage: 15, unit: 'mg',
          timing: ['morning'], iconName: 'leaf', colorValue: 0xFF2ECC71),
      _PresetSupplement(name: 'Whey Protein', dosage: 25, unit: 'g',
          timing: ['post_workout'], iconName: 'brain', colorValue: 0xFF6366F1),
    ],
  ),
  _PresetPack(
    emoji: '🌙',
    title: 'Sleep Stack',
    subtitle: 'Mag Glycinate · Melatonin · L-Theanine',
    supplements: [
      _PresetSupplement(name: 'Magnesium Glycinate', dosage: 400, unit: 'mg',
          timing: ['bedtime'], iconName: 'moon', colorValue: 0xFF845EC2),
      _PresetSupplement(name: 'Melatonin', dosage: 5, unit: 'mg',
          timing: ['bedtime'], iconName: 'moon', colorValue: 0xFF6366F1),
      _PresetSupplement(name: 'L-Theanine', dosage: 200, unit: 'mg',
          timing: ['bedtime'], iconName: 'leaf', colorValue: 0xFF00C9A7),
    ],
  ),
];

IconData _iconFor(String name) {
  switch (name) {
    case 'drop':   return PhosphorIconsFill.drop;
    case 'leaf':   return PhosphorIconsFill.leaf;
    case 'heart':  return PhosphorIconsFill.heart;
    case 'brain':  return PhosphorIconsFill.brain;
    case 'fire':   return PhosphorIconsFill.fire;
    case 'sun':    return PhosphorIconsFill.sun;
    case 'moon':   return PhosphorIconsFill.moon;
    default:       return PhosphorIconsFill.pill;
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────
class SupplementScreen extends ConsumerWidget {
  const SupplementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplements = ref.watch(supplementsProvider);
    final logs       = ref.watch(todaySupplementLogsProvider);
    final taken      = ref.watch(takenCountTodayProvider);
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepObsidian : AppColors.cloudGray,
      body: CustomScrollView(
        physics: scrollPhysics,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Supplements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.stackSimple),
                onPressed: () => _showPresetPacksSheet(context, ref, isDark),
                tooltip: 'Browse Stacks',
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.plus),
                onPressed: () => _showAddSheet(context, isDark),
                tooltip: 'Add Supplement',
              ),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // ── Progress Hero ─────────────────────────────────────
              _ProgressHero(
                total: supplements.length,
                taken: taken,
                isDark: isDark,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 20),

              // ── List or Empty ─────────────────────────────────────
              if (supplements.isEmpty)
                _EmptyState(
                  isDark: isDark,
                  onAdd: () => _showAddSheet(context, isDark),
                  onBrowse: () => _showPresetPacksSheet(context, ref, isDark),
                ).animate().fadeIn(duration: 400.ms)
              else
                _SupplementGroupedList(
                  supplements: supplements,
                  logs: logs,
                  isDark: isDark,
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSupplementSheet(isDark: isDark),
    );
  }

  void _showPresetPacksSheet(BuildContext context, WidgetRef ref, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PresetPacksSheet(isDark: isDark, ref: ref),
    );
  }
}

// ── Progress Hero ─────────────────────────────────────────────────────────────
class _ProgressHero extends StatelessWidget {
  final int total;
  final int taken;
  final bool isDark;

  const _ProgressHero({
    required this.total,
    required this.taken,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : (taken / total).clamp(0.0, 1.0);
    const accent = Color(0xFF6366F1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0E0D2A), const Color(0xFF0B0920)]
                : [const Color(0xFFEEEDFF), const Color(0xFFE4E2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(PhosphorIconsFill.pill, color: accent, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S SUPPLEMENTS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: accent.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '$taken / $total taken',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${(pct * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: pct == 1.0 ? AppColors.dynamicMint : accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: v,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: pct == 1.0
                              ? [AppColors.dynamicMint, AppColors.dynamicMint]
                              : [accent, accent.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
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

// ── Grouped Supplement List ───────────────────────────────────────────────────
class _SupplementGroupedList extends ConsumerStatefulWidget {
  final List<SupplementDoc> supplements;
  final Map<int, List<DateTime>> logs;
  final bool isDark;

  const _SupplementGroupedList({
    required this.supplements,
    required this.logs,
    required this.isDark,
  });

  @override
  ConsumerState<_SupplementGroupedList> createState() =>
      _SupplementGroupedListState();
}

class _SupplementGroupedListState
    extends ConsumerState<_SupplementGroupedList> {
  /// Tracks which groups are collapsed
  final Set<String> _collapsed = {};

  /// Build groups: group key → list of supplements
  Map<String, List<SupplementDoc>> _buildGroups() {
    final map = <String, List<SupplementDoc>>{};
    for (final sup in widget.supplements) {
      if (sup.timing.isEmpty) {
        map.putIfAbsent('_other', () => []).add(sup);
      } else {
        // Put supplement in its first timing group
        final key = sup.timing.first;
        map.putIfAbsent(key, () => []).add(sup);
      }
    }
    return map;
  }

  List<MapEntry<String, List<SupplementDoc>>> _sortedGroups(
      Map<String, List<SupplementDoc>> map) {
    final ordered = <MapEntry<String, List<SupplementDoc>>>[];
    for (final key in _kGroupOrder) {
      if (map.containsKey(key)) {
        ordered.add(MapEntry(key, map[key]!));
      }
    }
    if (map.containsKey('_other')) {
      ordered.add(MapEntry('_other', map['_other']!));
    }
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();
    final sorted = _sortedGroups(groups);
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sorted.asMap().entries.map((groupEntry) {
            final groupIdx = groupEntry.key;
            final groupKey = groupEntry.value.key;
            final sups = groupEntry.value.value;
            final isCollapsed = _collapsed.contains(groupKey);

            final takenInGroup = sups
                .where((s) => (widget.logs[s.id]?.isNotEmpty) ?? false)
                .length;
            final label = _kGroupLabels[groupKey] ?? groupKey;

            return Column(
              key: ValueKey(groupKey),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (groupIdx > 0) const SizedBox(height: 8),

                // ── Section Header ──────────────────────────────────
                AppAnimatedPressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isCollapsed) {
                        _collapsed.remove(groupKey);
                      } else {
                        _collapsed.add(groupKey);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: takenInGroup == sups.length
                                ? AppColors.dynamicMint.withValues(alpha: 0.15)
                                : const Color(0xFF6366F1).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$takenInGroup of ${sups.length} taken',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: takenInGroup == sups.length
                                  ? AppColors.dynamicMint
                                  : const Color(0xFF6366F1),
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: isCollapsed ? -0.25 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            PhosphorIconsRegular.caretDown,
                            size: 14,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: groupIdx * 40))
                    .fadeIn(duration: 300.ms),

                // ── Divider ──────────────────────────────────────────
                Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.06),
                  margin: const EdgeInsets.only(bottom: 10),
                ),

                // ── Supplement Cards ──────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: isCollapsed
                      ? const SizedBox.shrink()
                      : Column(
                          children: sups.asMap().entries.map((e) {
                            final i = e.key;
                            final sup = e.value;
                            final isTaken =
                                (widget.logs[sup.id]?.isNotEmpty) ?? false;
                            final accent = Color(sup.colorValue);

                            return _SupplementCard(
                              sup: sup,
                              isTaken: isTaken,
                              accent: accent,
                              isDark: widget.isDark,
                              animDelay: Duration(
                                  milliseconds: groupIdx * 60 + i * 50),
                              onToggle: () =>
                                  _handleToggle(context, sup, isTaken),
                              onOptions: () => _showOptions(
                                  context, sup, widget.isDark),
                            );
                          }).toList(),
                        ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _handleToggle(
      BuildContext context, SupplementDoc sup, bool isTaken) {
    HapticFeedback.mediumImpact();
    if (isTaken) {
      ref
          .read(todaySupplementLogsProvider.notifier)
          .removeLastLog(sup.id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${sup.name} unmarked'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.withValues(alpha: 0.85),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      ));
    } else {
      ref
          .read(todaySupplementLogsProvider.notifier)
          .logTaken(sup.id);
      final accent = Color(sup.colorValue);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${sup.name} marked as taken ✓'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: accent.withValues(alpha: 0.92),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      ));
    }
  }

  void _showOptions(
      BuildContext context, SupplementDoc sup, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              sup.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(PhosphorIconsFill.archive,
                    color: AppColors.danger, size: 18),
              ),
              title: const Text('Archive Supplement'),
              subtitle: const Text('Remove from your active stack'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(supplementsProvider.notifier)
                    .archiveSupplement(sup.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Individual Supplement Card ────────────────────────────────────────────────
class _SupplementCard extends StatelessWidget {
  final SupplementDoc sup;
  final bool isTaken;
  final Color accent;
  final bool isDark;
  final Duration animDelay;
  final VoidCallback onToggle;
  final VoidCallback onOptions;

  const _SupplementCard({
    required this.sup,
    required this.isTaken,
    required this.accent,
    required this.isDark,
    required this.animDelay,
    required this.onToggle,
    required this.onOptions,
  });

  String _dosageLabel() {
    if (sup.dosage > 0) {
      final amount = sup.dosage % 1 == 0
          ? sup.dosage.toInt().toString()
          : sup.dosage.toString();
      return '$amount ${sup.unit}';
    }
    return sup.unit;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: isDark ? 0.18 : 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onLongPress: onOptions,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // Icon bubble
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(_iconFor(sup.iconName), color: accent, size: 21),
                ),
                const SizedBox(width: 13),

                // Name + dosage + timing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sup.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dosageLabel(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                      if (sup.timing.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: sup.timing
                              .map((t) => _TimingChip(t, accent))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Tap-to-check button
                AppAnimatedPressable(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isTaken ? accent : accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: isTaken
                          ? null
                          : Border.all(
                              color: accent.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: isTaken
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: isTaken
                        ? const Icon(PhosphorIconsFill.checkFat,
                                size: 18, color: Colors.white)
                            .animate()
                            .scale(
                                begin: const Offset(0.3, 0.3),
                                end: const Offset(1, 1),
                                duration: 200.ms,
                                curve: Curves.easeOutBack)
                        : Icon(
                            PhosphorIconsRegular.check,
                            size: 18,
                            color: accent.withValues(alpha: 0.5),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: animDelay)
        .fadeIn(duration: 320.ms)
        .slideY(begin: 0.05, duration: 320.ms);
  }
}

class _TimingChip extends StatelessWidget {
  final String timing;
  final Color color;

  const _TimingChip(this.timing, this.color);

  @override
  Widget build(BuildContext context) {
    final label = _kTimingOptions
        .firstWhere((t) => t.$1 == timing, orElse: () => (timing, timing))
        .$2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Preset Packs Sheet ────────────────────────────────────────────────────────
class _PresetPacksSheet extends StatefulWidget {
  final bool isDark;
  final WidgetRef ref;

  const _PresetPacksSheet({required this.isDark, required this.ref});

  @override
  State<_PresetPacksSheet> createState() => _PresetPacksSheetState();
}

class _PresetPacksSheetState extends State<_PresetPacksSheet> {
  final Set<int> _addedPacks = {};
  final Set<int> _loadingPacks = {};

  Future<void> _addPack(int idx, _PresetPack pack) async {
    setState(() => _loadingPacks.add(idx));
    HapticFeedback.mediumImpact();

    for (final s in pack.supplements) {
      await widget.ref.read(supplementsProvider.notifier).addSupplement(
            name: s.name,
            dosage: s.dosage,
            unit: s.unit,
            timing: s.timing,
            colorValue: s.colorValue,
            iconName: s.iconName,
          );
    }

    setState(() {
      _loadingPacks.remove(idx);
      _addedPacks.add(idx);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('${pack.title} added (${pack.supplements.length} supplements) ✓'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dynamicMint.withValues(alpha: 0.92),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      ));

      // Auto-close after brief delay
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  const Icon(PhosphorIconsFill.stackSimple,
                      color: Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Supplement Stacks',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                itemCount: _kPresetPacks.length,
                itemBuilder: (_, idx) {
                  final pack = _kPresetPacks[idx];
                  final isAdded = _addedPacks.contains(idx);
                  final isLoading = _loadingPacks.contains(idx);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.cloudGray,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAdded
                            ? AppColors.dynamicMint.withValues(alpha: 0.4)
                            : const Color(0xFF6366F1).withValues(alpha: 0.12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pack.emoji,
                              style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pack.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: widget.isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pack.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.isDark
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 38,
                                  child: ElevatedButton(
                                    onPressed: isAdded || isLoading
                                        ? null
                                        : () => _addPack(idx, pack),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isAdded
                                          ? AppColors.dynamicMint
                                          : const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: isAdded
                                          ? AppColors.dynamicMint
                                              .withValues(alpha: 0.7)
                                          : Colors.grey.withValues(alpha: 0.3),
                                      disabledForegroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: isAdded ? 0 : 4,
                                      shadowColor: const Color(0xFF6366F1)
                                          .withValues(alpha: 0.3),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isAdded
                                                    ? PhosphorIconsFill.checkFat
                                                    : PhosphorIconsFill.plus,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isAdded
                                                    ? 'Added ✓'
                                                    : 'Add All',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: idx * 80))
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.06, duration: 300.ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAdd;
  final VoidCallback onBrowse;

  const _EmptyState({
    required this.isDark,
    required this.onAdd,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(PhosphorIconsFill.pill,
                color: Color(0xFF6366F1), size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'No supplements yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build your supplement stack and\ntrack daily intake with one tap.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onBrowse,
                  icon: const Icon(PhosphorIconsFill.stackSimple, size: 16),
                  label: const Text('Browse Stacks',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(PhosphorIconsFill.plus, size: 18),
                  label: const Text('Add',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Supplement Sheet ──────────────────────────────────────────────────────
class _AddSupplementSheet extends ConsumerStatefulWidget {
  final bool isDark;
  const _AddSupplementSheet({required this.isDark});

  @override
  ConsumerState<_AddSupplementSheet> createState() =>
      _AddSupplementSheetState();
}

class _AddSupplementSheetState extends ConsumerState<_AddSupplementSheet> {
  final _nameCtrl   = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _notesCtrl  = TextEditingController();

  String      _unit       = 'mg';
  int         _colorValue = 0xFF6366F1;
  String      _iconName   = 'pill';
  final Set<String> _timing = {};
  bool        _saving     = false;

  static const _icons = [
    ('pill',  'Pill'),
    ('drop',  'Drop'),
    ('leaf',  'Leaf'),
    ('heart', 'Heart'),
    ('brain', 'Brain'),
    ('fire',  'Fire'),
    ('sun',   'Sun'),
    ('moon',  'Moon'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }
    setState(() => _saving = true);
    await ref.read(supplementsProvider.notifier).addSupplement(
          name: name,
          dosage: double.tryParse(_dosageCtrl.text) ?? 0,
          unit: _unit,
          timing: _timing.toList(),
          colorValue: _colorValue,
          iconName: _iconName,
          notes: _notesCtrl.text.trim(),
        );
    setState(() => _saving = false);
    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(_colorValue);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Icon(PhosphorIconsFill.pill, color: accent, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Add Supplement',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                children: [
                  // ── Name ──
                  _SheetLabel('Name *'),
                  TextField(
                    controller: _nameCtrl,
                    decoration: _inputDeco('e.g. Vitamin D3', widget.isDark),
                  ),
                  const SizedBox(height: 16),

                  // ── Dosage + Unit ──
                  _SheetLabel('Dosage'),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _dosageCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              _inputDeco('e.g. 1000', widget.isDark),
                        ),
                      ),
                      const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _unit,
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: widget.isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AppColors.cloudGray,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                            ),
                            items: _kUnits
                                .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        u,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _unit = v);
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Timing ──
                  _SheetLabel('When to Take'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kTimingOptions.map((t) {
                      final selected = _timing.contains(t.$1);
                      return AppAnimatedPressable(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if (selected) {
                              _timing.remove(t.$1);
                            } else {
                              _timing.add(t.$1);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? accent
                                : accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: selected
                                ? null
                                : Border.all(color: accent.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            t.$2,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : accent,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // ── Icon ──
                  _SheetLabel('Icon'),
                  SizedBox(
                    height: 56,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _icons.length,
                      itemBuilder: (_, i) {
                        final (key, _) = _icons[i];
                        final sel = _iconName == key;
                        return AppAnimatedPressable(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _iconName = key);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? accent
                                  : accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconFor(key),
                              color: sel ? Colors.white : accent,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Color ──
                  _SheetLabel('Color'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _kSupplementColors.map((c) {
                      final sel = _colorValue == c.value;
                      return AppAnimatedPressable(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _colorValue = c.value);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: sel
                                ? Border.all(
                                    color: Colors.white, width: 2.5)
                                : null,
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                      color: c.withValues(alpha: 0.45),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: sel
                              ? const Icon(PhosphorIconsFill.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // ── Notes ──
                  _SheetLabel('Notes'),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: _inputDeco(
                        'e.g. Take with food', widget.isDark),
                  ),
                  const SizedBox(height: 28),

                  // ── Save ──
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 6,
                        shadowColor: accent.withValues(alpha: 0.4),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Add to Stack',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
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

// ── Sheet helpers ─────────────────────────────────────────────────────────────
class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

InputDecoration _inputDeco(String hint, bool isDark) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.4)),
      filled: true,
      fillColor:
          isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.cloudGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
