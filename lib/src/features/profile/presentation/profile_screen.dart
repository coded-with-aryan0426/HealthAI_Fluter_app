import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/theme_provider.dart';
import '../../profile/application/user_provider.dart';
import '../../../database/models/daily_log_doc.dart';
import '../../../database/models/exercise_pr_doc.dart';
import '../../dashboard/application/daily_activity_provider.dart';
import '../../dashboard/application/weekly_stats_provider.dart';
import '../../../services/local_db_service.dart';

// ── Providers ─────────────────────────────────────────────────────────────────
final _prListProvider = FutureProvider<List<ExercisePRDoc>>((ref) async {
  final isar = ref.watch(isarProvider);
  final all = isar.exercisePRDocs.where().idGreaterThan(0).findAllSync();
  all.sort((a, b) => b.estimated1RMKg.compareTo(a.estimated1RMKg));
  return all.take(5).toList();
});

/// Returns the last 7 days of DailyLogDoc sorted oldest→newest (reuses weeklyStatsProvider).
final _last7DaysProvider = Provider<List<DailyLogDoc>>((ref) {
  return ref.watch(weeklyStatsProvider).days;
});

/// Returns all DailyLogDocs for the current month using correct Isar query.
final _currentMonthLogsProvider = Provider<List<DailyLogDoc>>((ref) {
  final isar = ref.watch(isarProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final all = isar.dailyLogDocs.where().idGreaterThan(0).findAllSync();
  return all.where((d) => !d.date.isBefore(monthStart)).toList();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = ref.watch(dailyActivityProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepObsidian : AppColors.cloudGray,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _ProfileSliverAppBar(isDark: isDark),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _BodyMetricsStrip(isDark: isDark)
                    .animate().fadeIn(delay: 60.ms)
                    .slideY(begin: 0.06, duration: 380.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _WeeklyActivityCard(isDark: isDark, today: today)
                    .animate().fadeIn(delay: 120.ms)
                    .slideY(begin: 0.06, duration: 380.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _GoalsCard(isDark: isDark)
                    .animate().fadeIn(delay: 180.ms)
                    .slideY(begin: 0.06, duration: 380.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _AchievementsCard(isDark: isDark)
                    .animate().fadeIn(delay: 240.ms)
                    .slideY(begin: 0.06, duration: 380.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _StreakCard(isDark: isDark)
                    .animate().fadeIn(delay: 300.ms)
                    .slideY(begin: 0.06, duration: 380.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _PersonalBestsCard(isDark: isDark)
                    .animate().fadeIn(delay: 360.ms)
                    .slideY(begin: 0.06, duration: 380.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _AISummaryCard(isDark: isDark)
                    .animate().fadeIn(delay: 420.ms)
                    .slideY(begin: 0.06, duration: 380.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sliver App Bar ─────────────────────────────────────────────────────────────
class _ProfileSliverAppBar extends ConsumerWidget {
  final bool isDark;
  const _ProfileSliverAppBar({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final name = user.displayName ?? 'Friend';
    final photoUrl = user.photoUrl;

    return SliverAppBar(
      expandedHeight: 310,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.deepObsidian : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: _NavBtn(icon: PhosphorIconsRegular.arrowLeft, isDark: isDark),
        onPressed: () { HapticFeedback.lightImpact(); context.pop(); },
      ),
      actions: [
        IconButton(
          icon: _NavBtn(icon: PhosphorIconsRegular.gear, isDark: isDark),
          onPressed: () { HapticFeedback.lightImpact(); context.push('/settings'); },
        ),
        Consumer(builder: (ctx, r, _) {
          final dark = r.watch(themeProvider) == ThemeMode.dark;
          return IconButton(
            icon: _NavBtn(
              icon: dark ? PhosphorIconsFill.moon : PhosphorIconsFill.sun,
              isDark: isDark,
              color: dark ? AppColors.softIndigo : AppColors.warning,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              r.read(themeProvider.notifier).toggleTheme();
            },
          );
        }),
        const SizedBox(width: 6),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: _HeroBg(isDark: isDark, name: name, photoUrl: photoUrl, ref: ref),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final Color? color;
  const _NavBtn({required this.icon, required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.08 : 0.85),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.1 : 0.3)),
      ),
      child: Icon(icon,
          color: color ?? (isDark ? Colors.white70 : AppColors.lightTextPrimary),
          size: 17),
    );
  }
}

class _HeroBg extends ConsumerWidget {
  final bool isDark;
  final String name;
  final String? photoUrl;
  final WidgetRef ref;
  const _HeroBg({required this.isDark, required this.name, this.photoUrl, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final memberSince = user.createdAt;
    final sinceStr = '${_monthName(memberSince.month)} ${memberSince.year}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0B0E14), const Color(0xFF11142A)]
              : [const Color(0xFFECEDFF), const Color(0xFFE0F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient orbs
          Positioned(top: -50, right: -60,
              child: _Orb(size: 220, color: AppColors.softIndigo, opacity: 0.13)),
          Positioned(bottom: 10, left: -50,
              child: _Orb(size: 180, color: AppColors.dynamicMint, opacity: 0.09)),
          Positioned(top: 80, left: 60,
              child: _Orb(size: 80, color: AppColors.softIndigo, opacity: 0.07)),

          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 36),
                // Avatar ring
                Stack(alignment: Alignment.center, children: [
                  Container(
                    width: 112, height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.softIndigo, AppColors.dynamicMint],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.softIndigo.withOpacity(0.45),
                            blurRadius: 28, spreadRadius: 2),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.96, end: 1.04, duration: 2200.ms,
                          curve: Curves.easeInOut),
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.deepObsidian : Colors.white,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(photoUrl!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _AvatarInitial(initials: initials))
                          : _AvatarInitial(initials: initials),
                    ),
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: GestureDetector(
                      onTap: () => _showEditSheet(context, ref, isDark),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.softIndigo, Color(0xFF9B59B6)]),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isDark ? AppColors.deepObsidian : Colors.white,
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.softIndigo.withOpacity(0.5),
                                blurRadius: 8)
                          ],
                        ),
                        child: const Icon(PhosphorIconsFill.pencilSimple,
                            color: Colors.white, size: 13),
                      ),
                    ),
                  ),
                ]).animate().scale(duration: 550.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 14),
                Text(name,
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    )).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 6),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _PillBadge(
                      icon: Icons.verified, label: 'PRO MEMBER',
                      gradient: const LinearGradient(
                          colors: [AppColors.softIndigo, Color(0xFF9B59B6)])),
                  const SizedBox(width: 8),
                  _PillBadge(
                      icon: PhosphorIconsFill.calendarBlank,
                      label: 'Since $sinceStr',
                      gradient: LinearGradient(colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.06)
                      ])),
                ]).animate().fadeIn(delay: 160.ms),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showEditSheet(context, ref, isDark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isDark ? 0.08 : 0.65),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.12 : 0.5)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(PhosphorIconsRegular.pencilSimple,
                          color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                          size: 14),
                      const SizedBox(width: 6),
                      Text('Edit Profile',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                          )),
                    ]),
                  ),
                ).animate().fadeIn(delay: 220.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  void _showEditSheet(BuildContext context, WidgetRef ref, bool isDark) {
    HapticFeedback.lightImpact();
    final user = ref.read(userProvider);
    final nameCtrl = TextEditingController(text: user.displayName ?? '');
    final weightCtrl = TextEditingController(
        text: user.weightKg?.toStringAsFixed(0) ?? '');
    final heightCtrl = TextEditingController(
        text: user.heightCm?.toStringAsFixed(0) ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _EditProfileSheet(
          isDark: isDark, nameCtrl: nameCtrl,
          weightCtrl: weightCtrl, heightCtrl: heightCtrl,
          onSave: () async {
            HapticFeedback.mediumImpact();
            await ref.read(userProvider.notifier).updateProfile(
              name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
              heightCm: double.tryParse(heightCtrl.text),
              weightKg: double.tryParse(weightCtrl.text),
            );
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Orb({required this.size, required this.color, required this.opacity});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity)),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  const _PillBadge({required this.icon, required this.label, required this.gradient});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 11),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(
            color: Colors.white, fontSize: 10,
            fontWeight: FontWeight.bold, letterSpacing: 0.8)),
      ]),
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  final String initials;
  const _AvatarInitial({required this.initials});
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.softIndigo.withOpacity(0.3),
    child: Center(
      child: Text(initials, style: const TextStyle(
          color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
    ),
  );
}

