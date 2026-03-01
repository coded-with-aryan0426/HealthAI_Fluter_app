import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../application/fasting_provider.dart';
import '../../../database/models/fasting_doc.dart';

// Protocol definitions
const _protocols = [
  ('16:8',   16, 'Most popular. Eat within an 8-hour window.'),
  ('18:6',   18, 'Advanced. Eat within a 6-hour window.'),
  ('20:4',   20, 'Warrior Diet. 4-hour eating window.'),
  ('OMAD',   23, 'One Meal A Day. Max fat burning.'),
  ('5:2',    36, 'Two 36-hour fasts per week.'),
];

class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringCtrl.forward();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fastState = ref.watch(fastingProvider);
    final elapsedAsync = ref.watch(fastingElapsedProvider);
    final history = ref.watch(fastingHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final elapsed = elapsedAsync.valueOrNull ?? 0;
    final elapsedHours = elapsed / 3600.0;
    final phase = FastingNotifier.phaseFromHours(elapsedHours);
    final progress = fastState.isActive
        ? (elapsedHours / (fastState.session?.targetHours ?? 16)).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.deepObsidian : AppColors.cloudGray,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Fasting Tracker',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            actions: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.clockCounterClockwise),
                onPressed: () => _showHistory(context, history, isDark),
                tooltip: 'History',
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),

              // ── Hero Timer Ring ──────────────────────────────────
              _TimerRing(
                progress: progress,
                elapsed: elapsed,
                phase: phase,
                isActive: fastState.isActive,
                targetHours: fastState.session?.targetHours ?? 16,
                pulseCtrl: _pulseCtrl,
                ringCtrl: _ringCtrl,
                isDark: isDark,
              ),

              const SizedBox(height: 24),

              // ── Phase Timeline ───────────────────────────────────
              if (fastState.isActive)
                _PhaseTimeline(
                  elapsedHours: elapsedHours,
                  targetHours: (fastState.session?.targetHours ?? 16).toDouble(),
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              if (fastState.isActive) const SizedBox(height: 20),

              // ── Start/End Button ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: fastState.isActive
                    ? _EndFastButton(isDark: isDark)
                    : _StartFastSection(isDark: isDark),
              ),

              const SizedBox(height: 28),

              // ── Stats Row (only when active) ─────────────────────
              if (fastState.isActive)
                _StatsRow(
                  session: fastState.session!,
                  elapsed: elapsed,
                  isDark: isDark,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              if (fastState.isActive) const SizedBox(height: 28),

              // ── Recent History ───────────────────────────────────
              if (history.isNotEmpty)
                _RecentHistory(history: history, isDark: isDark)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  void _showHistory(
      BuildContext context, List history, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoalGlass : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsFill.clockCounterClockwise,
                        color: _kFastColor, size: 20),
                    const SizedBox(width: 10),
                    Text('Fasting History',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: history.length,
                  itemBuilder: (_, i) {
                    final s = history[i] as FastingDoc;
                    final dur = s.durationHours;
                    final hit = s.hitTarget;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.cloudGray,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: (hit
                                    ? AppColors.dynamicMint
                                    : _kFastColor)
                                .withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: (hit
                                      ? AppColors.dynamicMint
                                      : _kFastColor)
                                  .withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Icon(
                              hit
                                  ? PhosphorIconsFill.checkCircle
                                  : PhosphorIconsFill.timer,
                              color: hit
                                  ? AppColors.dynamicMint
                                  : _kFastColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(s.protocolName,
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 14)),
                                Text(
                                  DateFormat('MMM d, yyyy')
                                      .format(s.startTime),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${dur.toStringAsFixed(1)}h',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: hit
                                  ? AppColors.dynamicMint
                                  : _kFastColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kFastColor = Color(0xFF9B59B6);
const _kFastColorAlt = Color(0xFFE67E22);

// ── Timer Ring ────────────────────────────────────────────────────────────────
class _TimerRing extends StatelessWidget {
  final double progress;
  final int elapsed;
  final FastingPhase phase;
  final bool isActive;
  final int targetHours;
  final AnimationController pulseCtrl;
  final AnimationController ringCtrl;
  final bool isDark;

  const _TimerRing({
    required this.progress,
    required this.elapsed,
    required this.phase,
    required this.isActive,
    required this.targetHours,
    required this.pulseCtrl,
    required this.ringCtrl,
    required this.isDark,
  });

  Color get _phaseColor {
    switch (phase) {
      case FastingPhase.fed:         return const Color(0xFF3498DB);
      case FastingPhase.fatBurning:  return _kFastColorAlt;
      case FastingPhase.ketosis:     return _kFastColor;
      case FastingPhase.deepKetosis: return const Color(0xFF8E44AD);
      case FastingPhase.autophagy:   return const Color(0xFF1ABC9C);
    }
  }

  String _fmt(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor;

    return Center(
      child: AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, __) {
          final pulse = isActive ? 1.0 + pulseCtrl.value * 0.03 : 1.0;
          return Transform.scale(
            scale: pulse,
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  if (isActive)
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.15 * pulseCtrl.value),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  // Background track
                  CustomPaint(
                    size: const Size(240, 240),
                    painter: _RingPainter(
                      progress: 1.0,
                      color: color.withOpacity(0.1),
                      strokeWidth: 14,
                    ),
                  ),
                  // Progress arc
                  AnimatedBuilder(
                    animation: ringCtrl,
                    builder: (_, __) => CustomPaint(
                      size: const Size(240, 240),
                      painter: _RingPainter(
                        progress: progress * ringCtrl.value,
                        color: color,
                        strokeWidth: 14,
                        hasCap: true,
                      ),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive) ...[
                        Text(
                          _fmt(elapsed),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: 500.ms,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            phase.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Goal: ${targetHours}h',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.white.withOpacity(0.45)
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ] else ...[
                        Icon(PhosphorIconsFill.timer,
                            size: 40, color: color.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text(
                          'Not Fasting',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool hasCap;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.hasCap = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = hasCap ? StrokeCap.round : StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Phase Timeline ────────────────────────────────────────────────────────────
class _PhaseTimeline extends StatelessWidget {
  final double elapsedHours;
  final double targetHours;
  final bool isDark;

  const _PhaseTimeline({
    required this.elapsedHours,
    required this.targetHours,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final phases = FastingPhase.values;
    final maxHours = math.max(targetHours, 24.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: _kFastColor.withOpacity(isDark ? 0.2 : 0.1)),
          boxShadow: [
            BoxShadow(
                color: _kFastColor.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'METABOLIC PHASES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: _kFastColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            // Progress bar with phase markers
            Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _kFastColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Filled
                FractionallySizedBox(
                  widthFactor:
                      (elapsedHours / maxHours).clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3498DB),
                          Color(0xFFE67E22),
                          Color(0xFF9B59B6),
                          Color(0xFF1ABC9C),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Phase list
            ...phases.map((p) {
              final reached = elapsedHours >= p.startsAtHours;
              final isCurrent =
                  FastingNotifier.phaseFromHours(elapsedHours) == p;
              return AnimatedContainer(
                duration: 300.ms,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? _kFastColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent
                      ? Border.all(
                          color: _kFastColor.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: reached
                            ? _kFastColor.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        reached
                            ? PhosphorIconsFill.checkCircle
                            : PhosphorIconsRegular.circle,
                        size: 14,
                        color: reached
                            ? _kFastColor
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: reached
                                      ? (isDark
                                          ? Colors.white
                                          : AppColors
                                              .lightTextPrimary)
                                      : Colors.grey
                                          .withOpacity(0.5),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${p.startsAtHours.toInt()}h+',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: reached
                                      ? _kFastColor
                                          .withOpacity(0.8)
                                      : Colors.grey
                                          .withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                          if (isCurrent)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 3),
                              child: Text(
                                p.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white
                                          .withOpacity(0.55)
                                      : AppColors
                                          .lightTextSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Start Section ─────────────────────────────────────────────────────────────
class _StartFastSection extends ConsumerStatefulWidget {
  final bool isDark;
  const _StartFastSection({required this.isDark});

  @override
  ConsumerState<_StartFastSection> createState() =>
      _StartFastSectionState();
}

class _StartFastSectionState extends ConsumerState<_StartFastSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Protocol chips
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _protocols.length,
            itemBuilder: (_, i) {
              final (name, _, __) = _protocols[i];
              final isSel = i == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedIndex = i);
                },
                child: AnimatedContainer(
                  duration: 200.ms,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel
                        ? _kFastColor
                        : _kFastColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                                color: _kFastColor.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]
                        : null,
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSel
                          ? Colors.white
                          : _kFastColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Protocol description
        Text(
          _protocols[_selectedIndex].$3,
          style: TextStyle(
            fontSize: 12,
            color: widget.isDark
                ? Colors.white.withOpacity(0.5)
                : AppColors.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Start button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              final (name, hours, _) = _protocols[_selectedIndex];
              ref.read(fastingProvider.notifier).startFast(
                    targetHours: hours,
                    protocolName: name,
                  );
            },
            icon: const Icon(PhosphorIconsFill.play, size: 20),
            label: const Text('Start Fasting',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kFastColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              elevation: 8,
              shadowColor: _kFastColor.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}

// ── End Button ────────────────────────────────────────────────────────────────
class _EndFastButton extends ConsumerWidget {
  final bool isDark;
  const _EndFastButton({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor:
                  isDark ? AppColors.charcoalGlass : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('End Fast?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text(
                  'Your fasting session will be saved to history.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(fastingProvider.notifier).endFast();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger),
                  child: const Text('End Fast',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(PhosphorIconsFill.stop, size: 20),
        label: const Text('End Fast',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final FastingDoc session;
  final int elapsed;
  final bool isDark;

  const _StatsRow({
    required this.session,
    required this.elapsed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final startFmt =
        DateFormat('h:mm a').format(session.startTime);
    final endEst = session.startTime
        .add(Duration(hours: session.targetHours));
    final endFmt = DateFormat('h:mm a').format(endEst);
    final pct =
        ((elapsed / 3600.0) / session.targetHours * 100)
            .clamp(0, 100)
            .toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _StatChip(
              label: 'STARTED', value: startFmt, isDark: isDark),
          const SizedBox(width: 12),
          _StatChip(
              label: 'GOAL END', value: endFmt, isDark: isDark),
          const SizedBox(width: 12),
          _StatChip(
              label: 'PROGRESS',
              value: '$pct%',
              isDark: isDark,
              color: _kFastColor),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.isDark,
    this.color = const Color(0xFF9B59B6),
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: color.withOpacity(isDark ? 0.2 : 0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: color.withOpacity(0.7))),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : AppColors.lightTextPrimary)),
          ],
        ),
      ),
    );
  }
}

// ── Recent History ────────────────────────────────────────────────────────────
class _RecentHistory extends StatelessWidget {
  final List<FastingDoc> history;
  final bool isDark;

  const _RecentHistory(
      {required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final recent = history.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Sessions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...recent.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.charcoalGlass
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: (s.hitTarget
                            ? AppColors.dynamicMint
                            : _kFastColor)
                        .withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black
                          .withOpacity(isDark ? 0 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (s.hitTarget
                              ? AppColors.dynamicMint
                              : _kFastColor)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      s.hitTarget
                          ? PhosphorIconsFill.checkCircle
                          : PhosphorIconsFill.timer,
                      color: s.hitTarget
                          ? AppColors.dynamicMint
                          : _kFastColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(s.protocolName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Text(
                          DateFormat('EEE, MMM d')
                              .format(s.startTime),
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.45)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${s.durationHours.toStringAsFixed(1)}h',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: s.hitTarget
                              ? AppColors.dynamicMint
                              : _kFastColor,
                        ),
                      ),
                      Text(
                        '/ ${s.targetHours}h goal',
                        style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4)),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: i * 60))
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, duration: 350.ms);
          }),
        ],
      ),
    );
  }
}
