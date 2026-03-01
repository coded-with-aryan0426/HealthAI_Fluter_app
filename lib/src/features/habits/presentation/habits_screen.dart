import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../application/habit_provider.dart';
import '../application/habit_insight_provider.dart';
import '../../../database/models/habit_doc.dart';

// ── Icon helpers ──────────────────────────────────────────────────────────────
IconData _iconFor(String name) {
  switch (name) {
    case 'flower_lotus': return PhosphorIconsFill.flowerLotus;
    case 'sneaker':      return PhosphorIconsFill.sneaker;
    case 'pill':         return PhosphorIconsFill.pill;
    case 'book':         return PhosphorIconsFill.bookOpen;
    case 'barbell':      return PhosphorIconsFill.barbell;
    case 'bed':          return PhosphorIconsFill.bed;
    case 'fork':         return PhosphorIconsFill.forkKnife;
    case 'drop':         return PhosphorIconsFill.drop;
    case 'brain':        return PhosphorIconsFill.brain;
    case 'run':          return PhosphorIconsFill.personSimpleRun;
    case 'heart':        return PhosphorIconsFill.heart;
    case 'moon':         return PhosphorIconsFill.moon;
    case 'sun':          return PhosphorIconsFill.sun;
    case 'pencil':       return PhosphorIconsFill.pencilSimple;
    case 'music':        return PhosphorIconsFill.musicNotes;
    case 'coffee':       return PhosphorIconsFill.coffee;
    case 'leaf':         return PhosphorIconsFill.leaf;
    case 'fire':         return PhosphorIconsFill.fire;
    default:             return PhosphorIconsFill.target;
  }
}

const _iconOptions = [
  ('target',       'Goal'),
  ('barbell',      'Workout'),
  ('run',          'Running'),
  ('sneaker',      'Steps'),
  ('heart',        'Heart'),
  ('brain',        'Mental'),
  ('flower_lotus', 'Meditate'),
  ('moon',         'Sleep'),
  ('bed',          'Rest'),
  ('drop',         'Hydrate'),
  ('fork',         'Nutrition'),
  ('pill',         'Vitamins'),
  ('book',         'Reading'),
  ('pencil',       'Journal'),
  ('leaf',         'Nature'),
  ('fire',         'Streak'),
  ('coffee',       'Morning'),
  ('music',        'Music'),
];

const _colorOptions = [
  (0xFF6366F1, 'Indigo'),
  (0xFF8B5CF6, 'Purple'),
  (0xFF06B6D4, 'Cyan'),
  (0xFF10B981, 'Green'),
  (0xFFF59E0B, 'Amber'),
  (0xFFEF4444, 'Red'),
  (0xFFF97316, 'Orange'),
  (0xFF3B82F6, 'Blue'),
];

// ── Category metadata ─────────────────────────────────────────────────────────
const _categoryMeta = {
  'fitness':      ('Fitness',      PhosphorIconsFill.barbell,    0xFF6366F1),
  'nutrition':    ('Nutrition',    PhosphorIconsFill.forkKnife,  0xFF10B981),
  'mental':       ('Mental',       PhosphorIconsFill.brain,      0xFF8B5CF6),
  'sleep':        ('Sleep',        PhosphorIconsFill.moon,       0xFF06B6D4),
  'productivity': ('Productivity', PhosphorIconsFill.target,     0xFFF59E0B),
  'general':      ('General',      PhosphorIconsFill.sparkle,    0xFF94A3B8),
};

String _categoryLabel(String cat) => _categoryMeta[cat]?.$1 ?? 'General';
IconData _categoryIcon(String cat)  => _categoryMeta[cat]?.$2 ?? PhosphorIconsFill.sparkle;
Color _categoryColor(String cat)    => Color(_categoryMeta[cat]?.$3 ?? 0xFF94A3B8);

// ── Habit Template Packs ──────────────────────────────────────────────────────
class _HabitTemplate {
  final String title;
  final String iconName;
  final int colorValue;
  final String category;
  final String frequency;
  const _HabitTemplate(this.title, this.iconName, this.colorValue, this.category, this.frequency);
}

class _HabitPack {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<_HabitTemplate> habits;
  const _HabitPack({required this.name, required this.description, required this.icon, required this.color, required this.habits});
}