// ── Edit Profile Sheet ─────────────────────────────────────────────────────────
class _EditProfileSheet extends StatelessWidget {
  final bool isDark;
  final TextEditingController nameCtrl, weightCtrl, heightCtrl;
  final VoidCallback onSave;
  const _EditProfileSheet({
    required this.isDark, required this.nameCtrl,
    required this.weightCtrl, required this.heightCtrl, required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.07 : 0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 20),
            Text('Edit Profile', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary)),
            const SizedBox(height: 20),
            _Field(controller: nameCtrl, label: 'Display Name',
                icon: PhosphorIconsRegular.user, isDark: isDark),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Field(controller: heightCtrl, label: 'Height (cm)',
                  icon: PhosphorIconsRegular.arrowsVertical, isDark: isDark,
                  keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _Field(controller: weightCtrl, label: 'Weight (kg)',
                  icon: PhosphorIconsRegular.scales, isDark: isDark,
                  keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softIndigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
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
  final TextInputType keyboardType;
  const _Field({
    required this.controller, required this.label,
    required this.icon, required this.isDark,
    this.keyboardType = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : AppColors.lightTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.softIndigo),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : AppColors.cloudGray,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.softIndigo.withOpacity(0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.softIndigo, width: 1.5)),
      ),
    );
  }
}

