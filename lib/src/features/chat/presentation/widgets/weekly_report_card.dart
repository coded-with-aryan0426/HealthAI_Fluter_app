import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../../application/weekly_report_provider.dart';

class WeeklyReportCard extends ConsumerWidget {
  const WeeklyReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(weeklyReportProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return reportAsync.when(
      loading: () => _buildLoadingCard(isDark),
      error: (_, __) => _buildErrorCard(context, ref),
      data: (report) {
        if (report == null) return _buildEmptyCard(context, ref, isDark);
        return _buildReportCard(context, ref, report, isDark);
      },
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(isDark),
      child: Column(
        children: [
          Row(
            children: [
              _reportIcon(),
              const SizedBox(width: 12),
              const Text(
                'Generating your report...',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            color: AppColors.softIndigo,
            minHeight: 2,
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms),
          const SizedBox(height: 8),
          Text(
            'Analyzing your week with AI...',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(Theme.of(context).brightness == Brightness.dark),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          const SizedBox(height: 8),
          const Text('Could not generate report', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.read(weeklyReportProvider.notifier).generate(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.softIndigo),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(isDark),
      child: Column(
        children: [
          Row(
            children: [
              _reportIcon(),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Weekly AI Report Card',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Get a comprehensive AI analysis of your health this week — workouts, nutrition, sleep, and habits.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(weeklyReportProvider.notifier).generate();
              },
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('Generate My Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildReportCard(
    BuildContext context,
    WidgetRef ref,
    WeeklyReportData report,
    bool isDark,
  ) {
    final fmt = DateFormat('MMM d');
    final weekRange = '${fmt.format(report.weekStart)} – ${fmt.format(report.weekEnd)}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.softIndigo.withValues(alpha: isDark ? 0.4 : 0.15),
                  AppColors.dynamicMint.withValues(alpha: isDark ? 0.2 : 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                _reportIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Report Card',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        weekRange,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(weeklyReportProvider.notifier).generate();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      PhosphorIconsRegular.arrowClockwise,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    _StatCell(
                      label: 'Workouts',
                      value: '${report.workoutsCompleted}',
                      suffix: '/ ${report.workoutsPlanned}',
                      icon: PhosphorIconsFill.barbell,
                      color: report.workoutsCompleted >= report.workoutsPlanned
                          ? AppColors.dynamicMint
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _StatCell(
                      label: 'Avg Calories',
                      value: '${report.avgCalories.round()}',
                      suffix: 'kcal',
                      icon: PhosphorIconsFill.fire,
                      color: AppColors.softIndigo,
                    ),
                    const SizedBox(width: 8),
                    _StatCell(
                      label: 'Avg Sleep',
                      value: report.avgSleep.toStringAsFixed(1),
                      suffix: 'h',
                      icon: PhosphorIconsFill.moon,
                      color: report.avgSleep >= 7 ? AppColors.dynamicMint : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _StatCell(
                      label: 'Habits',
                      value: '${(report.habitCompletion * 100).round()}',
                      suffix: '%',
                      icon: PhosphorIconsFill.target,
                      color: report.habitCompletion >= 0.7
                          ? AppColors.dynamicMint
                          : Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // AI Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softIndigo.withValues(alpha: isDark ? 0.1 : 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.softIndigo.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 13, color: AppColors.softIndigo),
                          const SizedBox(width: 5),
                          Text(
                            'AI Summary',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.softIndigo,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.summary,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Highlights
                if (report.highlights.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ...report.highlights.map(
                    (h) => _BulletRow(text: h, isPositive: true, isDark: isDark),
                  ),
                ],

                // Warnings
                if (report.warnings.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...report.warnings.map(
                    (w) => _BulletRow(text: w, isPositive: false, isDark: isDark),
                  ),
                ],

                const SizedBox(height: 14),

                // Next week focus
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.1 : 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.dynamicMint.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsFill.arrowRight,
                        size: 16,
                        color: AppColors.dynamicMint,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next week focus',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dynamicMint,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              report.nextWeekFocus,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _reportIcon() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.softIndigo, AppColors.dynamicMint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.insert_chart_outlined_rounded, color: Colors.white, size: 19),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? AppColors.softIndigo.withValues(alpha: 0.2)
            : AppColors.softIndigo.withValues(alpha: 0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.softIndigo.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: suffix,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  final bool isPositive;
  final bool isDark;

  const _BulletRow({
    required this.text,
    required this.isPositive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isPositive ? '✅' : '⚠️';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
