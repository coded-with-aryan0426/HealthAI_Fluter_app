import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../database/models/daily_log_doc.dart';
import '../database/models/workout_doc.dart';
import '../database/models/meal_doc.dart';
import '../database/models/habit_doc.dart';
import '../database/models/user_doc.dart';

/// Generates a comprehensive PDF health report from Isar data.
class PdfReportService {
  const PdfReportService._();

  // ── Brand colours (using PDF colour space) ──────────────────────────────────
  static const _mint      = PdfColor.fromInt(0xFF12C2A8);
  static const _indigo    = PdfColor.fromInt(0xFF5B5EF6);
  static const _warn      = PdfColor.fromInt(0xFFF59E0B);
  static const _danger    = PdfColor.fromInt(0xFFEF4444);
  static const _darkBg    = PdfColor.fromInt(0xFF0D1117);
  static const _darkCard  = PdfColor.fromInt(0xFF161B22);
  static const _lightText = PdfColor.fromInt(0xFFE6EDF3);
  static const _mutedText = PdfColor.fromInt(0xFF8B949E);
  static const _border    = PdfColor.fromInt(0xFF30363D);

  // ── Public entry point ──────────────────────────────────────────────────────

  static Future<File> generate({
    required Isar isar,
    required UserDoc user,
    int rangeDays = 30,
  }) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: rangeDays));

    // Fetch all data in parallel
    final results = await Future.wait([
      isar.dailyLogDocs.filter().dateBetween(from, now).sortByDate().findAll(),
      isar.workoutDocs.filter().dateBetween(from, now).sortByDate().findAll(),
      isar.mealDocs.filter().dateLoggedBetween(from, now).sortByDateLogged().findAll(),
      isar.habitDocs.filter().isArchivedEqualTo(false).findAll(),
    ]);

    final logs     = results[0] as List<DailyLogDoc>;
    final workouts = results[1] as List<WorkoutDoc>;
    final meals    = results[2] as List<MealDoc>;
    final habits   = results[3] as List<HabitDoc>;

    final doc = pw.Document(
      title: 'HealthAI Health Report',
      author: 'HealthAI',
      subject: 'Personal Health Report',
    );

    // ── Page theme ─────────────────────────────────────────────────────────────
    final theme = pw.ThemeData.withFont();

    // ── Pages ──────────────────────────────────────────────────────────────────
    doc.addPage(_coverPage(user, from, now, logs, workouts, meals, habits, theme));
    if (logs.isNotEmpty) {
      doc.addPage(_dailyMetricsPage(logs, user, theme));
    }
    if (workouts.isNotEmpty) {
      doc.addPage(_workoutsPage(workouts, theme));
    }
    if (meals.isNotEmpty) {
      doc.addPage(_mealsPage(meals, theme));
    }
    if (habits.isNotEmpty) {
      doc.addPage(_habitsPage(habits, theme));
    }

    // ── Write to temp file ─────────────────────────────────────────────────────
    final bytes = await doc.save();
    final dir   = await getTemporaryDirectory();
    final stamp = '${now.year}${_p2(now.month)}${_p2(now.day)}';
    final file  = File('${dir.path}/HealthAI_Report_$stamp.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ── Cover page ──────────────────────────────────────────────────────────────

  static pw.Page _coverPage(
    UserDoc user,
    DateTime from,
    DateTime to,
    List<DailyLogDoc> logs,
    List<WorkoutDoc> workouts,
    List<MealDoc> meals,
    List<HabitDoc> habits,
    pw.ThemeData theme,
  ) {
    final name = user.displayName ?? user.email.split('@').first;
    final avgCal = logs.isEmpty
        ? 0
        : (logs.map((l) => l.caloriesConsumed).reduce((a, b) => a + b) / logs.length).round();
    final avgSteps = logs.isEmpty
        ? 0
        : (logs.map((l) => l.stepCount).reduce((a, b) => a + b) / logs.length).round();
    final totalWorkouts = workouts.length;
    final activeHabits  = habits.length;

    return pw.Page(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Container(
        color: _darkBg,
        child: pw.Stack(
          children: [
            // Accent bar top
            pw.Positioned(
              top: 0, left: 0, right: 0,
              child: pw.Container(
                height: 6,
                decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [_indigo, _mint],
                  ),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(48, 60, 48, 48),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Title badge
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: _mint.shade(0.15),
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      'HEALTH REPORT',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _mint,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    name,
                    style: pw.TextStyle(
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                      color: _lightText,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '${_fmtDate(from)} – ${_fmtDate(to)}',
                    style: pw.TextStyle(fontSize: 14, color: _mutedText),
                  ),
                  pw.SizedBox(height: 48),
                  pw.Divider(color: _border, thickness: 1),
                  pw.SizedBox(height: 32),

                  // Summary stats grid
                  pw.Text(
                    'AT A GLANCE',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _mint,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Row(
                    children: [
                      _statBox('Avg Calories', '$avgCal', 'kcal/day', _indigo),
                      pw.SizedBox(width: 16),
                      _statBox('Avg Steps', '$avgSteps', 'steps/day', _mint),
                      pw.SizedBox(width: 16),
                      _statBox('Workouts', '$totalWorkouts', 'sessions', _warn),
                      pw.SizedBox(width: 16),
                      _statBox('Active Habits', '$activeHabits', 'tracked', _danger),
                    ],
                  ),
                  pw.SizedBox(height: 32),
                  pw.Divider(color: _border, thickness: 1),
                  pw.SizedBox(height: 32),

                  // User profile snapshot
                  pw.Text(
                    'PROFILE SNAPSHOT',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _mint,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip('Goal: ${_goalLabel(user.primaryGoal)}'),
                      _chip('Level: ${user.fitnessLevel}'),
                      if (user.heightCm != null)
                        _chip('Height: ${user.heightCm!.round()} cm'),
                      if (user.weightKg != null)
                        _chip('Weight: ${user.weightKg!.toStringAsFixed(1)} kg'),
                      _chip('Cal target: ${user.calorieGoal} kcal'),
                      _chip('Protein target: ${user.proteinGoalG} g'),
                      if (user.preferences.dietary.isNotEmpty)
                        _chip('Diet: ${user.preferences.dietary.join(", ")}'),
                    ],
                  ),
                  pw.Spacer(),

                  // Footer
                  pw.Divider(color: _border, thickness: 1),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated by HealthAI',
                        style: pw.TextStyle(fontSize: 9, color: _mutedText),
                      ),
                      pw.Text(
                        _fmtDate(to),
                        style: pw.TextStyle(fontSize: 9, color: _mutedText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Daily Metrics page ─────────────────────────────────────────────────────

  static pw.Page _dailyMetricsPage(
    List<DailyLogDoc> logs,
    UserDoc user,
    pw.ThemeData theme,
  ) {
    return pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      header: (ctx) => _pageHeader('Daily Metrics', 'Last ${logs.length} days tracked'),
      footer: _pageFooter,
      build: (ctx) => [
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Cal In', 'Cal Burned', 'Protein', 'Carbs', 'Fat', 'Water', 'Steps', 'Sleep'],
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 8,
            color: _lightText,
          ),
          headerDecoration: const pw.BoxDecoration(color: _darkCard),
          cellStyle: const pw.TextStyle(fontSize: 8, color: _lightText),
          rowDecoration: const pw.BoxDecoration(color: _darkBg),
          oddRowDecoration: pw.BoxDecoration(
            color: _darkCard.shade(0.5),
          ),
          border: pw.TableBorder.all(color: _border, width: 0.5),
          columnWidths: {
            0: const pw.FixedColumnWidth(56),
            1: const pw.FixedColumnWidth(40),
            2: const pw.FixedColumnWidth(48),
            3: const pw.FixedColumnWidth(40),
            4: const pw.FixedColumnWidth(40),
            5: const pw.FixedColumnWidth(34),
            6: const pw.FixedColumnWidth(42),
            7: const pw.FixedColumnWidth(46),
            8: const pw.FixedColumnWidth(40),
          },
          data: logs.map((l) => [
            _shortDate(l.date),
            '${l.caloriesConsumed}',
            '${l.caloriesBurned}',
            '${l.proteinGrams}g',
            '${l.carbsGrams}g',
            '${l.fatGrams}g',
            '${(l.waterMl / 1000).toStringAsFixed(1)}L',
            '${l.stepCount}',
            '${(l.sleepMinutes / 60).toStringAsFixed(1)}h',
          ]).toList(),
        ),
        pw.SizedBox(height: 20),
        // Averages row
        _sectionTitle('Summary'),
        pw.SizedBox(height: 8),
        pw.Row(children: [
          _miniStat('Avg Cal In', '${_avg(logs.map((l) => l.caloriesConsumed))} kcal', _indigo),
          pw.SizedBox(width: 12),
          _miniStat('Avg Steps', '${_avg(logs.map((l) => l.stepCount))}', _mint),
          pw.SizedBox(width: 12),
          _miniStat('Avg Sleep', '${(_avg(logs.map((l) => l.sleepMinutes)) / 60).toStringAsFixed(1)} h', _warn),
          pw.SizedBox(width: 12),
          _miniStat('Avg Water', '${(_avg(logs.map((l) => l.waterMl)) / 1000).toStringAsFixed(1)} L', PdfColors.blueGrey),
        ]),
      ],
    );
  }

  // ── Workouts page ──────────────────────────────────────────────────────────

  static pw.Page _workoutsPage(
    List<WorkoutDoc> workouts,
    pw.ThemeData theme,
  ) {
    return pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      header: (ctx) => _pageHeader('Workouts', '${workouts.length} session${workouts.length == 1 ? "" : "s"}'),
      footer: _pageFooter,
      build: (ctx) => [
        pw.SizedBox(height: 16),
        ...workouts.map((w) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: _darkCard,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: _border, width: 0.5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        w.title,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: _lightText,
                        ),
                      ),
                      pw.Text(
                        _fmtDate(w.date),
                        style: pw.TextStyle(fontSize: 8, color: _mutedText),
                      ),
                    ],
                  ),
                  pw.Row(children: [
                    _wTag('${(w.durationSeconds / 60).round()} min', _mint),
                    pw.SizedBox(width: 6),
                    _wTag('${w.totalVolumeKg.toStringAsFixed(0)} kg vol', _indigo),
                  ]),
                ],
              ),
            ),
            if (w.exercises.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, top: 6, bottom: 4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: w.exercises.take(6).map((ex) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(children: [
                      pw.Container(
                        width: 4, height: 4,
                        decoration: pw.BoxDecoration(
                          color: _mint,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        ex.name,
                        style: pw.TextStyle(fontSize: 9, color: _lightText),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        '${ex.sets.length} set${ex.sets.length == 1 ? "" : "s"}',
                        style: pw.TextStyle(fontSize: 8, color: _mutedText),
                      ),
                    ]),
                  )).toList(),
                ),
              ),
            pw.SizedBox(height: 10),
          ],
        )),
      ],
    );
  }

  // ── Meals page ─────────────────────────────────────────────────────────────

  static pw.Page _mealsPage(
    List<MealDoc> meals,
    pw.ThemeData theme,
  ) {
    // Group by date
    final byDate = <String, List<MealDoc>>{};
    for (final m in meals) {
      final key = _shortDate(m.dateLogged);
      byDate.putIfAbsent(key, () => []).add(m);
    }

    return pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      header: (ctx) => _pageHeader('Nutrition Log', '${meals.length} meals logged'),
      footer: _pageFooter,
      build: (ctx) => [
        pw.SizedBox(height: 16),
        ...byDate.entries.take(30).map((entry) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Date header
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: _indigo.shade(0.2),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                entry.key,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _indigo,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Meal', 'Type', 'Cal', 'P', 'C', 'F'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 7,
                color: _lightText,
              ),
              headerDecoration: const pw.BoxDecoration(color: _darkCard),
              cellStyle: const pw.TextStyle(fontSize: 8, color: _lightText),
              rowDecoration: const pw.BoxDecoration(color: _darkBg),
              border: pw.TableBorder.all(color: _border, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FixedColumnWidth(40),
                3: const pw.FixedColumnWidth(32),
                4: const pw.FixedColumnWidth(32),
                5: const pw.FixedColumnWidth(32),
              },
              data: entry.value.map((m) => [
                m.name.length > 30 ? '${m.name.substring(0, 28)}…' : m.name,
                m.mealType,
                '${m.calories}',
                '${m.proteinGrams}g',
                '${m.carbsGrams}g',
                '${m.fatGrams}g',
              ]).toList(),
            ),
            pw.SizedBox(height: 12),
          ],
        )),
      ],
    );
  }

  // ── Habits page ────────────────────────────────────────────────────────────

  static pw.Page _habitsPage(
    List<HabitDoc> habits,
    pw.ThemeData theme,
  ) {
    return pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      header: (ctx) => _pageHeader('Habits', '${habits.length} active habit${habits.length == 1 ? "" : "s"}'),
      footer: _pageFooter,
      build: (ctx) => [
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: ['Habit', 'Category', 'Frequency', 'Streak', 'Total', 'Since'],
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 8,
            color: _lightText,
          ),
          headerDecoration: const pw.BoxDecoration(color: _darkCard),
          cellStyle: const pw.TextStyle(fontSize: 8, color: _lightText),
          rowDecoration: const pw.BoxDecoration(color: _darkBg),
          oddRowDecoration: pw.BoxDecoration(color: _darkCard.shade(0.5)),
          border: pw.TableBorder.all(color: _border, width: 0.5),
          data: habits.map((h) {
            final streak = _calcStreak(h.completedDates);
            return [
              h.title.length > 28 ? '${h.title.substring(0, 26)}…' : h.title,
              h.category,
              h.frequency,
              '$streak days',
              '${h.completedDates.length}×',
              _shortDate(h.createdAt),
            ];
          }).toList(),
        ),
      ],
    );
  }

  // ── Shared UI primitives ───────────────────────────────────────────────────

  static pw.Widget _pageHeader(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: 3,
          decoration: const pw.BoxDecoration(
            gradient: pw.LinearGradient(colors: [_indigo, _mint]),
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: _lightText,
                  ),
                ),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(fontSize: 9, color: _mutedText),
                ),
              ],
            ),
            pw.Text(
              'HealthAI',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _mint,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: _border, thickness: 0.5),
      ],
    );
  }

  static pw.Widget Function(pw.Context) get _pageFooter => (ctx) => pw.Column(
    children: [
      pw.Divider(color: _border, thickness: 0.5),
      pw.SizedBox(height: 6),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'HealthAI Personal Report',
            style: pw.TextStyle(fontSize: 7, color: _mutedText),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: _mutedText),
          ),
        ],
      ),
    ],
  );

  static pw.Widget _statBox(
      String label, String value, String unit, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: _darkCard,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: color.shade(0.4), width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.Text(
              unit,
              style: pw.TextStyle(fontSize: 8, color: _mutedText),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: _lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _chip(String text) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: pw.BoxDecoration(
      color: _darkCard,
      borderRadius: pw.BorderRadius.circular(20),
      border: pw.Border.all(color: _border, width: 0.5),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9, color: _lightText),
    ),
  );

  static pw.Widget _sectionTitle(String text) => pw.Text(
    text.toUpperCase(),
    style: pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: _mint,
      letterSpacing: 1.5,
    ),
  );

  static pw.Widget _miniStat(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: _darkCard,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: color.shade(0.3), width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.Text(
                label,
                style: pw.TextStyle(fontSize: 8, color: _mutedText),
              ),
            ],
          ),
        ),
      );

  static pw.Widget _wTag(String text, PdfColor color) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: pw.BoxDecoration(
      color: color.shade(0.15),
      borderRadius: pw.BorderRadius.circular(20),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 8, color: color, fontWeight: pw.FontWeight.bold),
    ),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  static int _calcStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final sorted = dates.map(_midnight).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime cursor = _midnight(DateTime.now());
    for (final d in sorted) {
      if (d == cursor || d == cursor.subtract(const Duration(days: 1))) {
        streak++;
        cursor = d;
      } else {
        break;
      }
    }
    return streak;
  }

  static int _avg(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return (list.reduce((a, b) => a + b) / list.length).round();
  }

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}';

  static String _shortDate(DateTime d) =>
      '${_p2(d.day)} ${_monthAbbr(d.month)}';

  static String _p2(int n) => n.toString().padLeft(2, '0');

  static String _monthName(int m) => const [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ][m];

  static String _monthAbbr(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m];

  static String _goalLabel(String g) => switch (g) {
    'fat_loss'      => 'Fat Loss',
    'muscle_gain'   => 'Muscle Gain',
    'maintenance'   => 'Maintenance',
    'recomposition' => 'Recomposition',
    _               => 'General Fitness',
  };
}