// ── Body Metrics Strip ─────────────────────────────────────────────────────────
class _BodyMetricsStrip extends ConsumerWidget {
  final bool isDark;
  const _BodyMetricsStrip({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final weight = user.weightKg;
    final height = user.heightCm;
    final dob = user.dob;
    final age = dob != null
        ? ((DateTime.now().difference(dob).inDays) / 365).floor()
        : null;

    double? bmi;
    String bmiLabel = '—';
    Color bmiColor = Colors.grey;
    if (weight != null && height != null && height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
      if (bmi < 18.5) { bmiLabel = 'Under'; bmiColor = Colors.blue; }
      else if (bmi < 25) { bmiLabel = 'Normal'; bmiColor = AppColors.dynamicMint; }
      else if (bmi < 30) { bmiLabel = 'Over'; bmiColor = AppColors.warning; }
      else { bmiLabel = 'Obese'; bmiColor = AppColors.danger; }
    }

    final metrics = [
      _MetricData(label: 'WEIGHT', value: weight != null ? '${weight.toStringAsFixed(1)}' : '—',
          unit: 'kg', icon: PhosphorIconsFill.scales, color: AppColors.softIndigo),
      _MetricData(label: 'HEIGHT', value: height != null ? '${height.toStringAsFixed(0)}' : '—',
          unit: 'cm', icon: PhosphorIconsFill.arrowsVertical, color: AppColors.dynamicMint),
      _MetricData(label: 'BMI', value: bmi != null ? bmi.toStringAsFixed(1) : '—',
          unit: bmiLabel, icon: PhosphorIconsFill.heartbeat, color: bmiColor),
      _MetricData(label: 'AGE', value: age != null ? '$age' : '—',
          unit: 'yrs', icon: PhosphorIconsFill.cake, color: AppColors.warning),
      _MetricData(label: 'GOAL CAL', value: '${user.calorieGoal}',
          unit: 'kcal', icon: PhosphorIconsFill.flame, color: Colors.deepOrange),
      _MetricData(label: 'PROTEIN', value: '${user.proteinGoalG}',
          unit: 'g/day', icon: PhosphorIconsFill.fishSimple, color: Colors.teal),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(label: 'Body Metrics', isDark: isDark,
          action: 'Edit', onAction: () => _showMetricsSheet(context, ref, isDark, user)),
      const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: metrics.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) => _MetricCard(m: metrics[i], isDark: isDark)
              .animate(delay: Duration(milliseconds: 40 * i))
              .fadeIn().slideX(begin: 0.1, curve: Curves.easeOutCubic),
        ),
      ),
    ]);
  }

  void _showMetricsSheet(BuildContext ctx, WidgetRef ref, bool isDark, user) {
    HapticFeedback.lightImpact();
    final weightCtrl = TextEditingController(text: user.weightKg?.toStringAsFixed(1) ?? '');
    final heightCtrl = TextEditingController(text: user.heightCm?.toStringAsFixed(0) ?? '');
    final calCtrl = TextEditingController(text: '${user.calorieGoal}');
    final proteinCtrl = TextEditingController(text: '${user.proteinGoalG}');

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoalGlass : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Body Metrics & Goals', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _Field(controller: heightCtrl, label: 'Height (cm)',
                    icon: PhosphorIconsRegular.arrowsVertical, isDark: isDark,
                    keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _Field(controller: weightCtrl, label: 'Weight (kg)',
                    icon: PhosphorIconsRegular.scales, isDark: isDark,
                    keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _Field(controller: calCtrl, label: 'Calorie Goal',
                    icon: PhosphorIconsRegular.flame, isDark: isDark,
                    keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _Field(controller: proteinCtrl, label: 'Protein (g)',
                    icon: PhosphorIconsRegular.fishSimple, isDark: isDark,
                    keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(userProvider.notifier).updateProfile(
                      heightCm: double.tryParse(heightCtrl.text),
                      weightKg: double.tryParse(weightCtrl.text),
                      calorieGoal: int.tryParse(calCtrl.text),
                      proteinGoalG: int.tryParse(proteinCtrl.text),
                    );
                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softIndigo, foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _MetricData {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const _MetricData({required this.label, required this.value,
    required this.unit, required this.icon, required this.color});
}

class _MetricCard extends StatefulWidget {
  final _MetricData m;
  final bool isDark;
  const _MetricCard({required this.m, required this.isDark});
  @override
  State<_MetricCard> createState() => _MetricCardState();
}
class _MetricCardState extends State<_MetricCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { setState(() => _pressed = true); HapticFeedback.selectionClick(); },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 88,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: widget.m.color.withOpacity(widget.isDark ? 0.10 : 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.m.color.withOpacity(0.22)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(widget.m.icon, color: widget.m.color, size: 14),
              const SizedBox(height: 4),
              Text(widget.m.value, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: widget.m.color)),
              Text(widget.m.unit, style: TextStyle(
                  fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
              const SizedBox(height: 2),
              Text(widget.m.label, style: TextStyle(
                  fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35))),
            ]),
        ),
      ),
    );
  }
}

