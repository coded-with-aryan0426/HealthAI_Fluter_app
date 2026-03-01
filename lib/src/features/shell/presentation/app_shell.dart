import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const _GradientScannerFab(),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}

// ── Glass Nav Bar ─────────────────────────────────────────────────────────────
class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.deepObsidian.withOpacity(0.88)
                : Colors.white.withOpacity(0.88),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  // Left side: Home + Habits
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
                    iconRegular: PhosphorIconsRegular.checkSquareOffset,
                    iconFill: PhosphorIconsFill.checkSquareOffset,
                    label: 'Habits',
                    onTap: () => onTap(1),
                  ),
                  // FAB spacer
                  const SizedBox(width: 76),
                  // Right side: Nutrition + Profile
                  _NavItem(
                    index: 2,
                    currentIndex: currentIndex,
                    iconRegular: PhosphorIconsRegular.bowlFood,
                    iconFill: PhosphorIconsFill.bowlFood,
                    label: 'Nutrition',
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    index: 3,
                    currentIndex: currentIndex,
                    iconRegular: PhosphorIconsRegular.user,
                    iconFill: PhosphorIconsFill.user,
                    label: 'Profile',
                    onTap: () => onTap(3),
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

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 150.ms);
    _scaleAnim =
        Tween<double>(begin: 1.0, end: 0.85).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
    final activeColor = AppColors.dynamicMint;
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
            mainAxisSize: MainAxisSize.max,
            children: [
              // Icon area – fixed 32px height always
              SizedBox(
                height: 32,
                child: AnimatedSwitcher(
                  duration: 200.ms,
                  child: isSelected
                      ? Container(
                          key: const ValueKey('pill'),
                          width: 44,
                          height: 28,
                          decoration: BoxDecoration(
                            color: activeColor.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(widget.iconFill,
                              color: activeColor, size: 18),
                        )
                      : Icon(
                          key: const ValueKey('icon'),
                          widget.iconRegular,
                          color: inactiveColor,
                          size: 22,
                        ),
                ),
              ),
              // Label – fixed 14px height always
              SizedBox(
                height: 14,
                child: AnimatedDefaultTextStyle(
                  duration: 200.ms,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  child: Text(widget.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Gradient Scanner FAB ─────────────────────────────────────────────────────
class _GradientScannerFab extends StatefulWidget {
  const _GradientScannerFab();

  @override
  State<_GradientScannerFab> createState() => _GradientScannerFabState();
}

class _GradientScannerFabState extends State<_GradientScannerFab>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;
  late AnimationController _scanCtrl;
  late Animation<double> _scanLineAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: false);

    _rotateCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    _scanCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _scanLineAnim = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        context.push('/scanner');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: 120.ms,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  final scale = 1.0 + _pulseCtrl.value * 0.5;
                  final opacity = (1.0 - _pulseCtrl.value).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.dynamicMint.withOpacity(opacity * 0.5),
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
                    painter: _GradientRingPainter(),
                  ),
                ),
              ),

              // Main button body
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1E2E), Color(0xFF0E0E1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dynamicMint.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Corner reticle marks
                      const Icon(PhosphorIconsRegular.cornersOut,
                          color: Colors.white, size: 32),

                      // Inner QR icon
                      const Icon(PhosphorIconsFill.qrCode,
                          color: Colors.white, size: 20),

                      // Animated scan line
                      AnimatedBuilder(
                        animation: _scanLineAnim,
                        builder: (_, __) {
                          return Transform.translate(
                            offset: Offset(0, _scanLineAnim.value * 12),
                            child: Container(
                              width: 28,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.dynamicMint,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.dynamicMint.withOpacity(0.8),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
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
          AppColors.dynamicMint.withOpacity(0.6),
          AppColors.softIndigo,
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect, 0, math.pi * 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
