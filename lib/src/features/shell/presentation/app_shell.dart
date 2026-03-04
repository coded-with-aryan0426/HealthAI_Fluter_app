import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> _onBack(BuildContext context) async {
    if (navigationShell.currentIndex != 0) {
      HapticFeedback.lightImpact();
      navigationShell.goBranch(0, initialLocation: true);
      return;
    }
    final shouldExit = await _showExitSheet(context);
    if (shouldExit == true && context.mounted) {
      SystemNavigator.pop();
    }
  }

  Future<bool?> _showExitSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Icon(PhosphorIconsFill.doorOpen,
                    size: 42,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                const SizedBox(height: 14),
                Text('Exit HealthAI?',
                    style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Your progress is saved. See you next time!',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Stay'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppGradientButton(
                        label: 'Exit',
                        gradientColors: [AppColors.danger, AppColors.dangerDark],
                        onTap: () => Navigator.of(ctx).pop(true),
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack(context);
      },
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 19), // Perfectly aligns the text vertically
          child: const _AiCoachFab(),
        ),
        bottomNavigationBar: _CurvedNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (i) => _onTap(context, i),
        ),
      ),
    );
  }
}

// ── Curved Notched Nav Bar ─────────────────────────────────────────────────────

class _CurvedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CurvedNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.deepObsidian.withValues(alpha: 0.96)
        : Colors.white.withValues(alpha: 0.97);

    return ClipPath(
      clipper: _NavBarClipper(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.10),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Stack(
                children: [
                  // Top border line with gap in center
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 72),
                    painter: _NavBorderPainter(isDark: isDark),
                  ),
                  // Nav items row
                  Row(
                    children: [
                      // Left two items
                      _NavItem(
                        index: 0,
                        currentIndex: currentIndex,
                        iconRegular: PhosphorIconsRegular.house,
                        iconFill: PhosphorIconsFill.house,
                        label: 'Home',
                        onTap: () => onTap(0),
                      ),
                      _NavItem(
                        index: 1,
                        currentIndex: currentIndex,
                        iconRegular: PhosphorIconsRegular.barbell,
                        iconFill: PhosphorIconsFill.barbell,
                        label: 'Workout',
                        onTap: () => onTap(1),
                      ),
                      // Center gap for FAB — 88px wide
                      const SizedBox(width: 88),
                      // Right two items
                      _NavItem(
                        index: 2,
                        currentIndex: currentIndex,
                        iconRegular: PhosphorIconsRegular.checkSquareOffset,
                        iconFill: PhosphorIconsFill.checkSquareOffset,
                        label: 'Habits',
                        onTap: () => onTap(2),
                      ),
                      _NavItem(
                        index: 3,
                        currentIndex: currentIndex,
                        iconRegular: PhosphorIconsRegular.forkKnife,
                        iconFill: PhosphorIconsFill.forkKnife,
                        label: 'Nutrition',
                        onTap: () => onTap(3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clips the nav bar into a curved shape with a center notch for the FAB.
class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // FAB geometry logic:
    // Without translations, centerDocked places the widget's center at y = 0.
    // The FAB widget is 84px tall, so its y goes from -42 to 42.
    // The top circle is 68px tall, making the circle itself center at y = -8.
    // We translated it by +19, giving the circle a final center at y = 11.
    // We want a gap around the 34px radius circle, so we use radius 40.
    final guestRect = Rect.fromCircle(
      center: Offset(size.width / 2, 11),
      radius: 40,
    );
    return const CircularNotchedRectangle().getOuterPath(
      Rect.fromLTWH(0, 0, size.width, size.height),
      guestRect,
    );
  }

  @override
  bool shouldReclip(_NavBarClipper old) => false;
}

/// Paints the top border line with a gap under the notch.
class _NavBorderPainter extends CustomPainter {
  final bool isDark;
  const _NavBorderPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final guestRect = Rect.fromCircle(
      center: Offset(size.width / 2, 11),
      radius: 40,
    );
    final path = const CircularNotchedRectangle().getOuterPath(
      Rect.fromLTWH(0, 0, size.width, size.height),
      guestRect,
    );

    canvas.save();
    // Clip vertically so we only ever draw the top line + notch, 
    // avoiding the left, right, and bottom edges of the screen.
    canvas.clipRect(Rect.fromLTWH(-10, -10, size.width + 20, 60));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_NavBorderPainter old) => old.isDark != isDark;
}

// ── Nav Item (standard) ───────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final int index;
  final int currentIndex;
  final IconData iconRegular;
  final IconData iconFill;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.iconRegular,
    required this.iconFill,
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 130.ms);
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.82)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.index == widget.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 34,
                child: AnimatedSwitcher(
                  duration: 220.ms,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: isSelected
                      ? Container(
                          key: const ValueKey('active'),
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.dynamicMint,
                                AppColors.softIndigo,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dynamicMint.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          // ShaderMask applies a gradient to the icon inside the pill
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Colors.white],
                            ).createShader(bounds),
                            child: Icon(widget.iconFill, color: Colors.white, size: 18),
                          ),
                        )
                      : Padding(
                          key: const ValueKey('inactive'),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(widget.iconRegular,
                              color: inactiveColor, size: 22),
                        ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: 200.ms,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.dynamicMint
                      : inactiveColor,
                  letterSpacing: 0.2,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AI Coach FAB ──────────────────────────────────────────────────────────────
class _AiCoachFab extends StatefulWidget {
  const _AiCoachFab();

  @override
  State<_AiCoachFab> createState() => _AiCoachFabState();
}

class _AiCoachFabState extends State<_AiCoachFab>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
    _rotateCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        context.push('/chat');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.87 : 1.0,
        duration: 120.ms,
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      final t = _pulseCtrl.value;
                      final scale = 1.0 + t * 0.50;
                      final opacity = (1.0 - t).clamp(0.0, 1.0);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.softIndigo.withValues(alpha: opacity * 0.45),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Spinning gradient ring
                  AnimatedBuilder(
                    animation: _rotateCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _rotateCtrl.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(68, 68),
                        painter: _AiRingPainter(),
                      ),
                    ),
                  ),

                  // Main button body
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.softIndigo, Color(0xFF6B21A8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softIndigo.withValues(alpha: 0.50),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.sparkle,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'AI Coach',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 1,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppColors.softIndigo.withValues(alpha: 0.8),
          AppColors.dynamicMint,
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(rect);
    canvas.drawArc(rect, 0, math.pi * 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