// ── Weekly Activity Card ───────────────────────────────────────────────────────
class _WeeklyActivityCard extends ConsumerWidget {
  final bool isDark;
  final DailyLogDoc today;
  const _WeeklyActivityCard({required this.isDark, required this.today});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GlassCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(label: "Today's Activity", isDark: isDark,
          action: 'Full Report', onAction: () => context.push('/weekly')),
      const SizedBox(height: 14),
      Row(children: [
        _StatPill(value: '${today.caloriesBurned}',
            unit: 'kcal', label: 'BURNED',
            color: AppColors.warning, icon: PhosphorIconsFill.flame, isDark: isDark),
        const SizedBox(width: 10),
        _StatPill(value: '${today.exerciseCompletedMinutes}',
            unit: 'min', label: 'ACTIVE',
            color: AppColors.dynamicMint, icon: PhosphorIconsFill.timer, isDark: isDark),
        const SizedBox(width: 10),
        _StatPill(value: '${(today.waterMl / 1000).toStringAsFixed(1)}',
            unit: 'L', label: 'WATER',
            color: const Color(0xFF41C9E2), icon: PhosphorIconsFill.drop, isDark: isDark),
      ]),
      const SizedBox(height: 16),
      _WeeklyBarChart(isDark: isDark),
    ]));
  }
}

class _StatPill extends StatelessWidget {
  final String value, unit, label;
  final Color color;
  final IconData icon;
  final bool isDark;
  const _StatPill({required this.value, required this.unit, required this.label,
    required this.color, required this.icon, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.10 : 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic, children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 2),
            Text(unit, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
          ]),
          Text(label, style: TextStyle(
              fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35))),
        ]),
      ),
    );
  }
}