const _habitPacks = [
  _HabitPack(
    name: 'Morning Routine',
    description: 'Build a powerful start to every day',
    icon: PhosphorIconsFill.sun,
    color: Color(0xFFF59E0B),
    habits: [
      _HabitTemplate('Hydrate (2 glasses)', 'drop',         0xFF06B6D4, 'general',  'daily'),
      _HabitTemplate('Meditate 10 min',     'flower_lotus', 0xFF8B5CF6, 'mental',   'daily'),
      _HabitTemplate('Morning Stretch',     'run',          0xFF6366F1, 'fitness',  'daily'),
      _HabitTemplate('Cold Shower',         'drop',         0xFF3B82F6, 'general',  'daily'),
    ],
  ),
  _HabitPack(
    name: 'Athlete Pack',
    description: 'Optimize your performance and recovery',
    icon: PhosphorIconsFill.barbell,
    color: Color(0xFF6366F1),
    habits: [
      _HabitTemplate('Workout',          'barbell', 0xFF6366F1, 'fitness',   'weekly5'),
      _HabitTemplate('Protein Goal',     'fork',    0xFF10B981, 'nutrition', 'daily'),
      _HabitTemplate('Sleep 8 Hours',    'bed',     0xFF06B6D4, 'sleep',     'daily'),
      _HabitTemplate('Take Vitamins',    'pill',    0xFFF59E0B, 'nutrition', 'daily'),
      _HabitTemplate('10,000 Steps',     'sneaker', 0xFFF97316, 'fitness',   'daily'),
    ],
  ),
  _HabitPack(
    name: 'Mental Wellness',
    description: 'Nurture your mind and emotional health',
    icon: PhosphorIconsFill.brain,
    color: Color(0xFF8B5CF6),
    habits: [
      _HabitTemplate('Journaling',          'pencil',       0xFF8B5CF6, 'mental', 'daily'),
      _HabitTemplate('Gratitude Practice',  'heart',        0xFFEF4444, 'mental', 'daily'),
      _HabitTemplate('Screen-free Hour',    'moon',         0xFF06B6D4, 'mental', 'daily'),
      _HabitTemplate('Read 20 min',         'book',         0xFF10B981, 'mental', 'daily'),
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  int _selectedDayIndex = DateTime.now().weekday - 1;
  // Track collapsed categories
  final Set<String> _collapsedCategories = {};

  // Today's weekday index (0 = Mon)
  int get _todayIndex => DateTime.now().weekday - 1;

  // true when viewing today
  bool get _isViewingToday => _selectedDayIndex == _todayIndex;

  DateTime get _selectedDate {
    final now    = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: _selectedDayIndex));
  }

  List<String> get _days  => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<String> get _dates {
    final now    = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)).day.toString());
  }

  // Full dates for each strip position (for history lookup)
  List<DateTime> get _stripDates {
    final now    = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final habits   = ref.watch(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);
    final completed = habits.where((h) => notifier.isCompletedOn(h, _selectedDate)).length;
    final streak    = notifier.calculateStreak();
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    // Past-day indicator — true if selected day is before today
    final isPastDay  = _selectedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: _buildAppBar(context, completed, habits.length, isPastDay),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Templates FAB
          FloatingActionButton(
            heroTag: 'templates',
            onPressed: () => _showTemplatesSheet(context),
            backgroundColor: isDark ? AppColors.charcoalGlass : Colors.white,
            elevation: 4,
            mini: true,
            child: const Icon(PhosphorIconsFill.squaresFour, color: AppColors.softIndigo, size: 20),
          ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 12),
          // New Habit FAB
          FloatingActionButton.extended(
            heroTag: 'newHabit',
            onPressed: () => _showAddHabitSheet(context),
            backgroundColor: AppColors.softIndigo,
            elevation: 8,
            label: const Text('New Habit',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            icon: const Icon(PhosphorIconsFill.plus, color: Colors.white, size: 20),
          ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
        ],
      ).animate().fade(delay: 400.ms),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDatePicker(isDark),
            const SizedBox(height: 20),
            _buildProgressSummary(context, completed, habits.length, isDark),
            const SizedBox(height: 20),
            _buildStreakHeatmap(isDark, streak),
            const SizedBox(height: 20),
            _HabitAiInsightCard(),
            const SizedBox(height: 20),
            _buildCategorisedHabitsList(context, habits, isDark),
          ],
        ),
      ),
    ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, int completed, int total, bool isPastDay) {
    final selDate  = _selectedDate;
    final monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateLabel  = _isViewingToday
        ? 'Build consistency, one day at a time'
        : '${_days[_selectedDayIndex]}, ${monthNames[selDate.month - 1]} ${selDate.day} — $completed of $total habits completed';

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Your Habits',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, height: 1.2)),
              if (isPastDay) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softIndigo.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('History',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softIndigo)),
                ),
              ],
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              dateLabel,
              key: ValueKey(dateLabel),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  // ── Date Picker ─────────────────────────────────────────────────────────────
  Widget _buildDatePicker(bool isDark) {
    final habits   = ref.read(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);
    final today    = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final stripDates = _stripDates;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final isSelected = index == _selectedDayIndex;
          final isToday    = index == _todayIndex;
          final cellDate   = stripDates[index];
          final cellMidnight = DateTime(cellDate.year, cellDate.month, cellDate.day);
          final isPast     = cellMidnight.isBefore(todayMidnight);
          final isFuture   = cellMidnight.isAfter(todayMidnight);

          // Completion status for this day
          Widget historyIndicator = const SizedBox(height: 5);
          if (isPast && habits.isNotEmpty) {
            final completed = habits.where((h) => notifier.isCompletedOn(h, cellDate)).length;
            final allDone   = completed == habits.length;
            historyIndicator = Icon(
              allDone ? PhosphorIconsFill.checkCircle : PhosphorIconsFill.xCircle,
              size: 10,
              color: isSelected
                  ? Colors.white.withOpacity(0.85)
                  : allDone
                      ? AppColors.dynamicMint.withOpacity(0.85)
                      : AppColors.danger.withOpacity(0.6),
            );
          } else if (isToday && !isSelected) {
            historyIndicator = Container(
              width: 5, height: 5,
              decoration: BoxDecoration(
                  color: AppColors.softIndigo,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.softIndigo.withOpacity(0.5), blurRadius: 4)]),
            );
          }

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedDayIndex = index);
            },
            child: AnimatedContainer(
              duration: 300.ms,
              width: 42,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.softIndigo
                    : isPast && !isSelected
                        ? (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06))
                        : isFuture
                            ? (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02))
                            : isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.softIndigo.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Column(
                children: [
                  Text(_days[index],
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isFuture
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                  const SizedBox(height: 6),
                  Text(_dates[index],
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isFuture
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.25)
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                  const SizedBox(height: 4),
                  historyIndicator,
                ],
              ),
            ),
          );
        }),
      ).animate().fade().slideY(begin: -0.1, end: 0, duration: 400.ms),
    );
  }

  // ── Progress Summary ────────────────────────────────────────────────────────
  Widget _buildProgressSummary(BuildContext context, int completed, int total, bool isDark) {
    final pct = total == 0 ? 0.0 : completed / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.charcoalGlass, const Color(0xFF0D1B2A)]
                : [Colors.white, AppColors.cloudGray],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.softIndigo.withOpacity(isDark ? 0.2 : 0.1)),
          boxShadow: [BoxShadow(color: AppColors.softIndigo.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60, height: 60,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct),
                duration: 1200.ms,
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: v,
                      strokeWidth: 5,
                      backgroundColor: AppColors.softIndigo.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(AppColors.softIndigo),
                      strokeCap: StrokeCap.round,
                    ),
                    Text('${(v * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.softIndigo)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$completed / $total Completed',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(
                  pct >= 1.0
                      ? 'All done! Amazing day! 🎉'
                      : pct >= 0.5
                          ? 'More than halfway there!'
                          : "Let's crush those goals!",
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ],
        ),
      ).animate(delay: 50.ms).fade().slideY(begin: 0.1, duration: 400.ms),
    );
  }

  // ── Streak + 12-week Heatmap ─────────────────────────────────────────────────
  Widget _buildStreakHeatmap(bool isDark, int streak) {
    final habits   = ref.read(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);
    final today    = DateTime.now();

    // Build 12 weeks × 7 days grid (84 cells, oldest → newest, left→right, top→bottom)
    // Align so today falls in the last column of the last row
    final int todayWeekday = today.weekday; // 1=Mon..7=Sun
    // last cell index = 83, which is today
    // each column is one week, Mon at top. We build from col 0 (oldest week) to col 11 (newest)
    // within each col, row 0=Mon..row 6=Sun
    final startDate = today.subtract(Duration(days: (11 * 7) + (todayWeekday - 1)));

    // Precompute completion rate per day
    int totalHabits = habits.length;

    double _dayRate(DateTime day) {
      if (totalHabits == 0) return 0;
      final count = habits.where((h) => notifier.isCompletedOn(h, day)).length;
      return count / totalHabits;
    }

    Color _heatColor(double rate, bool dark) {
      if (rate == 0)       return dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06);
      if (rate < 0.25)     return Colors.orange.withOpacity(0.25);
      if (rate < 0.5)      return Colors.orange.withOpacity(0.45);
      if (rate < 0.75)     return Colors.orange.withOpacity(0.65);
      return Colors.orange.withOpacity(0.9);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(isDark ? 0.25 : 0.12),
              isDark ? AppColors.charcoalGlass : Colors.white,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Streak',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$streak ${streak == 1 ? 'Day' : 'Days'}',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary)),
                        const SizedBox(width: 10),
                        if (streak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: AppColors.dynamicMint.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('🔥 active',
                                style: TextStyle(
                                    color: AppColors.dynamicMint,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11)),
                          ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      Colors.orange.withOpacity(0.4),
                      Colors.deepOrange.withOpacity(0.2),
                    ]),
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 16, spreadRadius: 2)],
                  ),
                  child: const Icon(PhosphorIconsFill.fire, color: Colors.orange, size: 26),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 0.95, end: 1.05, duration: 1200.ms),
              ],
            ),
            const SizedBox(height: 16),

            // 12-week heatmap
            Text('12-Week Activity',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
            const SizedBox(height: 8),

            // Row labels (Mon–Sun) + grid columns side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day labels
                Column(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: SizedBox(
                      width: 12, height: 9,
                      child: Text(d,
                          style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3))),
                    ),
                  )).toList(),
                ),
                const SizedBox(width: 4),

                // 12 columns (weeks)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(12, (weekIdx) {
                      return Column(
                        children: List.generate(7, (dayIdx) {
                          final cellDate = startDate.add(Duration(days: weekIdx * 7 + dayIdx));
                          final isFuture = cellDate.isAfter(today);
                          final rate = isFuture ? -1.0 : _dayRate(cellDate);
                          final isToday = cellDate.year == today.year &&
                              cellDate.month == today.month &&
                              cellDate.day == today.day;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Tooltip(
                              message: isFuture
                                  ? ''
                                  : '${cellDate.day}/${cellDate.month}: ${(rate * 100).toInt()}%',
                              child: AnimatedContainer(
                                duration: 200.ms,
                                width: 9, height: 9,
                                decoration: BoxDecoration(
                                  color: isFuture
                                      ? Colors.transparent
                                      : _heatColor(rate, isDark),
                                  borderRadius: BorderRadius.circular(2),
                                  border: isToday
                                      ? Border.all(color: Colors.orange, width: 1.5)
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ],
            ),

            // Legend
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Less', style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3))),
                const SizedBox(width: 4),
                ...[0.0, 0.25, 0.5, 0.75, 1.0].map((r) => Container(
                  width: 9, height: 9,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: _heatColor(r, isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
                Text('More', style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3))),
              ],
            ),
          ],
        ),
      ).animate(delay: 100.ms).fade().slideY(begin: 0.1, duration: 400.ms),
    );
  }

  // ── Categorised Habits List ──────────────────────────────────────────────────
  Widget _buildCategorisedHabitsList(BuildContext context, List<HabitDoc> habits, bool isDark) {
    final isToday  = _isViewingToday;
    final isPast   = _selectedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    final notifier = ref.read(habitsProvider.notifier);

    // Group habits by category, preserve insertion order of first occurrence
    final Map<String, List<HabitDoc>> groups = {};
    for (final h in habits) {
      groups.putIfAbsent(h.category, () => []).add(h);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Text(
                isToday ? "Today's Goals" : "Goals for ${_days[_selectedDayIndex]}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (isPast) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.softIndigo.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('View Only',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softIndigo)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          if (habits.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(PhosphorIconsFill.target, size: 48, color: AppColors.softIndigo.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No habits yet',
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                    const SizedBox(height: 4),
                    Text('Tap + New Habit or browse Templates',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35))),
                  ],
                ),
              ),
            )
          else
            // One category section per group
            ...groups.entries.toList().asMap().entries.map((mapEntry) {
              final sectionIndex = mapEntry.key;
              final category     = mapEntry.value.key;
              final catHabits    = mapEntry.value.value;
              final isCollapsed  = _collapsedCategories.contains(category);
              final catColor     = _categoryColor(category);
              final catIcon      = _categoryIcon(category);
              final catLabel     = _categoryLabel(category);

              // Count completions for this category on selected day
              final catDone = catHabits.where((h) => notifier.isCompletedOn(h, _selectedDate)).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category header
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isCollapsed) {
                          _collapsedCategories.remove(category);
                        } else {
                          _collapsedCategories.add(category);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(isDark ? 0.12 : 0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(catIcon, color: catColor, size: 15),
                          const SizedBox(width: 8),
                          Text(catLabel.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: catColor)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: catColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('$catDone/${catHabits.length}',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: catColor)),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            turns: isCollapsed ? -0.25 : 0,
                            duration: 250.ms,
                            child: Icon(PhosphorIconsRegular.caretDown,
                                size: 14,
                                color: catColor.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ).animate(delay: Duration(milliseconds: sectionIndex * 40)).fade().slideX(begin: -0.05, duration: 300.ms),
                  ),

                  // Habit cards (collapsible)
                  AnimatedCrossFade(
                    duration: 300.ms,
                    crossFadeState: isCollapsed
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Column(
                      children: catHabits.asMap().entries.map((entry) {
                        final idx        = entry.key;
                        final habit      = entry.value;
                        final isCompleted = notifier.isCompletedOn(habit, _selectedDate);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HabitCard(
                            habit: habit,
                            isDark: isDark,
                            isCompleted: isCompleted,
                            isReadOnly: isPast,  // past days are view-only
                            onToggle: isToday ? () {
                              HapticFeedback.mediumImpact();
                              ref.read(habitsProvider.notifier).toggle(habit.id, _selectedDate);
                            } : null,
                            onDelete: isToday ? () => ref.read(habitsProvider.notifier).remove(habit.id) : null,
                          ).animate(delay: Duration(milliseconds: sectionIndex * 60 + idx * 50))
                              .fade(duration: 350.ms)
                              .slideX(begin: 0.08, end: 0, duration: 350.ms),
                        );
                      }).toList(),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 4),
                ],
              );
            }),
        ],
      ),
    );
  }

  // ── Add Habit Sheet ──────────────────────────────────────────────────────────
  void _showAddHabitSheet(BuildContext context, {_HabitTemplate? template}) {
    HapticFeedback.lightImpact();
    final titleCtrl = TextEditingController(text: template?.title ?? '');
    String selectedIcon      = template?.iconName  ?? 'target';
    int    selectedColor     = template?.colorValue ?? 0xFF6366F1;
    String selectedCategory  = template?.category   ?? 'general';
    String selectedFrequency = template?.frequency  ?? 'daily';
    bool   reminderEnabled   = false;
    TimeOfDay reminderTime   = const TimeOfDay(hour: 8, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.charcoalGlass : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Add New Habit',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      // Title
                      TextField(
                        controller: titleCtrl,
                        autofocus: template == null,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.lightTextPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g. Morning Run, Cold Shower...',
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : AppColors.cloudGray,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category selector
                      Text('Category',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _categoryMeta.entries.map((e) {
                            final isSel = e.key == selectedCategory;
                            final cColor = Color(e.value.$3);
                            return GestureDetector(
                              onTap: () => setSheetState(() => selectedCategory = e.key),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? cColor.withOpacity(0.2) : Colors.grey.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: isSel ? Border.all(color: cColor, width: 1.5) : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(e.value.$2, size: 13, color: isSel ? cColor : Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(e.value.$1,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSel ? cColor : Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Icon picker
                      Text('Icon',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _iconOptions.length,
                          itemBuilder: (_, i) {
                            final (iconName, _) = _iconOptions[i];
                            final isSel = iconName == selectedIcon;
                            return GestureDetector(
                              onTap: () => setSheetState(() => selectedIcon = iconName),
                              child: Container(
                                width: 46, height: 46,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? Color(selectedColor).withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSel ? Border.all(color: Color(selectedColor), width: 2) : null,
                                ),
                                child: Icon(_iconFor(iconName),
                                    color: isSel ? Color(selectedColor) : Colors.grey,
                                    size: 22),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Color picker
                      Text('Color',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 8),
                      Row(
                        children: _colorOptions.map((opt) {
                          final (colorVal, _) = opt;
                          final isSel = colorVal == selectedColor;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedColor = colorVal),
                            child: Container(
                              width: 32, height: 32,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Color(colorVal),
                                shape: BoxShape.circle,
                                border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                                boxShadow: isSel
                                    ? [BoxShadow(color: Color(colorVal).withOpacity(0.5), blurRadius: 8)]
                                    : null,
                              ),
                              child: isSel ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Frequency
                      Text('Frequency',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _FreqChip(label: 'Daily',    value: 'daily',   selected: selectedFrequency, onTap: (v) => setSheetState(() => selectedFrequency = v)),
                          const SizedBox(width: 8),
                          _FreqChip(label: '5x/week',  value: 'weekly5', selected: selectedFrequency, onTap: (v) => setSheetState(() => selectedFrequency = v)),
                          const SizedBox(width: 8),
                          _FreqChip(label: '3x/week',  value: 'weekly3', selected: selectedFrequency, onTap: (v) => setSheetState(() => selectedFrequency = v)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Reminder toggle ───────────────────────────────────────
                      Text('Reminder',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : AppColors.cloudGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(PhosphorIconsRegular.bell,
                                size: 18,
                                color: reminderEnabled
                                    ? AppColors.softIndigo
                                    : Theme.of(ctx).colorScheme.onSurface.withOpacity(0.4)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                reminderEnabled
                                    ? 'Reminder at ${reminderTime.format(ctx)}'
                                    : 'No reminder',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: reminderEnabled
                                        ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                                        : Theme.of(ctx).colorScheme.onSurface.withOpacity(0.45)),
                              ),
                            ),
                            if (reminderEnabled)
                              GestureDetector(
                                onTap: () async {
                                  HapticFeedback.selectionClick();
                                  final picked = await showTimePicker(
                                    context: ctx,
                                    initialTime: reminderTime,
                                    builder: (context, child) => Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: Theme.of(context).colorScheme.copyWith(
                                          primary: AppColors.softIndigo,
                                        ),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) {
                                    setSheetState(() => reminderTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.softIndigo.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Change',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.softIndigo)),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: reminderEnabled,
                              activeColor: AppColors.softIndigo,
                              onChanged: (val) async {
                                if (val) {
                                  // Open time picker immediately when enabling
                                  final picked = await showTimePicker(
                                    context: ctx,
                                    initialTime: reminderTime,
                                    builder: (context, child) => Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: Theme.of(context).colorScheme.copyWith(
                                          primary: AppColors.softIndigo,
                                        ),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  setSheetState(() {
                                    reminderEnabled = true;
                                    if (picked != null) reminderTime = picked;
                                  });
                                } else {
                                  setSheetState(() => reminderEnabled = false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleCtrl.text.trim().isNotEmpty) {
                              final now = DateTime.now();
                              final reminder = reminderEnabled
                                  ? DateTime(now.year, now.month, now.day, reminderTime.hour, reminderTime.minute)
                                  : null;
                              await ref.read(habitsProvider.notifier).add(
                                title: titleCtrl.text.trim(),
                                iconName: selectedIcon,
                                colorValue: selectedColor,
                                category: selectedCategory,
                                frequency: selectedFrequency,
                                targetPerWeek: selectedFrequency == 'daily'
                                    ? 7
                                    : selectedFrequency == 'weekly5'
                                        ? 5
                                        : 3,
                                reminderTime: reminder,
                              );
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                HapticFeedback.mediumImpact();
                                final msg = reminderEnabled
                                    ? '${titleCtrl.text.trim()} added! Reminder set for ${reminderTime.format(context)} ✓'
                                    : '${titleCtrl.text.trim()} added ✓';
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(msg),
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.softIndigo.withOpacity(0.9),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                                ));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.softIndigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Add Habit',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // ── Templates Sheet ──────────────────────────────────────────────────────────
  void _showTemplatesSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollCtrl) => Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.charcoalGlass : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppColors.softIndigo, AppColors.dynamicMint]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(PhosphorIconsFill.squaresFour, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Habit Packs',
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('One-tap add curated habit sets',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.5))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: _habitPacks.length,
                    itemBuilder: (_, packIdx) {
                      final pack = _habitPacks[packIdx];
                      return _PackCard(
                        pack: pack,
                        isDark: isDark,
                        packIdx: packIdx,
                        onAddAll: () {
                          HapticFeedback.mediumImpact();
                          for (final t in pack.habits) {
                            ref.read(habitsProvider.notifier).add(
                              title: t.title,
                              iconName: t.iconName,
                              colorValue: t.colorValue,
                              category: t.category,
                              frequency: t.frequency,
                              targetPerWeek: t.frequency == 'daily' ? 7 : t.frequency == 'weekly5' ? 5 : 3,
                            );
                          }
                          Navigator.pop(ctx);
                        },
                        onAddSingle: (t) {
                          Navigator.pop(ctx);
                          _showAddHabitSheet(context, template: t);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Freq Chip ─────────────────────────────────────────────────────────────────
class _FreqChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;
  const _FreqChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSel = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.softIndigo : Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSel ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
      ),
    );
  }
}

// ── Pack Card ─────────────────────────────────────────────────────────────────
class _PackCard extends StatefulWidget {
  final _HabitPack pack;
  final bool isDark;
  final int packIdx;
  final VoidCallback onAddAll;
  final ValueChanged<_HabitTemplate> onAddSingle;
  const _PackCard({required this.pack, required this.isDark, required this.packIdx, required this.onAddAll, required this.onAddSingle});

  @override
  State<_PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<_PackCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pack;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.charcoalGlass.withOpacity(0.6) : AppColors.cloudGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          // Pack header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: p.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.color.withOpacity(0.3)),
                  ),
                  child: Icon(p.icon, color: p.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(p.description,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                      const SizedBox(height: 4),
                      Text('${p.habits.length} habits',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600, color: p.color)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    // Add all
                    GestureDetector(
                      onTap: widget.onAddAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [p.color, p.color.withOpacity(0.7)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Add All',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Expand toggle
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        _expanded ? 'Hide' : 'Preview',
                        style: TextStyle(
                            fontSize: 11,
                            color: p.color.withOpacity(0.7),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable habit list
          AnimatedCrossFade(
            duration: 250.ms,
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const Divider(height: 1, indent: 16, endIndent: 16),
                ...p.habits.map((t) => ListTile(
                  dense: true,
                  leading: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Color(t.colorValue).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_iconFor(t.iconName), color: Color(t.colorValue), size: 16),
                  ),
                  title: Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text(t.frequency == 'daily' ? 'Daily' : t.frequency == 'weekly5' ? '5×/week' : '3×/week',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                  trailing: GestureDetector(
                    onTap: () => widget.onAddSingle(t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(t.colorValue).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(t.colorValue).withOpacity(0.3)),
                      ),
                      child: Text('Add',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(t.colorValue))),
                    ),
                  ),
                )),
                const SizedBox(height: 8),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: widget.packIdx * 80)).fade(duration: 350.ms).slideY(begin: 0.08, duration: 350.ms);
  }
}

// ── Habit Card ────────────────────────────────────────────────────────────────
class _HabitCard extends StatefulWidget {
  final HabitDoc habit;
  final bool isDark;
  final bool isCompleted;
  final bool isReadOnly;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const _HabitCard({
    required this.habit,
    required this.isDark,
    required this.isCompleted,
    this.isReadOnly = false,
    this.onToggle,
    this.onDelete,
  });

  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard> with SingleTickerProviderStateMixin {
  late AnimationController _checkAnim;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(vsync: this, duration: 400.ms);
    if (widget.isCompleted) _checkAnim.value = 1;
  }

  @override
  void didUpdateWidget(_HabitCard old) {
    super.didUpdateWidget(old);
    if (widget.isCompleted != old.isCompleted) {
      widget.isCompleted ? _checkAnim.forward() : _checkAnim.reverse();
    }
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h     = widget.habit;
    final color = Color(h.colorValue);
    final icon  = _iconFor(h.iconName);

    // Per-habit streak
    int habitStreak = 0;
    DateTime day = DateTime.now();
    while (h.completedDates.any((d) =>
        DateTime(d.year, d.month, d.day) == DateTime(day.year, day.month, day.day))) {
      habitStreak++;
      day = day.subtract(const Duration(days: 1));
    }

    return Dismissible(
      key: ValueKey(h.id),
      direction: widget.isReadOnly ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20)),
        child: const Icon(PhosphorIconsFill.trash, color: AppColors.danger),
      ),
      confirmDismiss: widget.isReadOnly ? null : (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: widget.onDelete == null ? null : (_) => widget.onDelete!(),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isCompleted
              ? color.withOpacity(widget.isDark ? 0.12 : 0.06)
              : widget.isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isCompleted
                ? color.withOpacity(0.3)
                : Colors.white.withOpacity(widget.isDark ? 0.05 : 0),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isCompleted
                  ? color.withOpacity(0.1)
                  : Colors.black.withOpacity(widget.isDark ? 0 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52, height: 52,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.isCompleted ? 1.0 : 0.0),
                duration: 600.ms,
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: v,
                      strokeWidth: 4,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                      strokeCap: StrokeCap.round,
                    ),
                    Icon(icon, color: color, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: 300.ms,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: color.withOpacity(0.6),
                    ),
                    child: Text(h.title),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.isCompleted
                        ? 'Completed ✓'
                        : (h.subtitle.isNotEmpty ? h.subtitle : h.frequency),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isCompleted
                          ? color
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                      fontWeight: widget.isCompleted ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (habitStreak > 0) ...[
                    const SizedBox(height: 2),
                    Text('🔥 $habitStreak day streak',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.withOpacity(0.8),
                            fontWeight: FontWeight.w500)),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.isReadOnly ? null : widget.onToggle,
              child: AnimatedContainer(
                duration: 300.ms,
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isCompleted
                      ? color.withOpacity(widget.isReadOnly ? 0.5 : 1.0)
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isCompleted
                        ? color.withOpacity(widget.isReadOnly ? 0.4 : 1.0)
                        : Colors.grey.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: widget.isCompleted && !widget.isReadOnly
                      ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)]
                      : null,
                ),
                child: AnimatedSwitcher(
                  duration: 250.ms,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: widget.isCompleted
                      ? Icon(PhosphorIconsBold.check,
                          key: const ValueKey('check'), color: Colors.white.withOpacity(widget.isReadOnly ? 0.7 : 1.0), size: 20)
                      : const SizedBox(key: ValueKey('empty')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Habit Insight Card ─────────────────────────────────────────────────────
class _HabitAiInsightCard extends ConsumerStatefulWidget {
  const _HabitAiInsightCard();

  @override
  ConsumerState<_HabitAiInsightCard> createState() => _HabitAiInsightCardState();
}

class _HabitAiInsightCardState extends ConsumerState<_HabitAiInsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insightAsync = ref.watch(habitInsightProvider);
    final isDark       = Theme.of(context).brightness == Brightness.dark;

    // Stop spinner when loading is done
    ref.listen(habitInsightProvider, (_, next) {
      if (!next.isLoading) _spinCtrl.stop();
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: insightAsync.when(
        loading: () => Container(
          height: 70,
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoalGlass : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.softIndigo.withOpacity(0.1)),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 1200.ms, color: AppColors.softIndigo.withOpacity(0.05)),
        error: (_, __) => const SizedBox.shrink(),
        data: (text) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1B2E), AppColors.charcoalGlass]
                  : [const Color(0xFFF5F0FF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.softIndigo.withOpacity(isDark ? 0.2 : 0.12)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.softIndigo.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.softIndigo, AppColors.dynamicMint]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.softIndigo.withOpacity(0.35), blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('AI COACH',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: AppColors.softIndigo.withOpacity(0.7))),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _spinCtrl.repeat();
                            ref.read(habitInsightProvider.notifier).refresh();
                          },
                          child: RotationTransition(
                            turns: _spinCtrl,
                            child: Icon(PhosphorIconsRegular.arrowsClockwise,
                                size: 15, color: AppColors.softIndigo.withOpacity(0.6)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        text,
                        key: ValueKey(text),
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.lightTextPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
      ),
    );
  }
}