class _WeeklyBarChart extends ConsumerWidget {
  final bool isDark;
  const _WeeklyBarChart({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // 0=Mon

    final logs = ref.watch(_last7DaysProvider);

    // Build a map of weekday index → normalized activity value (0.0–1.0)
    final Map<int, double> dayValues = {};
    for (final log in logs) {
      final wd = log.date.weekday - 1; // 0=Mon
      final burned = log.caloriesBurned;
      final steps = log.stepCount;
      // Normalize: 500 kcal burned or 10k steps = 1.0
      final v = ((burned / 500.0) + (steps / 10000.0)) / 2.0;
      dayValues[wd] = v.clamp(0.05, 1.0);
    }

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('7-Day Activity', style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          Text('This week', style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35))),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final isToday = i == today;
          final isActive = i <= today;
          final value = dayValues[i] ?? (isActive ? 0.07 : 0.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: isActive ? value : 0.07),
                  duration: Duration(milliseconds: 600 + i * 80),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Container(
                    height: 48 * v + 4,
                    decoration: BoxDecoration(
                      gradient: isToday
                          ? const LinearGradient(
                              colors: [AppColors.softIndigo, AppColors.dynamicMint],
                              begin: Alignment.bottomCenter, end: Alignment.topCenter)
                          : LinearGradient(
                              colors: isActive
                                  ? [AppColors.dynamicMint.withOpacity(0.4),
                                     AppColors.dynamicMint.withOpacity(0.75)]
                                  : [Colors.grey.withOpacity(0.08),
                                     Colors.grey.withOpacity(0.13)],
                              begin: Alignment.bottomCenter, end: Alignment.topCenter),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(days[i], style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? AppColors.softIndigo
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
              ]),
            ),
          );
        }),
      ),
    ]);
  }
}

// ── Goals Card ─────────────────────────────────────────────────────────────────
class _GoalsCard extends ConsumerWidget {
  final bool isDark;
  const _GoalsCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    String goalLabel = 'General Fitness';
    Color goalColor = AppColors.dynamicMint;
    if (user.primaryGoal == 'weight_loss') { goalLabel = 'Weight Loss'; goalColor = AppColors.danger; }
    if (user.primaryGoal == 'muscle_gain') { goalLabel = 'Muscle Gain'; goalColor = AppColors.warning; }
    if (user.primaryGoal == 'endurance') { goalLabel = 'Endurance'; goalColor = AppColors.softIndigo; }

    String levelLabel = 'Intermediate';
    if (user.fitnessLevel == 'beginner') levelLabel = 'Beginner';
    if (user.fitnessLevel == 'advanced') levelLabel = 'Advanced';

    final dietary = user.preferences.dietary;

    final today = ref.watch(dailyActivityProvider);

    return _GlassCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(label: 'Goals & Preferences', isDark: isDark),
      const SizedBox(height: 14),
      // Goal + level badges
      Row(children: [
        _TagChip(label: goalLabel, color: goalColor, icon: PhosphorIconsFill.target),
        const SizedBox(width: 8),
        _TagChip(label: levelLabel, color: AppColors.softIndigo, icon: PhosphorIconsFill.chartLine),
      ]),
      if (dietary.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: dietary.map((d) => _TagChip(
            label: d, color: AppColors.dynamicMint,
            icon: PhosphorIconsFill.leaf,
          )).toList(),
        ),
      ],
      const SizedBox(height: 16),
      // Progress rings row — live data from today's log
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _GoalRing(
          value: user.calorieGoal > 0
              ? (today.caloriesConsumed / user.calorieGoal).clamp(0.0, 1.0)
              : 0,
          label: '${user.calorieGoal}',
          sublabel: 'kcal goal',
          color: AppColors.warning,
        ),
        _GoalRing(
          value: user.proteinGoalG > 0
              ? (today.proteinGrams / user.proteinGoalG).clamp(0.0, 1.0)
              : 0,
          label: '${user.proteinGoalG}g',
          sublabel: 'protein',
          color: Colors.teal,
        ),
        _GoalRing(
          value: user.waterGoalMl > 0
              ? (today.waterMl / user.waterGoalMl).clamp(0.0, 1.0)
              : 0,
          label: '${(user.waterGoalMl / 1000).toStringAsFixed(1)}L',
          sublabel: 'water',
          color: const Color(0xFF41C9E2),
        ),
      ]),
    ]));
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _TagChip({required this.label, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class _GoalRing extends StatelessWidget {
  final double value;
  final String label, sublabel;
  final Color color;
  const _GoalRing({required this.value, required this.label,
    required this.sublabel, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 66, height: 66,
        child: Stack(alignment: Alignment.center, children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
            duration: 900.ms, curve: Curves.easeOutCubic,
            builder: (_, v, __) => CircularProgressIndicator(
              value: v, strokeWidth: 5, strokeCap: StrokeCap.round,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(label, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface)),
        ]),
      ),
      const SizedBox(height: 6),
      Text(sublabel, style: TextStyle(
          fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
    ]);
  }
}

// ── Achievements Card ──────────────────────────────────────────────────────────
class _AchievementsCard extends ConsumerWidget {
  final bool isDark;
  const _AchievementsCard({required this.isDark});

  static const _badges = [
    (id: 'early_bird',  icon: PhosphorIconsFill.sun,              color: Colors.amber,      label: 'Early Bird',     desc: 'Log before 8 AM'),
    (id: 'scan_master', icon: PhosphorIconsFill.scan,             color: Colors.blueAccent, label: 'Scan Master',    desc: 'Scan 10 foods'),
    (id: 'marathon',    icon: PhosphorIconsFill.personSimpleRun,  color: Colors.deepOrange, label: 'Marathon',       desc: 'Run 42 km total'),
    (id: 'hydrated',    icon: PhosphorIconsFill.drop,             color: Color(0xFF41C9E2), label: 'Hydrated',       desc: 'Hit water goal 7 days'),
    (id: 'streak_7',    icon: PhosphorIconsFill.flame,            color: Colors.orange,     label: 'Streak 7',       desc: '7-day streak'),
    (id: 'protein_pro', icon: PhosphorIconsFill.fishSimple,       color: Colors.teal,       label: 'Protein Pro',   desc: 'Hit protein goal 14 days'),
    (id: 'gym_rat',     icon: PhosphorIconsFill.barbell,          color: Colors.purple,     label: 'Gym Rat',        desc: 'Work out 20 times'),
    (id: 'perf_week',   icon: PhosphorIconsFill.trophy,           color: Colors.amber,      label: 'Perfect Week',  desc: 'All goals for 7 days'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final unlocked = user.unlockedAchievements;
    final unlockedCount = _badges.where((b) => unlocked.contains(b.id)).length;

    return _GlassCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _SectionHeader(label: 'Achievements', isDark: isDark)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.softIndigo, AppColors.dynamicMint]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$unlockedCount / ${_badges.length}',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ]),
      const SizedBox(height: 14),
      // Total points
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.softIndigo.withOpacity(0.15),
            AppColors.dynamicMint.withOpacity(0.08),
          ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.softIndigo.withOpacity(0.2)),
        ),
        child: Row(children: [
          const Icon(PhosphorIconsFill.star, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Points', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.6,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            Text('${user.totalPoints + 250}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: AppColors.warning)),
          ]),
          const Spacer(),
          Text('Level ${(user.totalPoints ~/ 500) + 1}',
              style: const TextStyle(color: AppColors.softIndigo,
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
      ),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 8,
        children: _badges.asMap().entries.map((e) {
          final b = e.value;
          final isUnlocked = unlocked.contains(b.id);
          return _BadgeTile(
              icon: b.icon, color: b.color,
            label: b.label, desc: b.desc,
            unlocked: isUnlocked, delay: 50 * e.key,
          );
        }).toList(),
      ),
    ]));
  }
}

class _BadgeTile extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label, desc;
  final bool unlocked;
  final int delay;
  const _BadgeTile({required this.icon, required this.color, required this.label,
    required this.desc, required this.unlocked, required this.delay});
  @override
  State<_BadgeTile> createState() => _BadgeTileState();
}
class _BadgeTileState extends State<_BadgeTile> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { setState(() => _pressed = true); HapticFeedback.selectionClick(); },
      onTapUp: (_) { setState(() => _pressed = false); _showTooltip(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0, duration: 120.ms,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.unlocked
                  ? LinearGradient(colors: [
                      widget.color.withOpacity(0.28),
                      widget.color.withOpacity(0.1)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : null,
              color: widget.unlocked ? null : Colors.grey.withOpacity(0.08),
              border: Border.all(
                color: widget.unlocked ? widget.color.withOpacity(0.55) : Colors.grey.withOpacity(0.18),
                width: 1.5,
              ),
              boxShadow: widget.unlocked ? [
                BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
              ] : null,
            ),
            child: Icon(widget.icon,
                color: widget.unlocked ? widget.color : Colors.grey.withOpacity(0.3),
                size: 24),
          )
              .animate(delay: Duration(milliseconds: widget.delay))
              .scale(duration: 380.ms, curve: Curves.easeOutBack,
                  begin: widget.unlocked ? const Offset(0.6, 0.6) : const Offset(1, 1)),
          const SizedBox(height: 5),
          Text(widget.label, textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w600,
                color: widget.unlocked
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                    : Colors.grey.withOpacity(0.4),
              )),
        ]),
      ),
    );
  }
  void _showTooltip() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);
    final entry = OverlayEntry(builder: (_) => Positioned(
      top: position.dy - 42,
      left: position.dx - 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(widget.desc, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      ),
    ));
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1400), entry.remove);
  }
}

// ── Streak Card ────────────────────────────────────────────────────────────────
class _StreakCard extends ConsumerWidget {
  final bool isDark;
  const _StreakCard({required this.isDark});

  /// Calculates current and longest streak from a list of DailyLogDocs.
  /// A day counts as "active" if caloriesBurned > 0 or stepCount > 0.
  static (int current, int longest) _calcStreaks(List<DailyLogDoc> logs) {
    if (logs.isEmpty) return (0, 0);
    final activeDays = logs
        .where((l) => l.caloriesBurned > 0 || l.stepCount > 0)
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet();

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Current streak — walk backwards from today
    int current = 0;
    var check = today;
    while (activeDays.contains(check)) {
      current++;
      check = check.subtract(const Duration(days: 1));
    }

    // Longest streak — scan all active days sorted
    final sorted = activeDays.toList()..sort();
    int longest = 0, run = 0;
    DateTime? prev;
    for (final d in sorted) {
      if (prev == null || d.difference(prev).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
      prev = d;
    }

    return (current, longest);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthLogs = ref.watch(_currentMonthLogsProvider);

    // For streak we need all logs, not just this month — reuse _last7DaysProvider
    // for current streak approximation; for full history use month logs.
    // Using month logs is sufficient since streaks rarely exceed a month.
    final (currentStreak, longestStreak) = _calcStreaks(monthLogs);

    // Active days set for heatmap
    final activeDays = monthLogs
        .where((l) => l.caloriesBurned > 0 || l.stepCount > 0)
        .map((l) => l.date.day)
        .toSet();

    return _GlassCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(label: 'Streaks & Consistency', isDark: isDark),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _StreakPill(
          value: currentStreak, label: 'Current',
          color: Colors.orange, icon: PhosphorIconsFill.flame,
        )),
        const SizedBox(width: 12),
        Expanded(child: _StreakPill(
          value: longestStreak, label: 'Best',
          color: AppColors.warning, icon: PhosphorIconsFill.trophy,
        )),
      ]),
      const SizedBox(height: 16),
      Text('Monthly Heatmap', style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
      const SizedBox(height: 10),
      _HeatmapGrid(now: now, isDark: isDark, activeDays: activeDays),
    ]));
  }
}

class _StreakPill extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final IconData icon;
  const _StreakPill({required this.value, required this.label,
    required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.9, end: 1.1, duration: 1200.ms),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$value days', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(
              fontSize: 10, color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final DateTime now;
  final bool isDark;
  final Set<int> activeDays;
  const _HeatmapGrid({required this.now, required this.isDark, required this.activeDays});
  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday; // 1=Mon

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, mainAxisSpacing: 5, crossAxisSpacing: 5),
      itemCount: (firstWeekday - 1) + daysInMonth,
      itemBuilder: (ctx, i) {
        final day = i - (firstWeekday - 1) + 1;
        if (day < 1) return const SizedBox.shrink();
        final isToday = day == now.day;
        final isPast = day < now.day;
        final isActive = activeDays.contains(day);
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + day * 10),
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.softIndigo
                : isActive && isPast
                    ? AppColors.dynamicMint.withOpacity(0.7)
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: isToday ? Center(child: Text('$day',
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))
              : null,
        );
      },
    );
  }
}

// ── Personal Bests Card ────────────────────────────────────────────────────────
class _PersonalBestsCard extends ConsumerWidget {
  final bool isDark;
  const _PersonalBestsCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prsAsync = ref.watch(_prListProvider);
    final prs = prsAsync.valueOrNull ?? [];

    return _GlassCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(label: 'Personal Bests', isDark: isDark,
          action: 'Progress', onAction: () => context.push('/workout/progress')),
      const SizedBox(height: 14),
      if (prs.isEmpty) ...[
        Center(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Icon(PhosphorIconsRegular.barbell,
                size: 36, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 8),
            Text('Complete workouts to track your PRs',
                style: TextStyle(fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
          ]),
        )),
      ] else ...[
        ...prs.asMap().entries.map((e) {
          final pr = e.value;
          final isLast = e.key == prs.length - 1;
          return Column(children: [
            _PRRow(pr: pr, rank: e.key + 1, isDark: isDark)
                .animate(delay: Duration(milliseconds: 40 * e.key))
                .fadeIn().slideX(begin: 0.05, curve: Curves.easeOutCubic),
            if (!isLast) Divider(height: 12, thickness: 0.5,
                indent: 48, color: Colors.white.withOpacity(0.06)),
          ]);
        }),
      ],
    ]));
  }
}

class _PRRow extends StatelessWidget {
  final ExercisePRDoc pr;
  final int rank;
  final bool isDark;
  const _PRRow({required this.pr, required this.rank, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final color = rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : Colors.brown.shade400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(PhosphorIconsFill.trophy, color: color, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pr.exerciseName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text('Achieved ${_dateStr(pr.achievedAt)}',
              style: TextStyle(fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${pr.estimated1RMKg.toStringAsFixed(1)} kg',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                  color: AppColors.softIndigo)),
          Text('Est. 1RM', style: TextStyle(fontSize: 9,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35))),
        ]),
      ]),
    );
  }
  static String _dateStr(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

// ── AI Summary Card ────────────────────────────────────────────────────────────
class _AISummaryCard extends ConsumerWidget {
  final bool isDark;
  const _AISummaryCard({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final summary = user.weeklyAiSummary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.softIndigo.withOpacity(0.22), AppColors.softIndigo.withOpacity(0.06)]
              : [AppColors.softIndigo.withOpacity(0.1), AppColors.softIndigo.withOpacity(0.03)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softIndigo.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: AppColors.softIndigo.withOpacity(0.06),
              blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Stack(children: [
        Positioned(right: -10, top: -10,
            child: Icon(PhosphorIconsFill.sparkle, size: 80,
                color: AppColors.softIndigo.withOpacity(0.07))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.softIndigo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(PhosphorIconsFill.sparkle,
                  color: AppColors.softIndigo, size: 16),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.88, end: 1.0, duration: 1600.ms),
            const SizedBox(width: 10),
            const Text('AI WEEKLY SUMMARY', style: TextStyle(
                color: AppColors.softIndigo, fontSize: 11,
                fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ]),
          const SizedBox(height: 12),
          if (summary != null && summary.isNotEmpty) ...[
            Text(summary, style: TextStyle(
                height: 1.55, fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          ] else ...[
            const Text('Your weekly summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Chat with the AI Coach to get a personalized weekly health summary.',
                style: TextStyle(height: 1.5, fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55))),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); context.push('/chat'); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.softIndigo, Color(0xFF9B59B6)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(PhosphorIconsFill.sparkle, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('Ask AI Coach', style: TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ],
        ]),
      ]),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _GlassCard({required this.isDark, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.0 : 0.04),
              blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.label, required this.isDark,
    this.action, this.onAction});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      const Spacer(),
      if (action != null)
        GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); onAction?.call(); },
          child: Text(action!, style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold,
              color: AppColors.softIndigo)),
        ),
    ]);
  }
}
